import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../widgets/ui.dart';
import 'payments_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _svc = PaymentService();
  Map<String, dynamic>? data;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await _svc.dashboard();
      if (!mounted) return;
      setState(() {
        data = res;
        error = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        data = null;
        error = e.toString();
        loading = false;
      });
    }
  }

  num _toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () async {
              try {
                await AuthService().logout();
              } catch (_) {}
              await context.read<AuthProvider>().clear();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
              ? _ErrorView(message: error!, onRetry: _load)
              : (data == null)
                  ? _EmptyView(onRetry: _load)
                  : RefreshIndicator(
                      onRefresh: () async => _load(),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'Bonjour ${user?['name'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const Gap(12),
                          LayoutBuilder(builder: (ctx, c) {
                            final isWide = c.maxWidth > 820;
                            final balance = _toNum(data!['balance']);
                            final monthly = _toNum(data!['monthly_total']);

                            final cards = [
                              Expanded(
                                child: StatCard(
                                  title: 'Solde disponible',
                                  value: money(balance),
                                  icon: Icons.account_balance_wallet_rounded,
                                ),
                              ),
                              const SizedBox(width: 16, height: 16),
                              Expanded(
                                child: StatCard(
                                  title: 'Total du mois',
                                  value: money(monthly),
                                  icon: Icons.bar_chart_rounded,
                                ),
                              ),
                            ];
                            return isWide
                                ? Row(children: cards)
                                : Column(children: cards);
                          }),
                          const Gap(20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Derniers paiements',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              TextButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const PaymentsPage()),
                                ),
                                icon: const Icon(Icons.list_alt_outlined),
                                label: const Text('Voir tout'),
                              ),
                            ],
                          ),
                          const Gap(8),
                          ..._recentPaymentsTiles(),
                        ],
                      ),
                    ),
    );
  }

  List<Widget> _recentPaymentsTiles() {
    final list = (data!['recent_payments'] as List?) ?? const [];
    if (list.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: const [
                Icon(Icons.inbox_outlined),
                SizedBox(width: 12),
                Text('Aucun paiement récent'),
              ],
            ),
          ),
        ),
      ];
    }
    return List<Widget>.from(list.map((p) {
      final amount = _toNum(p['amount']);
      final created =
          p['created_at']?.toString() ?? DateTime.now().toIso8601String();
      final category = (p['category'] ?? '').toString();
      final status = (p['status'] ?? '').toString();

      return Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(_iconForCategory(category))),
          title: Text(
            p['description']?.toString() ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('$category • ${created.substring(0, 16)}'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(money(amount),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              StatusChip(status.isEmpty ? 'PENDING' : status),
            ],
          ),
        ),
      );
    }));
  }

  IconData _iconForCategory(String c) {
    switch (c) {
      case 'internet':
        return Icons.wifi_rounded;
      case 'electricity':
        return Icons.flash_on_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'rent':
        return Icons.home_work_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 32, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Impossible de charger le tableau de bord',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.inbox_outlined, size: 32),
              const SizedBox(height: 12),
              const Text('Aucune donnée'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Recharger'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
