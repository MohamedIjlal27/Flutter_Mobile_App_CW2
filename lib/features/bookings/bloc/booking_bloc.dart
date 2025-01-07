import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBookings extends BookingEvent {}

class LoadUpcomingBookings extends BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;

  const CreateBooking(this.booking);

  @override
  List<Object?> get props => [booking];
}

class CancelBooking extends BookingEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class DeleteBooking extends BookingEvent {
  final String bookingId;

  const DeleteBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class BookingsUpdated extends BookingEvent {
  final List<Booking> bookings;

  const BookingsUpdated(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

// States
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  final List<Booking> upcomingBookings;

  const BookingsLoaded({
    required this.bookings,
    required this.upcomingBookings,
  });

  @override
  List<Object?> get props => [bookings, upcomingBookings];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingSuccess extends BookingState {
  final String message;

  const BookingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repository;
  StreamSubscription? _bookingsSubscription;
  StreamSubscription? _upcomingBookingsSubscription;

  BookingBloc({required BookingRepository repository})
      : _repository = repository,
        super(BookingInitial()) {
    on<LoadUserBookings>(_onLoadBookings);
    on<LoadUpcomingBookings>(_onLoadUpcomingBookings);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
    on<DeleteBooking>(_onDeleteBooking);
    on<BookingsUpdated>(_onBookingsUpdated);

    // Start listening to bookings
    add(LoadUserBookings());
    add(LoadUpcomingBookings());
  }

  Future<void> _onLoadBookings(
    LoadUserBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _bookingsSubscription?.cancel();
      _bookingsSubscription = _repository.getUserBookings().listen(
            (bookings) => add(BookingsUpdated(bookings)),
          );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingBookings(
    LoadUpcomingBookings event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _upcomingBookingsSubscription?.cancel();
      _upcomingBookingsSubscription = _repository.getUpcomingBookings().listen(
            (bookings) => add(BookingsUpdated(bookings)),
          );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _repository.createBooking(event.booking);
      emit(const BookingSuccess('Booking created successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _repository.cancelBooking(event.bookingId);
      emit(const BookingSuccess('Booking cancelled successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onDeleteBooking(
    DeleteBooking event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _repository.deleteBooking(event.bookingId);
      emit(const BookingSuccess('Booking deleted successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onBookingsUpdated(
    BookingsUpdated event,
    Emitter<BookingState> emit,
  ) {
    if (state is BookingsLoaded) {
      final currentState = state as BookingsLoaded;
      emit(BookingsLoaded(
        bookings: event.bookings,
        upcomingBookings: currentState.upcomingBookings,
      ));
    } else {
      emit(BookingsLoaded(
        bookings: event.bookings,
        upcomingBookings: event.bookings.where((b) => b.isUpcoming).toList(),
      ));
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    _upcomingBookingsSubscription?.cancel();
    return super.close();
  }
}
