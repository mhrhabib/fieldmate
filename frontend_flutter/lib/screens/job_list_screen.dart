import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/status_chip.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';

class JobListScreen extends StatefulWidget {
  final ApiClient api;
  const JobListScreen({super.key, required this.api});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<Job>> _future;
  JobStatus? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _future = widget.api.listJobs(status: _filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            tooltip: 'Show only jobs waiting on a part',
            icon: Icon(
              Icons.build,
              color: _filter == JobStatus.waitingOnPart ? Colors.deepOrange : null,
            ),
            onPressed: () {
              _filter = _filter == JobStatus.waitingOnPart ? null : JobStatus.waitingOnPart;
              _load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<List<Job>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load jobs.\n${snapshot.error}\n\n'
                      'Is the backend running at $apiBaseUrl?'),
                ),
              ]);
            }
            final jobs = snapshot.data ?? [];
            if (jobs.isEmpty) {
              return const Center(child: Text('No jobs yet. Tap + to add one.'));
            }
            return ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final job = jobs[i];
                return ListTile(
                  title: Text('${job.applianceType} — ${job.brand ?? "Unknown brand"}'),
                  subtitle: Text(job.symptom, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: StatusChip(status: job.status),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => JobDetailScreen(api: widget.api, jobId: job.id!),
                    ));
                    _load();
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => NewJobScreen(api: widget.api),
          ));
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
