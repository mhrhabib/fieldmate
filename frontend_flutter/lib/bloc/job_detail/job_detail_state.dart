part of 'job_detail_cubit.dart';

abstract class JobDetailState extends Equatable {
  const JobDetailState();
}

class JobDetailInitial extends JobDetailState {
  @override
  List<Object?> get props => [];
}

class JobDetailLoading extends JobDetailState {
  @override
  List<Object?> get props => [];
}

class JobDetailLoaded extends JobDetailState {
  final Job job;
  final List<Job> history;

  const JobDetailLoaded({required this.job, required this.history});

  @override
  List<Object?> get props => [job, history];
}

class JobDetailFailure extends JobDetailState {
  final String message;

  const JobDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
