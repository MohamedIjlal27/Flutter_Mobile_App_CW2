import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/features/bookings/screens/edit_booking_screen.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  _BookingsListScreenState createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Stream<List<Map<String, dynamic>>>? _bookingsStream;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _setupBookingsStream();
  }

  void _setupBookingsStream() {
    if (_currentUser != null) {
      _bookingsStream = _firestore
          .collection('bookings')
          .where('userId', isEqualTo: _currentUser!.uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['bookingId'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  Future<void> _editBooking(String bookingId) async {
    if (bookingId.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBookingScreen(bookingId: bookingId),
        ),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Cancel Booking',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to cancel this booking?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmCancel == true) {
      try {
        await _firestore.collection('bookings').doc(bookingId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking canceled successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error canceling booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text('My Bookings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        centerTitle: true,
      ),
      body: _bookingsStream == null
          ? const Center(child: Text('Please sign in to view bookings.'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _bookingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return const Center(child: Text('No bookings found.'));
                }

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: AppGradients.primaryGradient,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['location'] ?? 'Unknown Location',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${booking['date'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Time: ${booking['time'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'People: ${booking['numberOfPeople'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _editBooking(booking['bookingId'] ?? ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text('Edit',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _cancelBooking(
                                      booking['bookingId'] ?? ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
