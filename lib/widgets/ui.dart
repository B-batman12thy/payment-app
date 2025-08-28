import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);

class Gap extends SizedBox { const Gap(double v, {super.key}) : super(height: v); }

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status; // PENDING / SUCCESS / FAILED
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final colors = Theme.of(context).colorScheme;
    Color bg; Color fg;
    switch (s) {
      case 'SUCCESS': bg = Colors.green.withOpacity(.15); fg = Colors.green.shade800; break;
      case 'FAILED':  bg = Colors.red.withOpacity(.15);   fg = Colors.red.shade800;   break;
      default:        bg = Colors.amber.withOpacity(.2);  fg = Colors.amber.shade900; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

String money(num v) => _money.format(v);
