part of 'new_job_cubit.dart';

abstract class NewJobState extends Equatable {
  const NewJobState();
}

class NewJobInitial extends NewJobState {
  @override
  List<Object?> get props => [];
}

class NewJobSubmitting extends NewJobState {
  @override
  List<Object?> get props => [];
}

class NewJobSuccess extends NewJobState {
  final Job job;

  const NewJobSuccess(this.job);

  @override
  List<Object?> get props => [job];
}

class NewJobFailure extends NewJobState {
  final String message;

  const NewJobFailure(this.message);

  @override
  List<Object?> get props => [message];
}
