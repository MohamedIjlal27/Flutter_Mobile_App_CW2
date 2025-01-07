import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's budget collection reference
  CollectionReference<Map<String, dynamic>> get _budgetCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  // Add a new budget entry
  Future<void> addBudgetEntry(BudgetEntry entry) async {
    await _budgetCollection.doc(entry.id).set(entry.toMap());
  }

  // Update an existing budget entry
  Future<void> updateBudgetEntry(BudgetEntry entry) async {
    await _budgetCollection.doc(entry.id).update(entry.toMap());
  }

  // Delete a budget entry
  Future<void> deleteBudgetEntry(String entryId) async {
    await _budgetCollection.doc(entryId).delete();
  }

  // Get all budget entries
  Stream<List<BudgetEntry>> getBudgetEntries() {
    return _budgetCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BudgetEntry.fromMap(data);
      }).toList();
    });
  }
}
