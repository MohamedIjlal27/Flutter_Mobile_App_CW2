import 'package:uuid/uuid.dart';

class BudgetEntry {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final String currency;
  final int memberCount;
  final double perPersonAmount;

  BudgetEntry({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.currency,
    required this.memberCount,
  })  : id = id ?? const Uuid().v4(),
        perPersonAmount = amount / memberCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'currency': currency,
      'memberCount': memberCount,
      'perPersonAmount': perPersonAmount,
    };
  }

  factory BudgetEntry.fromMap(Map<String, dynamic> map) {
    return BudgetEntry(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      currency: map['currency'],
      memberCount: map['memberCount'],
    );
  }

  BudgetEntry copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    String? currency,
    int? memberCount,
  }) {
    return BudgetEntry(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}
