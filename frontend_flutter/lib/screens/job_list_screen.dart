import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/job_list/job_list_cubit.dart';
import '../models/models.dart';
import '../widgets/status_chip.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobListCubit, JobListState>(
      builder: (context, state) {
        final cubit = context.read<JobListCubit>();

        if (state is JobListInitial) {
          cubit.load();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Repairmate jobs'),
            actions: [
              IconButton(
                tooltip: 'Toggle waiting on part',
                onPressed: cubit.toggleWaitingOnPartFilter,
                icon: Icon(
                  Icons.pending_actions_outlined,
                  color: state is JobListLoaded && state.filter == JobStatus.waitingOnPart
                      ? Colors.orange
                      : null,
                ),
              ),
            ],
          ),
          body: switch (state) {
            JobListLoading() => const Center(child: CircularProgressIndicator()),
            JobListFailure(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(message),
                ),
              ),
            JobListLoaded(:final jobs) => jobs.isEmpty
                ? const Center(child: Text('No jobs yet. Tap + to add one.'))
                : RefreshIndicator(
                    onRefresh: () async => cubit.load(filter: state.filter),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                title: Text('${job.applianceType} • ${job.brand ?? 'Unknown brand'}'),
                                subtitle: Text(job.symptom, maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: StatusChip(status: job.status),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailScreen(jobId: job.id!),
                                    ),
                                  );
                                  cubit.load(filter: state.filter);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewJobScreen()),
              );
              cubit.load(filter: state is JobListLoaded ? state.filter : null);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
