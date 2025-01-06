import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/bookings/bloc/booking_event.dart';
import 'package:e_travel/features/bookings/bloc/booking_state.dart';
import 'package:e_travel/features/bookings/repositories/booking_repository.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingInitial()) {
    on<LoadUserBookings>(_onLoadUserBookings);
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBooking>(_onUpdateBooking);
    on<DeleteBooking>(_onDeleteBooking);
    on<LoadBookingDetails>(_onLoadBookingDetails);
  }

  void _onLoadUserBookings(
    LoadUserBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.getUserBookings(event.userId);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.createBooking(event.booking);
      emit(BookingOperationSuccess('Booking created successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onUpdateBooking(
    UpdateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.updateBooking(event.booking);
      emit(BookingOperationSuccess('Booking updated successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onDeleteBooking(
    DeleteBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.deleteBooking(event.bookingId);
      emit(BookingOperationSuccess('Booking cancelled successfully'));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onLoadBookingDetails(
    LoadBookingDetails event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await _bookingRepository.getBookingById(event.bookingId);
      emit(BookingDetailLoaded(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
