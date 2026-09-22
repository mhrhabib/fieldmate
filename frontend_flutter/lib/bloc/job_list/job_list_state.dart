part of 'job_list_cubit.dart';

abstract class JobListState extends Equatable {
  const JobListState();
}

class JobListInitial extends JobListState {
  @override
  List<Object?> get props => [];
}

class JobListLoading extends JobListState {
  @override
  List<Object?> get props => [];
}

class JobListLoaded extends JobListState {
  final List<Job> jobs;
  final JobStatus? filter;

  const JobListLoaded({required this.jobs, this.filter});

  @override
  List<Object?> get props => [jobs, filter];
}

class JobListFailure extends JobListState {
  final String message;

  const JobListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
