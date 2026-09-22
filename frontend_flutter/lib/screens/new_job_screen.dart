import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/new_job/new_job_cubit.dart';
import '../models/models.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key});

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

    await context.read<NewJobCubit>().submit(
      customer: Customer(
        name: _customerName.text.trim(),
        phone: _customerPhone.text.trim(),
      ),
      buildJob: (customerId) => Job(
        customerId: customerId,
        applianceType: _applianceType.text.trim(),
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        modelNumber: _modelNumber.text.trim().isEmpty ? null : _modelNumber.text.trim(),
        serialNumber: _serialNumber.text.trim().isEmpty ? null : _serialNumber.text.trim(),
        symptom: _symptom.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewJobCubit, NewJobState>(
      listener: (context, state) {
        if (state is NewJobFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is NewJobSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is NewJobSubmitting;
        final isDesktop = MediaQuery.sizeOf(context).width >= 760;
        return Scaffold(
          appBar: AppBar(title: const Text('New job')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                Text('Customer', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _FormSurface(
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _customerNameField()),
                            const SizedBox(width: 16),
                            Expanded(child: _customerPhoneField()),
                          ],
                        )
                      : Column(children: [_customerNameField(), _customerPhoneField()]),
                ),
                const SizedBox(height: 24),
                Text('Appliance', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _FormSurface(
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _applianceTypeField()),
                            const SizedBox(width: 16),
                            Expanded(child: _brandField()),
                          ],
                        )
                      : Column(children: [_applianceTypeField(), _brandField()]),
                ),
                const SizedBox(height: 12),
                _FormSurface(
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _modelField()),
                            const SizedBox(width: 16),
                            Expanded(child: _serialField()),
                          ],
                        )
                      : Column(children: [_modelField(), _serialField()]),
                ),
                const SizedBox(height: 24),
                Text('Problem', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _FormSurface(
                  child: TextFormField(
                    controller: _symptom,
                    decoration: const InputDecoration(labelText: 'What did the customer report?'),
                    maxLines: 4,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isSubmitting ? null : _save,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create job'),
                ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _customerNameField() => TextFormField(
        controller: _customerName,
        decoration: const InputDecoration(labelText: 'Name'),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      );

  Widget _customerPhoneField() => TextFormField(
        controller: _customerPhone,
        decoration: const InputDecoration(labelText: 'Phone'),
        keyboardType: TextInputType.phone,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      );

  Widget _applianceTypeField() => TextFormField(
        controller: _applianceType,
        decoration: const InputDecoration(
          labelText: 'Appliance type',
          hintText: 'Refrigerator, Washer, Dryer…',
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      );

  Widget _brandField() => TextFormField(
        controller: _brand,
        decoration: const InputDecoration(labelText: 'Brand'),
      );

  Widget _modelField() => TextFormField(
        controller: _modelNumber,
        decoration: const InputDecoration(labelText: 'Model number'),
      );

  Widget _serialField() => TextFormField(
        controller: _serialNumber,
        decoration: const InputDecoration(labelText: 'Serial number'),
      );
}

class _FormSurface extends StatelessWidget {
  final Widget child;

  const _FormSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
