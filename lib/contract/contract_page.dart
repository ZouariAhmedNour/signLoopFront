import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/providers/app_provider.dart';
import '../components/custom_button.dart';

class ContractPage extends ConsumerWidget {
  const ContractPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrats'),
        backgroundColor: const Color(0xFFB6D8F2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page des Contrats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Charger les contrats',
              onPressed: () {
                ref.read(dataProvider.notifier).state = 'Contrats chargés';
              },
              backgroundColor: const Color(0xFFB6D8F2),
            ),
            const SizedBox(height: 20),
            Text(data),
          ],
        ),
      ),
    );
  }
}