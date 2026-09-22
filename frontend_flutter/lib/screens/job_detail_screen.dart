import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/status_chip.dart';

class JobDetailScreen extends StatefulWidget {
  final ApiClient api;
  final int jobId;
  const JobDetailScreen({super.key, required this.api, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Job? _job;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final jobs = await widget.api.listJobs();
    setState(() => _job = jobs.firstWhere((j) => j.id == widget.jobId));
  }

  Future<void> _advanceStatus() async {
    final job = _job!;
    final next = job.status.next;
    if (next == null) return;

    if (next == JobStatus.inProgress && job.status != JobStatus.waitingOnPart) {
      // Offer "waiting on part" as an alternative to a plain "in progress" move.
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Move this job to…'),
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
      if (choice == null) return;
      if (choice == 'waiting_on_part') {
        final part = await _askForPartName();
        if (part == null || part.trim().isEmpty) return;
        await _patch({'status': 'waiting_on_part', 'part_needed': part.trim()});
        return;
      }
    }

    await _patch({'status': next.toApi()});
  }

  Future<String?> _askForPartName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Which part are you waiting on?'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _patch(Map<String, dynamic> patch) async {
    setState(() => _busy = true);
    try {
      await widget.api.updateJob(widget.jobId, patch);
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: job == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${job.applianceType} — ${job.brand ?? "Unknown brand"}',
                        style: Theme.of(context).textTheme.titleLarge),
                    StatusChip(status: job.status),
                  ],
                ),
                const SizedBox(height: 16),
                _row('Model #', job.modelNumber),
                _row('Serial #', job.serialNumber),
                _row('Symptom', job.symptom),
                _row('Diagnosis', job.diagnosis),
                if (job.status == JobStatus.waitingOnPart) _row('Part needed', job.partNeeded),
                const SizedBox(height: 24),
                if (job.status.next != null)
                  FilledButton(
                    onPressed: _busy ? null : _advanceStatus,
                    child: Text(_busy
                        ? 'Saving…'
                        : 'Move to ${job.status.next!.label}'),
                  ),
              ],
            ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
