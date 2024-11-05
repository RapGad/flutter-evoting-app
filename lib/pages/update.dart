import 'package:flutter/material.dart';
class UpdateLevelDialog extends StatefulWidget {
  final void Function(int from, int to) onUpdate;

  const UpdateLevelDialog({Key? key, required this.onUpdate}) : super(key: key);

  @override
  _UpdateLevelDialogState createState() => _UpdateLevelDialogState();
}

class _UpdateLevelDialogState extends State<UpdateLevelDialog> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Users Level'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _fromController,
            decoration: InputDecoration(labelText: 'From Level'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _toController,
            decoration: InputDecoration(labelText: 'To Level'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            int from = int.tryParse(_fromController.text) ?? 0;
            int to = int.tryParse(_toController.text) ?? 0;
            widget.onUpdate(from, to);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}