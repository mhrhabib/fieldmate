import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/job_list/job_list_cubit.dart';
import '../models/models.dart';
import '../widgets/status_chip.dart';
import 'job_detail_screen.dart';
import 'job_list_screen.dart';
import 'new_job_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial job data when dashboard mounts
    context.read<JobListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final User? user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: IndexedStack(
        index: _selectedBottomIndex,
        children: [
          _DashboardHomeView(user: user),
          const JobListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedBottomIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
        indicatorColor: const Color(0xFF315C55).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF315C55)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Color(0xFF315C55)),
            label: 'All Jobs',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewJobScreen()),
          );
          if (context.mounted) {
            context.read<JobListCubit>().load();
          }
        },
        backgroundColor: const Color(0xFF315C55),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Job', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  final User? user;

  const _DashboardHomeView({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobListCubit, JobListState>(
      builder: (context, jobState) {
        final jobCubit = context.read<JobListCubit>();
        final jobs = jobState is JobListLoaded ? jobState.jobs : <Job>[];
        final isLoading = jobState is JobListLoading;

        final totalJobs = jobs.length;
        final waitingOnPartCount =
            jobs.where((j) => j.status == JobStatus.waitingOnPart).length;
        final scheduledCount =
            jobs.where((j) => j.status == JobStatus.scheduled || j.status == JobStatus.lead).length;
        final activeCount = jobs
            .where((j) =>
                j.status == JobStatus.inProgress || j.status == JobStatus.waitingOnPart)
            .length;
        final completedCount = jobs
            .where((j) =>
                j.status == JobStatus.completed ||
                j.status == JobStatus.invoiced ||
                j.status == JobStatus.paid)
            .length;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: RefreshIndicator(
                onRefresh: () async => jobCubit.load(),
                child: CustomScrollView(
                  slivers: [
                    // Top App & User Header
                    SliverToBoxAdapter(
                      child: _TopHeader(user: user),
                    ),

                    // KPI Summary Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Operation Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 600;
                                return GridView.count(
                                  crossAxisCount: isWide ? 4 : 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: isWide ? 1.6 : 1.4,
                                  children: [
                                    _KpiCard(
                                      title: 'Active Jobs',
                                      value: '$activeCount',
                                      icon: Icons.run_circle_outlined,
                                      accentColor: const Color(0xFF315C55),
                                    ),
                                    _KpiCard(
                                      title: 'Waiting on Part',
                                      value: '$waitingOnPartCount',
                                      icon: Icons.hourglass_top_rounded,
                                      accentColor: const Color(0xFFDD6B20),
                                      isAlert: waitingOnPartCount > 0,
                                    ),
                                    _KpiCard(
                                      title: 'Scheduled / Leads',
                                      value: '$scheduledCount',
                                      icon: Icons.calendar_today_rounded,
                                      accentColor: const Color(0xFF3182CE),
                                    ),
                                    _KpiCard(
                                      title: 'Completed / Paid',
                                      value: '$completedCount',
                                      icon: Icons.check_circle_outline_rounded,
                                      accentColor: const Color(0xFF38A169),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recent Jobs Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Jobs ($totalJobs)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => jobCubit.load(),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Jobs Feed List
                    if (isLoading && jobs.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (jobs.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyStateView(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList.separated(
                          itemCount: jobs.length > 8 ? 8 : jobs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return _JobCardItem(
                              job: job,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailScreen(jobId: job.id!),
                                  ),
                                );
                                jobCubit.load();
                              },
                            );
                          },
                        ),
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
}

class _TopHeader extends StatelessWidget {
  final User? user;

  const _TopHeader({required this.user});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of Repairmate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Appliance Tech';
    final email = user?.email ?? 'shop@repairmate.com';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF315C55), Color(0xFF1E3A34)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF315C55).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'R',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isAlert;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAlert ? accentColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
          width: isAlert ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              if (isAlert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Attention',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isAlert ? accentColor : const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF718096),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCardItem extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const _JobCardItem({required this.job, required this.onTap});

  IconData get _applianceIcon {
    final type = job.applianceType.toLowerCase();
    if (type.contains('washer') || type.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    }
    if (type.contains('fridge') || type.contains('refrigerat')) {
      return Icons.kitchen_outlined;
    }
    if (type.contains('oven') || type.contains('stove')) {
      return Icons.microwave_outlined;
    }
    if (type.contains('dish')) return Icons.countertops_outlined;
    if (type.contains('ac') || type.contains('air')) return Icons.ac_unit_outlined;
    return Icons.handyman_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF315C55).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_applianceIcon, color: const Color(0xFF315C55)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.applianceType} • ${job.brand ?? 'Unknown brand'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A202C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.symptom,
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: job.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFA0AEC0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFF315C55).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_outlined,
                  size: 36, color: Color(0xFF315C55)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No repair jobs found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "New Job" to log an appliance repair service job.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
