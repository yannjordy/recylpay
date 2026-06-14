import 'package:intl/intl.dart';

extension NumberFormatting on double {
  String toFCFA() {
    try {
      final format = NumberFormat('#,##0', 'fr_FR');
      return '${format.format(this)} FCFA';
    } catch (_) {
      return '${toStringAsFixed(0)} FCFA';
    }
  }

  String toKg() {
    return '${toStringAsFixed(1)} kg';
  }
}

extension DateTimeFormatting on DateTime {
  String toFrenchDate() {
    try {
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(this);
    } catch (_) {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    }
  }

  String toFrenchDateTime() {
    try {
      return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(this);
    } catch (_) {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
  }

  String toRelative() {
    try {
      final now = DateTime.now();
      final diff = now.difference(this);
      if (diff.inMinutes < 1) return "À l'instant";
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
      return toFrenchDate();
    } catch (_) {
      return '';
    }
  }
}
