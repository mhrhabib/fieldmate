import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/api_client.dart';
import '../../models/models.dart';

part 'new_job_state.dart';

class NewJobCubit extends Cubit<NewJobState> {
  final ApiClient api;

  NewJobCubit({required this.api}) : super(NewJobInitial());

  Future<void> submit({required Customer customer, required Job Function(int customerId) buildJob}) async {
    emit(NewJobSubmitting());

    try {
      final createdCustomer = await api.createCustomer(customer);
      final created = await api.createJob(buildJob(createdCustomer.id!));
      emit(NewJobSuccess(created));
    } catch (e) {
      emit(NewJobFailure(e.toString()));
    }
  }
}
