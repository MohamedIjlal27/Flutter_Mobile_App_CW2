import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/features/bookings/models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookings: ${e.toString()}');
    }
  }

  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore.collection('bookings').add(booking.toMap());
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  Future<void> updateBooking(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toMap());
    } catch (e) {
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: ${e.toString()}');
    }
  }

  Future<Booking> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) {
        throw Exception('Booking not found');
      }
      return Booking.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get booking: ${e.toString()}');
    }
  }
}
