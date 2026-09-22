import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api_client.dart';
import '../../models/models.dart';

part 'job_list_state.dart';

class JobListCubit extends Cubit<JobListState> {
  final ApiClient api;

  JobListCubit({required this.api}) : super(JobListInitial());

  Future<void> load({JobStatus? filter}) async {
    emit(JobListLoading());

    try {
      final jobs = await api.listJobs(status: filter);
      emit(JobListLoaded(jobs: jobs, filter: filter));
    } catch (e) {
      emit(JobListFailure(e.toString()));
    }
  }

  Future<void> toggleWaitingOnPartFilter() async {
    final current = state is JobListLoaded ? (state as JobListLoaded).filter : null;
    final nextFilter = current == JobStatus.waitingOnPart ? null : JobStatus.waitingOnPart;
    await load(filter: nextFilter);
  }
}
