import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/sos_service.dart';
import '../../models/sos_report.dart';

class SOSFormScreen extends StatefulWidget {
  const SOSFormScreen({super.key});

  @override
  State<SOSFormScreen> createState() => _SOSFormScreenState();
}

class _SOSFormScreenState extends State<SOSFormScreen> {
  String? _selectedCategory;
  bool _isOtherChecked = false;
  final _otherController = TextEditingController();
  bool _needAllResidents = false;
  bool _isSending = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_fire_department, 'label': 'KEBAKARAN', 'key': 'kebakaran'},
    {'icon': Icons.masks, 'label': 'PENCURIAN', 'key': 'pencurian'},
    {'icon': Icons.pets, 'label': 'HEWAN LIAR', 'key': 'hewan_liar'},
    {'icon': Icons.tsunami, 'label': 'BENCANA ALAM', 'key': 'bencana_alam'},
  ];

  Future<void> _sendSOS() async {
    if (_selectedCategory == null && !_isOtherChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori darurat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.id ?? Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSending = false;
      });
      return;
    }

    String description = _selectedCategory ?? '';
    if (_isOtherChecked) {
      description += description.isNotEmpty ? ', ${_otherController.text}' : _otherController.text;
    }

    final sosId = 'SOS-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await SosService().createSosReport(
        SosReport(
          id: sosId,
          userId: userId,
          waktu: DateTime.now(),
          status: 'waiting',
          deskripsi: description,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('SOS berhasil dikirim!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon SOS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PANGGILAN SOS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const Text('Pilih keadaan darurat:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Grid Menu
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _categories.map((cat) {
                    final isActive = _selectedCategory == cat['key'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = isActive ? null : cat['key'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isActive ? Colors.blue[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], color: isActive ? Colors.white : Colors.black87),
                            const SizedBox(height: 8),
                            Text(cat['label'],
                                style: TextStyle(
                                    color: isActive ? Colors.white : Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Checkbox Lainnya
                Row(
                  children: [
                    Checkbox(
                      value: _isOtherChecked,
                      onChanged: (val) {
                        setState(() {
                          _isOtherChecked = val ?? false;
                        });
                      },
                    ),
                    const Text('LAINNYA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                if (_isOtherChecked)
                  TextField(
                    controller: _otherController,
                    decoration: InputDecoration(
                      hintText: 'Misal: Gangguan kebisingan...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                const SizedBox(height: 24),
                const Text('APAKAH BUTUH BANTUAN SEMUA WARGA?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),

                const SizedBox(height: 12),

                // Toggle Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _needAllResidents = !_needAllResidents;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: !_needAllResidents ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: !_needAllResidents
                                    ? Border.all(color: Colors.grey[200]!)
                                    : null),
                            child: const Text('TIDAK',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        ),
                        Expanded(
                          child: Text('YA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _needAllResidents ? Colors.blue : Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSending ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('BATAL',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendSOS,
                        icon: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send, size: 18, color: Colors.white),
                        label: const Text('KIRIM',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
