import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:flutter/material.dart';

class EditBookingScreen extends StatefulWidget {
  final String bookingId;

  EditBookingScreen({required this.bookingId});

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final TextEditingController _peopleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final bookingSnapshot =
        await _firestore.collection('bookings').doc(widget.bookingId).get();
    if (bookingSnapshot.exists) {
      final data = bookingSnapshot.data()!;
      _peopleController.text =
          data['people'] ?? '0'; // Default value is '0' if null
      _selectedDate = DateTime.tryParse(data['date']) ??
          DateTime.now(); // Default to now if null
      // Assuming 'time' is stored as a string in the format 'HH:mm'
      final timeString = data['time'] ?? '12:00';
      final parts = timeString.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 12,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  Future<void> _updateBooking() async {
    await _firestore.collection('bookings').doc(widget.bookingId).update({
      'date': _selectedDate.toIso8601String(),
      'time': _selectedTime.format(context),
      'people': _peopleController.text,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully.')));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 5,
        title: const Text('Edit Booking'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Your Booking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _peopleController,
              decoration: InputDecoration(
                labelText: 'Number of People',
                labelStyle: const TextStyle(fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child:
                      const Text('Select Date', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Time: ${_selectedTime.format(context)}',
                  style: const TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child:
                      const Text('Select Time', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateBooking,
              child: const Text('Update Booking'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
