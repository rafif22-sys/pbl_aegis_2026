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

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Sesi login tidak ditemukan.');
      }

      final data = await _selectPesan(token);

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

  Future<List<Map<String, dynamic>>> _selectPesan(String token) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/pesan'),
      headers: ApiClient.headers(token: token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengambil pesan.');
    }

    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  List<_MessageItem> get _filteredMessages {
    switch (_selectedFilterIndex) {
      case 1:
        return _messages.where((message) => message.isUnread).toList();
      case 2:
        return _messages.where((message) => message.isStarred).toList();
      default:
        return _messages;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _filteredMessages;

    return Scaffold(
      backgroundColor: const Color(0xffDCEFFE), // Warna background kustom
      body: SafeArea(
        child: Column(
          children: [
            const TopBarScreen(),

            // --- FILTER TABS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
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

            // --- LIST PESAN SECTION ---
            Expanded(child: _buildMessageList(messages)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<_MessageItem> messages) {
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
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
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

    if (messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchMessages,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Text(
                'Belum ada informasi.',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMessages,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...messages.map(
            (message) => _buildMessageCard(
              sender: message.sender,
              time: message.time,
              content: message.content,
              isStarred: message.isStarred,
              isUnread: message.isUnread,
              hasLeftIndicator: message.hasLeftIndicator,
            ),
          ),
          const SizedBox(
            height: 100,
          ), // Spacing agar tidak tertutup bottom navigation
        ],
      ),
    );
  }

  // Widget Builder untuk Tab Filter Atas
  Widget _buildFilterTab(int index, String label) {
    bool isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Builder untuk Card Pesan / Notifikasi
  Widget _buildMessageCard({
    required String sender,
    required String time,
    required String content,
    required bool isStarred,
    required bool isUnread,
    bool hasLeftIndicator = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Indikator Garis Samping Kiri (Spesifik untuk Supervisor di gambar)
          if (hasLeftIndicator)
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Pengirim, Waktu, & Dot Merah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade300,
                          ),
                        ),
                        if (isUnread) ...[
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
                // Baris Tengah: Isi Konten Pesan
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                // Baris Bawah: Tombol Bintang (Favorit)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    isStarred ? Icons.star : Icons.star_border,
                    color: isStarred ? Colors.yellow.shade700 : Colors.black54,
                    size: 24,
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

class _MessageItem {
  _MessageItem({
    required this.sender,
    required this.time,
    required this.content,
    required this.isStarred,
    required this.isUnread,
    this.hasLeftIndicator = false,
  });

  final String sender;
  final String time;
  final String content;
  final bool isStarred;
  final bool isUnread;
  final bool hasLeftIndicator;

  factory _MessageItem.fromJson(Map<String, dynamic> json) {
    final content = _firstStringValue(json, [
      'content',
      'pesan',
      'message',
      'isi',
      'isi_informasi',
      'konten',
      'deskripsi',
      'keterangan',
      'judul',
    ]);

    return _MessageItem(
      sender:
          _firstStringValue(json, [
            'pengirim',
            'sender',
            'created_by',
            'role',
          ]) ??
          'Admin',
      time: _formatDateTime(
        _firstStringValue(json, ['time', 'created_at', 'tanggal', 'waktu']),
      ),
      content: content ?? '-',
      isStarred:
          json['isStarred'] == true ||
          json['is_starred'] == true ||
          json['favorit'] == true,
      isUnread:
          json['isUnread'] == true ||
          json['is_read'] == false ||
          json['dibaca'] == false ||
          json['status'] == 'unread',
      hasLeftIndicator: json['hasLeftIndicator'] == true,
    );
  }

  static String? _firstStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static String _formatDateTime(String? raw) {
    if (raw == null) return '-';

    final date = DateTime.tryParse(raw);
    if (date == null) return raw;

    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month ${date.year} | $hour.$minute';
  }
}
