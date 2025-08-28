import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payments_provider.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider(); await auth.load();
  runApp(MyApp(auth: auth));
}

class MyApp extends StatelessWidget {
  final AuthProvider auth;
  const MyApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_)=>PaymentsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Paiements',
        theme: buildAppTheme(),
        home: auth.isAuthenticated ? const DashboardPage() : const LoginPage(),
      ),
    );
  }
}
