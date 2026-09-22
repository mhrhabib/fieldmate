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

        final currentFilter = state is JobListLoaded ? state.filter : null;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: RefreshIndicator(
                  onRefresh: () async => cubit.load(filter: currentFilter),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _DashboardHeader(jobCount: state is JobListLoaded ? state.jobs.length : null),
                      ),
                      SliverToBoxAdapter(
                        child: _StatusFilterBar(
                          selected: currentFilter,
                          onSelected: (status) => cubit.setFilter(status),
                        ),
                      ),
                      switch (state) {
                        JobListLoading() => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        JobListFailure(:final message) => SliverFillRemaining(
                            hasScrollBody: false,
                            child: _ErrorState(message: message),
                          ),
                        JobListLoaded(:final jobs) => jobs.isEmpty
                            ? const SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyState(),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                                sliver: SliverList.separated(
                                  itemCount: jobs.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final job = jobs[index];
                                    return _JobCard(
                                      job: job,
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => JobDetailScreen(jobId: job.id!),
                                          ),
                                        );
                                        cubit.load(filter: currentFilter);
                                      },
                                    );
                                  },
                                ),
                              ),
                        _ => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      },
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewJobScreen()),
              );
              cubit.load(filter: currentFilter);
            },
            icon: const Icon(Icons.add),
            label: const Text('New job'),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final int? jobCount;
  const _DashboardHeader({required this.jobCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  jobCount == null ? 'Loading your jobs…' : '$jobCount ${jobCount == 1 ? 'job' : 'jobs'} in view',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.build_outlined, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final JobStatus? selected;
  final ValueChanged<JobStatus?> onSelected;

  const _StatusFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <(String, JobStatus?)>[
      ('All', null),
      for (final status in JobStatus.values) (status.label, status),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, status) = chips[index];
          final isSelected = status == selected;
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(status),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            selectedColor: theme.colorScheme.primary,
            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFD9E3DE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  IconData get _applianceIcon {
    final type = job.applianceType.toLowerCase();
    if (type.contains('washer') || type.contains('laundry')) return Icons.local_laundry_service_outlined;
    if (type.contains('fridge') || type.contains('refrigerat')) return Icons.kitchen_outlined;
    if (type.contains('oven') || type.contains('stove')) return Icons.microwave_outlined;
    if (type.contains('dish')) return Icons.countertops_outlined;
    if (type.contains('ac') || type.contains('air')) return Icons.ac_unit_outlined;
    return Icons.handyman_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_applianceIcon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.applianceType} • ${job.brand ?? 'Unknown brand'}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.symptom,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: job.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined, size: 34, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('No jobs yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Tap "New job" to create your first service job.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 34, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
