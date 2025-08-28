import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState()=>_LoginPageState(); }

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass  = TextEditingController();
  final name  = TextEditingController();
  bool loading=false, registerMode=false;

  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    setState(()=>loading=true);
    try {
      final auth = AuthService();
      Map<String,dynamic> data;
      if (registerMode) {
        data = await auth.register(name.text.trim(), email.text.trim(), pass.text.trim());
      } else {
        data = await auth.login(email.text.trim(), pass.text.trim());
      }
      await context.read<AuthProvider>().setAuth(
        data['token'] as String,
        Map<String,dynamic>.from(data['user']),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const DashboardPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally { if (mounted) setState(()=>loading=false); }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: form,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(registerMode ? 'Créer un compte' : 'Connexion',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (registerMode)
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nom complet'),
                      validator: (v)=> (v==null||v.trim().isEmpty) ? 'Champ requis' : null,
                    ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v)=> (v==null||!v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: pass,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                    validator: (v)=> (v==null||v.length<6) ? '6 caractères minimum' : null,
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading? null : _submit,
                        child: loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color: Colors.white))
                                       : Text(registerMode ? 'Créer le compte' : 'Se connecter'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: ()=> setState(()=> registerMode = !registerMode),
                      child: Text(registerMode ? 'Déjà membre ? Se connecter' : 'Créer un compte'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: scheme.surfaceContainerHighest.withOpacity(.6),
    );
  }
}
