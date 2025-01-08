import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import 'package:e_travel/core/services/offline_service.dart';
import 'dart:async';

class BookingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final OfflineService _offlineService;
  final _bookingStreamController = StreamController<List<Booking>>.broadcast();

  BookingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _offlineService = offlineService ?? OfflineService() {
    _initializeOfflineSync();
  }

  void _initializeOfflineSync() {
    // Check and sync offline data periodically
    Timer.periodic(const Duration(minutes: 5), (_) async {
      if (await _offlineService.isDataStale()) {
        await _offlineService.synchronizeOfflineData();
      }
    });
  }

  // Get user's bookings collection reference
  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _bookingsCollection.doc(booking.id).set(booking.toMap());
    } catch (e) {
      // If offline or error occurs, save locally
      await _offlineService.saveOfflineData('bookings', booking.toMap());
      // Update the stream with local data
      _updateLocalStream();
    }
  }

  // Get all bookings for current user
  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Listen to Firestore updates
      _bookingsCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        final bookings = snapshot.docs
            .map((doc) => Booking.fromMap(doc.data(), doc.id))
            .toList();
        _bookingStreamController.add(bookings);
      });

      // Also check for offline data
      _updateLocalStream();
    } catch (e) {
      // If offline, use only local data
      _updateLocalStream();
    }

    return _bookingStreamController.stream;
  }

  Future<void> _updateLocalStream() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final offlineBookings = await _offlineService.getOfflineData('bookings');
    final bookings = offlineBookings
        .where((data) => data['userId'] == user.uid)
        .map((data) => Booking.fromMap(data, data['id']))
        .toList();

    if (bookings.isNotEmpty) {
      _bookingStreamController.add(bookings);
    }
  }

  // Get upcoming bookings for current user
  Stream<List<Booking>> getUpcomingBookings() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
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
    } catch (e) {
      // If offline, filter local data for upcoming bookings
      return Stream.fromFuture(_getOfflineUpcomingBookings());
    }
  }

  Future<List<Booking>> _getOfflineUpcomingBookings() async {
    final offlineBookings = await _offlineService.getOfflineData('bookings');
    final now = DateTime.now();

    return offlineBookings
        .where((data) {
          final bookingDate = DateTime.parse(data['date']);
          return bookingDate.isAfter(now);
        })
        .map((data) => Booking.fromMap(data, data['id']))
        .toList();
  }

  // Update booking status
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      // Handle offline status updates
      final offlineBookings = await _offlineService.getOfflineData('bookings');
      final updatedBookings = offlineBookings.map((data) {
        if (data['id'] == bookingId) {
          data['status'] = status.toString().split('.').last;
          data['_needsSync'] = true;
        }
        return data;
      }).toList();

      await _offlineService.saveOfflineData('bookings', {
        'bookings': updatedBookings,
      });
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Delete booking (only if it's cancelled or completed)
  Future<void> deleteBooking(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) throw Exception('Booking not found');

      final booking = Booking.fromMap(doc.data()!, doc.id);
      if (booking.status != BookingStatus.cancelled &&
          booking.status != BookingStatus.completed) {
        throw Exception('Can only delete cancelled or completed bookings');
      }

      await _bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      // Mark for deletion when back online
      final offlineBookings = await _offlineService.getOfflineData('bookings');
      final updatedBookings =
          offlineBookings.where((data) => data['id'] != bookingId).toList();

      await _offlineService.saveOfflineData('bookings', {
        'bookings': updatedBookings,
      });
    }
  }

  // Get booking by ID
  Future<Booking> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) throw Exception('Booking not found');
      return Booking.fromMap(doc.data()!, doc.id);
    } catch (e) {
      // Try to find booking in offline data
      final offlineBookings = await _offlineService.getOfflineData('bookings');
      final bookingData = offlineBookings.firstWhere(
          (data) => data['id'] == bookingId,
          orElse: () => throw Exception('Booking not found'));
      return Booking.fromMap(bookingData, bookingId);
    }
  }

  void dispose() {
    _bookingStreamController.close();
  }
}
