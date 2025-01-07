import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's bookings collection reference
  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _bookingsCollection.doc(booking.id).set(booking.toMap());
  }

  // Get all bookings for current user
  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _bookingsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get upcoming bookings for current user
  Stream<List<Booking>> getUpcomingBookings() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _bookingsCollection
        .where('userId', isEqualTo: user.uid)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update booking status
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _bookingsCollection.doc(bookingId).update({
      'status': status.toString().split('.').last,
    });
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Delete booking (only if it's cancelled or completed)
  Future<void> deleteBooking(String bookingId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _bookingsCollection.doc(bookingId).get();
    if (!doc.exists) throw Exception('Booking not found');

    final booking = Booking.fromMap(doc.data()!, doc.id);
    if (booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed) {
      throw Exception('Can only delete cancelled or completed bookings');
    }

    await _bookingsCollection.doc(bookingId).delete();
  }

  // Get booking by ID
  Future<Booking> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    if (!doc.exists) throw Exception('Booking not found');
    return Booking.fromMap(doc.data()!, doc.id);
  }
}
