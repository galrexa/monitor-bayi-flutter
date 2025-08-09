import 'package:flutter/material.dart';
import '../models/room_model.dart';

class RoomForm extends StatefulWidget {
  final Room? room;
  final Function(String name, String description) onSave;

  const RoomForm({
    super.key,
    this.room,
    required this.onSave,
  });

  @override
  State<RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.room?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.room == null ? 'Tambah Kamar' : 'Edit Kamar'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kamar',
                hintText: 'Contoh: Kamar Bayi A',
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kamar tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Deskripsi kamar (opsional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(widget.room == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }
}
