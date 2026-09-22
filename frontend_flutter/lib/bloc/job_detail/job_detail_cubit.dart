import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api_client.dart';
import '../../models/models.dart';

part 'job_detail_state.dart';

class JobDetailCubit extends Cubit<JobDetailState> {
  final ApiClient api;
  final int jobId;

  JobDetailCubit({required this.api, required this.jobId}) : super(JobDetailInitial());

  Future<void> load() async {
    emit(JobDetailLoading());

    try {
      final job = (await api.listJobs()).firstWhere((element) => element.id == jobId);
      final history = await api.callbackHistory(jobId);
      emit(JobDetailLoaded(job: job, history: history));
    } catch (e) {
      emit(JobDetailFailure(e.toString()));
    }
  }

  Future<void> updateStatus(JobStatus status, {String? partNeeded}) async {
    final currentState = state;
    if (currentState is! JobDetailLoaded) return;

    try {
      final patch = <String, dynamic>{'status': status.toApi()};
      if (partNeeded != null) patch['part_needed'] = partNeeded;
      final updated = await api.updateJob(jobId, patch);
      final history = await api.callbackHistory(jobId);
      emit(JobDetailLoaded(job: updated, history: history));
    } catch (e) {
      emit(JobDetailFailure(e.toString()));
    }
  }
}
