import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/providers/app_provider.dart';

class ContractHeader extends StatelessWidget {
  const ContractHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Contrats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final contracts = ref.watch(contractProvider);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${contracts.length} contrat${contracts.length > 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}