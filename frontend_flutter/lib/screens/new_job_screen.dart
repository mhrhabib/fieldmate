import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class NewJobScreen extends StatefulWidget {
  final ApiClient api;
  const NewJobScreen({super.key, required this.api});

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController();
  final _applianceType = TextEditingController();
  final _brand = TextEditingController();
  final _modelNumber = TextEditingController();
  final _serialNumber = TextEditingController();
  final _symptom = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _customerName,
      _customerPhone,
      _applianceType,
      _brand,
      _modelNumber,
      _serialNumber,
      _symptom,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // MVP simplification: always create a new customer record per job.
      // Add a customer picker/search once you have repeat customers to
      // actually search across.
      final customer = await widget.api.createCustomer(
        Customer(name: _customerName.text.trim(), phone: _customerPhone.text.trim()),
      );
      await widget.api.createJob(Job(
        customerId: customer.id!,
        applianceType: _applianceType.text.trim(),
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        modelNumber: _modelNumber.text.trim().isEmpty ? null : _modelNumber.text.trim(),
        serialNumber: _serialNumber.text.trim().isEmpty ? null : _serialNumber.text.trim(),
        symptom: _symptom.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Job')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _customerName,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _customerPhone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text('Appliance', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _applianceType,
              decoration: const InputDecoration(
                labelText: 'Appliance type',
                hintText: 'Refrigerator, Washer, Dryer…',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextFormField(
              controller: _modelNumber,
              decoration: const InputDecoration(labelText: 'Model number'),
            ),
            TextFormField(
              controller: _serialNumber,
              decoration: const InputDecoration(labelText: 'Serial number'),
            ),
            const SizedBox(height: 24),
            const Text('Problem', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _symptom,
              decoration: const InputDecoration(labelText: 'What did the customer report?'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create job'),
            ),
          ],
        ),
      ),
    );
  }
}
