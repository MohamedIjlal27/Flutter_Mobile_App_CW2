import 'package:e_travel/features/bookings/models/booking_model.dart';

abstract class BookingEvent {}

class LoadUserBookings extends BookingEvent {
  final String userId;
  LoadUserBookings(this.userId);
}

class CreateBooking extends BookingEvent {
  final Booking booking;
  CreateBooking(this.booking);
}

class UpdateBooking extends BookingEvent {
  final Booking booking;
  UpdateBooking(this.booking);
}

class DeleteBooking extends BookingEvent {
  final String bookingId;
  DeleteBooking(this.bookingId);
}

class LoadBookingDetails extends BookingEvent {
  final String bookingId;
  LoadBookingDetails(this.bookingId);
}
