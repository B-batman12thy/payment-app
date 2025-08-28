import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override State<PaymentsPage> createState()=>_PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final desc = TextEditingController();
  final amount = TextEditingController();
  String category = 'internet';
  Uint8List? receiptBytes; String? receiptName;

  @override
  void initState(){
    super.initState();
    Future.microtask(()=> context.read<PaymentsProvider>().fetch());
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png','webp']);
    if(res!=null && res.files.isNotEmpty){
      setState((){ receiptBytes = res.files.first.bytes; receiptName = res.files.first.name; });
    }
  }

  @override
  Widget build(BuildContext context){
    final p = context.watch<PaymentsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Filtres
          Row(children:[
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText:'Jour (YYYY-MM-DD)'),
              onChanged: (v){ p.day = v; },
            )),
            const SizedBox(width:8),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText:'Mois (YYYY-MM)'),
              onChanged: (v){ p.month = v; },
            )),
            const SizedBox(width:8),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText:'Année (YYYY)'),
              onChanged: (v){ p.year = v; },
            )),
            const SizedBox(width:8),
            ElevatedButton(onPressed: p.loading? null: p.fetch, child: const Text('Filtrer')),
          ]),
          const SizedBox(height:16),
          // Formulaire nouveau paiement
          ExpansionTile(
            title: const Text('Nouveau paiement'),
            children: [
              Row(children:[
                Expanded(child: TextField(controller: desc, decoration: const InputDecoration(labelText:'Description'))),
                const SizedBox(width:8),
                SizedBox(width:160, child: TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'Montant'))),
                const SizedBox(width:8),
                DropdownButton<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value:'internet', child: Text('Internet')),
                    DropdownMenuItem(value:'electricity', child: Text('Électricité')),
                    DropdownMenuItem(value:'water', child: Text('Eau')),
                    DropdownMenuItem(value:'rent', child: Text('Loyer')),
                    DropdownMenuItem(value:'other', child: Text('Autre')),
                  ],
                  onChanged: (v)=> setState(()=> category = v ?? 'internet'),
                ),
                const SizedBox(width:8),
                TextButton.icon(onPressed: _pickFile, icon: const Icon(Icons.attach_file), label: Text(receiptName ?? 'Justificatif')),
                const SizedBox(width:8),
                FilledButton(
                  onPressed: () async {
                    final a = num.tryParse(amount.text.trim());
                    if (desc.text.isEmpty || a==null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Champs invalides')));
                      return;
                    }
                    await p.create(
                      description: desc.text.trim(),
                      amount: a,
                      category: category,
                      receiptBytes: receiptBytes,
                      receiptFileName: receiptName,
                    );
                    setState(()=> { desc.clear(), amount.clear(), receiptBytes=null, receiptName=null });
                  },
                  child: const Text('Payer'),
                ),
              ]),
              const SizedBox(height:12),
            ],
          ),
          const SizedBox(height:8),
          // Liste
          Expanded(
            child: p.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: p.items.length,
                    separatorBuilder: (_, __)=> const Divider(height:1),
                    itemBuilder: (_, i){
                      final x = p.items[i];
                      return ListTile(
                        title: Text(x.description),
                        subtitle: Text('${x.category} • ${x.status} • ${x.createdAt.toIso8601String().substring(0,10)}'),
                        trailing: Text(x.amount.toStringAsFixed(2)),
                        onTap: (){},
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
