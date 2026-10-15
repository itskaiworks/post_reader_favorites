import 'package:flutter/material.dart';

import '../app_theme.dart';

// Dialog for editing the short personal note on a saved post.
// It returns the new note text, or null if the user cancels.
class EditNoteDialog extends StatefulWidget {
  final String currentNote;

  const EditNoteDialog({super.key, required this.currentNote});

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.currentNote);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Personal Note',
        style: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: noteController,
        maxLines: 3,
        maxLength: 120,
        decoration: const InputDecoration(labelText: 'Write a short note'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, noteController.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}