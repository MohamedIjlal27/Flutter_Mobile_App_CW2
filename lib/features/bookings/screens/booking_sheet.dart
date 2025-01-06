import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/features/locations/models/location_model.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingBottomSheet extends StatefulWidget {
  final Location location;

  const BookingBottomSheet({Key? key, required this.location})
      : super(key: key);

  @override
  _BookingBottomSheetState createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _peopleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Handle date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Handle time picker
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
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // More rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Wrap with Form widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 24, // Increased font size for the title
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),

              // Date Selection
              _buildDateSelectionButton(),

              const SizedBox(height: 12),

              // Time Selection
              _buildTimeSelectionButton(),

              const SizedBox(height: 16),

              // People Count
              _buildPeopleCountField(),

              const SizedBox(height: 16),

              // Submit Button (Booking confirmation)
              _buildBookingButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Date Selection Button
  Widget _buildDateSelectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectDate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 15), // Button padding
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
          ),
          elevation: 5, // Subtle shadow for the button
        ),
        child: Text(
          "Select Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
          style: const TextStyle(color: Colors.white), // Text color
        ),
      ),
    );
  }

  // Time Selection Button
  Widget _buildTimeSelectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectTime(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 15), // Button padding
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
          ),
          elevation: 5, // Subtle shadow for the button
        ),
        child: Text(
          "Select Time: ${_selectedTime.format(context)}",
          style: const TextStyle(color: Colors.white), // Text color
        ),
      ),
    );
  }

  // People Count Input Field
  Widget _buildPeopleCountField() {
    return TextFormField(
      controller: _peopleController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Number of People',
        labelStyle: const TextStyle(
          color: Colors.blueAccent, // Label color
          fontWeight: FontWeight.w600, // Slightly bolder label
        ),
        hintText: 'Enter number of people',
        hintStyle: const TextStyle(color: Colors.grey), // Hint text style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          borderSide:
              BorderSide(color: Colors.blueAccent, width: 1.5), // Border style
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.blueAccent, width: 2), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.blueAccent.withOpacity(0.5),
              width: 1.5), // Enabled border color
        ),
        filled: true,
        fillColor: Colors.white, // Background color
        contentPadding: const EdgeInsets.symmetric(
            vertical: 15, horizontal: 20), // Padding inside the field
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the number of people';
        }
        return null;
      },
    );
  }

  // Booking Confirmation Button
  Widget _buildBookingButton() {
    return ElevatedButton(
      onPressed: () {
        print('Button tapped'); // Added debug statement
        if (_formKey.currentState?.validate() ?? false) {
          _saveBooking(context);
        } else {
          print('Form is invalid'); // Added debug statement
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(
            vertical: 18, horizontal: 30), // Increased padding
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Text color
        ),
        elevation: 5, // Subtle shadow for 3D effect
      ),
      child: const Text(
        'Confirm Booking',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Save booking to Firebase
  Future<void> _saveBooking(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is logged in, proceeding with booking...'); // Debugging line
      final bookingData = {
        'location': widget.location.name,
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime.format(context),
        'people': _peopleController.text,
        'userId': user.uid,
        'status': 'pending',
      };

      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .add(bookingData);
        print('Booking saved to Firestore'); // Debugging line
        _showConfirmationDialog(context);
      } catch (e) {
        print('Error saving booking: $e'); // Debugging line
      }
    } else {
      print('User is not logged in'); // Debugging line
    }
  }

  // Show Confirmation Dialog
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Custom rounded shape
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle,
                  color: Colors.green, size: 30), // Success icon
              const SizedBox(width: 10),
              const Text(
                'Booking Confirmed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your booking has been successfully confirmed.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
