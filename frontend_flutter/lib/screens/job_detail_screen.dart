import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/job_detail/job_detail_cubit.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/status_chip.dart';

class JobDetailScreen extends StatelessWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobDetailCubit(api: context.read<ApiClient>(), jobId: jobId)..load(),
      child: _JobDetailView(jobId: jobId),
    );
  }
}

class _JobDetailView extends StatelessWidget {
  final int jobId;

  const _JobDetailView({required this.jobId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobDetailCubit, JobDetailState>(
      listener: (context, state) {
        if (state is JobDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is JobDetailLoading || state is JobDetailInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is JobDetailFailure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job details')),
            body: Center(child: Text(state.message)),
          );
        }

        final loaded = state as JobDetailLoaded;
        final job = loaded.job;

        return Scaffold(
          appBar: AppBar(title: const Text('Job details')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${job.applianceType} • ${job.brand ?? 'Unknown brand'}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusChip(status: job.status),
                ],
              ),
              const SizedBox(height: 18),
              _InfoRow(label: 'Model', value: job.modelNumber),
              _InfoRow(label: 'Serial', value: job.serialNumber),
              _InfoRow(label: 'Symptom', value: job.symptom),
              _InfoRow(label: 'Diagnosis', value: job.diagnosis),
              _InfoRow(label: 'Part needed', value: job.partNeeded),
              const SizedBox(height: 20),
              if (job.status.next != null)
                FilledButton(
                  onPressed: () async {
                    final cubit = context.read<JobDetailCubit>();
                    final next = job.status.next!;
                    if (next == JobStatus.inProgress && job.status != JobStatus.waitingOnPart) {
                      final option = await showDialog<String>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('Move job to…'),
                          children: [
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, 'in_progress'),
                              child: const Text('In Progress'),
                            ),
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, 'waiting_on_part'),
                              child: const Text('Waiting on a Part'),
                            ),
                          ],
                        ),
                      );

                      if (!context.mounted) return;
                      if (option == 'waiting_on_part') {
                        final part = await _askForPartName(context);
                        if (!context.mounted) return;
                        if (part == null || part.trim().isEmpty) return;
                        await cubit.updateStatus(
                          JobStatus.waitingOnPart,
                          partNeeded: part.trim(),
                        );
                        return;
                      }
                    }
                    await cubit.updateStatus(next);
                  },
                  child: Text('Move to ${job.status.next!.label}'),
                ),
              const SizedBox(height: 24),
              Text('History', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (loaded.history.isEmpty)
                const Text('No related callbacks yet.')
              else ...[
                ...loaded.history.map((entry) => ListTile(
                      dense: true,
                      title: Text('${entry.applianceType} • ${entry.status.label}'),
                      subtitle: Text(entry.symptom),
                    )),
              ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _askForPartName(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Which part is missing?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Door seal, compressor, etc.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}
