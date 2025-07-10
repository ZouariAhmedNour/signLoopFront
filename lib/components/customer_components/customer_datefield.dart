import 'package:flutter/material.dart';

class CustomerDateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const CustomerDateField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Date de naissance (YYYY-MM-DD)',
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF1976D2)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
            onPressed: onTap,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        readOnly: true,
        style: const TextStyle(color: Color(0xFF2D3748)),
      ),
    );
  }
}