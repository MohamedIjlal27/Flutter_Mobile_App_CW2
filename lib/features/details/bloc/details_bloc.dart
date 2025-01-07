import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/details_model.dart';
import '../repositories/details_repository.dart';
import 'package:e_travel/features/locations/models/location_model.dart';

// Events
abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocationDetails extends DetailsEvent {
  final Location location;

  const LoadLocationDetails(this.location);

  @override
  List<Object?> get props => [location];
}

class UpdateLocationDetails extends DetailsEvent {
  final LocationDetails details;

  const UpdateLocationDetails(this.details);

  @override
  List<Object?> get props => [details];
}

// States
abstract class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object?> get props => [];
}

class DetailsInitial extends DetailsState {}

class DetailsLoading extends DetailsState {}

class DetailsLoaded extends DetailsState {
  final LocationDetails details;

  const DetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class DetailsError extends DetailsState {
  final String message;

  const DetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final DetailsRepository _repository;

  DetailsBloc({required DetailsRepository repository})
      : _repository = repository,
        super(DetailsInitial()) {
    on<LoadLocationDetails>(_onLoadDetails);
    on<UpdateLocationDetails>(_onUpdateDetails);
  }

  Future<void> _onLoadDetails(
    LoadLocationDetails event,
    Emitter<DetailsState> emit,
  ) async {
    emit(DetailsLoading());
    try {
      final details = await _repository.getLocationDetails(event.location);
      emit(DetailsLoaded(details));
    } catch (e) {
      emit(DetailsError(e.toString()));
    }
  }

  Future<void> _onUpdateDetails(
    UpdateLocationDetails event,
    Emitter<DetailsState> emit,
  ) async {
    try {
      await _repository.updateLocationDetails(event.details);
      emit(DetailsLoaded(event.details));
    } catch (e) {
      emit(DetailsError(e.toString()));
    }
  }
}
