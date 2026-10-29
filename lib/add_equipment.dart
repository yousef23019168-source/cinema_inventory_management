import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cinema_inventory/equipment.dart';
import 'package:cinema_inventory/equipment_categories.dart';
import 'package:cinema_inventory/equipment_repo.dart';
import 'package:cinema_inventory/helpers.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();

  String _category = kEquipmentCategories.first;
  String _code = EquipmentRepository.generateCode();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    _notes.dispose();
    super.dispose();
  }

  double? _parseRate(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _name.text.trim();

    try {
      await EquipmentRepository.instance.add(
        Equipment(
          code: _code,
          name: name,
          category: _category,
          dailyRate: _parseRate(_rate.text)!,
          notes: _notes.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('"$name" added ($_code)')));
    } on CodeAlreadyExistsException {
      if (!mounted) return;
      setState(() {
        _code = EquipmentRepository.generateCode();
        _saving = false;
      });
      showMessage(context, 'That code was already taken. Tap Save again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, 'Could not save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add equipment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. ARRI Alexa Mini',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in kEquipmentCategories)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(categoryIcon(c), size: 20),
                        const SizedBox(width: 12),
                        Text(c),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Daily rental rate',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: '/ day',
              ),
              validator: (v) {
                final n = _parseRate(v);
                if (n == null) return 'Enter a valid number';
                if (n <= 0) return 'Rate must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: SelectableText(_code),
                subtitle: const Text('Equipment code · used for the QR label'),
                trailing: IconButton(
                  tooltip: 'Generate a new code',
                  icon: const Icon(Icons.refresh),
                  onPressed: _saving
                      ? null
                      : () => setState(
                          () => _code = EquipmentRepository.generateCode(),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving…' : 'Save equipment'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
