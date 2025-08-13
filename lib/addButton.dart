import 'package:flutter/material.dart';
import 'addModal.dart';

class AddButton extends StatefulWidget {
  final Function? onScheduleAdded;

  const AddButton({super.key, this.onScheduleAdded});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                AddModal(onScheduleAdded: widget.onScheduleAdded),
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
