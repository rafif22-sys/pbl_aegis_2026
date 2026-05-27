import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/services/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/buku_tamu/top_bar_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Belum Dibaca, 2: Favorit
  bool _isLoading = true;
  String? _errorMessage;
  List<_MessageItem> _messages = [];

  static const _filterValues = ['semua', 'belum_dibaca', 'favorit'];

  @override
  void initState() {
    super.initState();
    _markRead(); // tandai sudah dibaca saat halaman dibuka
    _fetchMessages();
  }

  String get _token =>
      Provider.of<AuthProvider>(context, listen: false).token ?? '';

  // ── Mark semua pesan sudah dibaca ──────────────────────────────────────────
  Future<void> _markRead() async {
    try {
      await http.post(
        Uri.parse('${ApiClient.baseUrl}/pesan/mark-read'),
        headers: ApiClient.headers(token: _token),
      );
    } catch (_) {}
  }

  // ── Fetch pesan sesuai filter aktif ────────────────────────────────────────
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filter = _filterValues[_selectedFilterIndex];
      final uri = Uri.parse('${ApiClient.baseUrl}/pesan')
          .replace(queryParameters: {'filter': filter});

      final response = await http.get(
        uri,
        headers: ApiClient.headers(token: _token),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(body['message'] ?? 'Gagal mengambil pesan.');
      }

      final data = List<Map<String, dynamic>>.from(body['data'] ?? []);

      if (!mounted) return;
      setState(() {
        _messages = data.map(_MessageItem.fromJson).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal mengambil pesan dari admin.';
        _isLoading = false;
      });
    }
  }

  // ── Toggle favorit ─────────────────────────────────────────────────────────
  Future<void> _toggleFavorit(int index) async {
    final item = _messages[index];
    // Optimistic update
    setState(() {
      _messages[index] = item.copyWith(isStarred: !item.isStarred);
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/pesan/${item.id}/favorit'),
        headers: ApiClient.headers(token: _token),
      );
      final body = jsonDecode(response.body);
      if (body['success'] != true) throw Exception();

      // Jika sedang di tab Favorit dan di-unstar, hapus dari list
      if (_selectedFilterIndex == 2 && body['favorited'] == false) {
        setState(() => _messages.removeAt(index));
      }
    } catch (_) {
      // Rollback jika gagal
      if (!mounted) return;
      setState(() {
        _messages[index] = item;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffDCEFFE),
      body: SafeArea(
        child: Column(
          children: [
            const TopBarScreen(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  _buildFilterTab(0, 'Semua'),
                  const SizedBox(width: 10),
                  _buildFilterTab(1, 'Belum Dibaca'),
                  const SizedBox(width: 10),
                  _buildFilterTab(2, 'Favorit'),
                ],
              ),
            ),
            Expanded(child: _buildMessageList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xff093A9C)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchMessages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff093A9C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      final emptyText = switch (_selectedFilterIndex) {
        1 => 'Tidak ada pesan belum dibaca.',
        2 => 'Belum ada pesan favorit.',
        _ => 'Belum ada informasi.',
      };

      return RefreshIndicator(
        onRefresh: _fetchMessages,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 160),
            Center(
              child: Text(
                emptyText,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMessages,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _messages.length + 1,
        itemBuilder: (context, i) {
          if (i == _messages.length) return const SizedBox(height: 100);
          final msg = _messages[i];
          return _buildMessageCard(index: i, message: msg);
        },
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedFilterIndex == index) return;
          setState(() => _selectedFilterIndex = index);
          _fetchMessages();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff093A9C)
                : const Color(0xffD0E1F4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard({required int index, required _MessageItem message}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (message.hasLeftIndicator)
            Positioned(
              left: 0,
              top: 15,
              bottom: 15,
              child: Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message.sender,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          message.time,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade300),
                        ),
                        if (message.isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.3),
                  ),
                ),
                // ✅ Bintang bisa di-tap
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _toggleFavorit(index),
                    child: Icon(
                      message.isStarred ? Icons.star : Icons.star_border,
                      color: message.isStarred
                          ? Colors.yellow.shade700
                          : Colors.black54,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────
class _MessageItem {
  const _MessageItem({
    required this.id,
    required this.sender,
    required this.time,
    required this.content,
    required this.isStarred,
    required this.isUnread,
    this.hasLeftIndicator = false,
  });

  final int id;
  final String sender;
  final String time;
  final String content;
  final bool isStarred;
  final bool isUnread;
  final bool hasLeftIndicator;

  _MessageItem copyWith({bool? isStarred}) => _MessageItem(
        id: id,
        sender: sender,
        time: time,
        content: content,
        isStarred: isStarred ?? this.isStarred,
        isUnread: isUnread,
        hasLeftIndicator: hasLeftIndicator,
      );

  factory _MessageItem.fromJson(Map<String, dynamic> json) {
    return _MessageItem(
      id: json['id'] as int? ?? 0,
      sender: json['sender']?.toString() ?? 'Admin',
      time: json['time']?.toString() ?? '-',
      content: json['content']?.toString() ?? '-',
      isStarred: json['isStarred'] == true,
      isUnread: json['isUnread'] == true,
      hasLeftIndicator: json['hasLeftIndicator'] == true,
    );
  }
}