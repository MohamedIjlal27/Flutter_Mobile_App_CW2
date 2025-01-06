import 'package:e_travel/features/bookings/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  BookingsLoaded(this.bookings);
}

class BookingDetailLoaded extends BookingState {
  final Booking booking;
  BookingDetailLoaded(this.booking);
}

class BookingOperationSuccess extends BookingState {
  final String message;
  BookingOperationSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
