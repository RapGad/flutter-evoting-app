import 'package:flutter/material.dart';
class DeleteUser extends StatefulWidget {
  final void Function(int userLevel) onDelete;

  const DeleteUser({Key? key, required this.onDelete}) : super(key: key);

  @override
  DeleteUserState createState() => DeleteUserState();
}

class DeleteUserState extends State<DeleteUser> {
  final TextEditingController levelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Users'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: levelController,
            decoration: InputDecoration(labelText: 'user Level'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
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
            int deleteLevel = int.tryParse(levelController.text) ?? 0;
            widget.onDelete(deleteLevel);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Delete'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    levelController.dispose();
    super.dispose();
  }
}