import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final Function? onScheduleAdded;

  const AddButton({super.key, this.onScheduleAdded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah jadwal dinonaktifkan dalam demo'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A4877),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          elevation: 4,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
