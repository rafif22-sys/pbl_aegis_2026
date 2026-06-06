// ─────────────────────────────────────────────────────────────────────────────
// helpers.dart
// Kumpulan fungsi pembantu untuk fitur Buku Tamu
// ─────────────────────────────────────────────────────────────────────────────

String? resolveFotoUrl(String? fotoTamu) {
  if (fotoTamu == null || fotoTamu.trim().isEmpty) return null;
  if (fotoTamu.startsWith('http://') || fotoTamu.startsWith('https://')) {
    return fotoTamu;
  }
  const supabaseStorageUrl =
      'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/aegis/';
  final cleaned =
      fotoTamu.startsWith('/') ? fotoTamu.substring(1) : fotoTamu;
  return '$supabaseStorageUrl$cleaned';
}

/// Format jam saja → "08:30"
String formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

/// Format tanggal singkat → "23 Mei"
String formatDateShort(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}

/// Format tanggal + jam lengkap → "23 Mei 2025  08:30"
String formatDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final tgl = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  final jam = '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
  return '$tgl  $jam';
}

/// Format tanggal panjang → "23 Mei 2025"
String formatDate(DateTime dt) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}