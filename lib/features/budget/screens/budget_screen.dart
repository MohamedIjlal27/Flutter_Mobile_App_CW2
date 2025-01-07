import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BudgetBloc(
        repository: BudgetRepository(),
      ),
      child: const BudgetView(),
    );
  }
}

class BudgetView extends StatelessWidget {
  const BudgetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Budget Tracker'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BudgetLoaded) {
            return Column(
              children: [
                _BudgetSummary(
                  totalExpenses: state.totalExpenses,
                  averagePerPerson: state.averagePerPerson,
                  totalMembers: state.totalMembers,
                ),
                Expanded(
                  child: _ExpensesList(entries: state.entries),
                ),
              ],
            );
          } else if (state is BudgetError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Start tracking your expenses!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final budgetBloc = context.read<BudgetBloc>();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => BlocProvider.value(
              value: budgetBloc,
              child: const _AddExpenseForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  final double totalExpenses;
  final double averagePerPerson;
  final int totalMembers;

  const _BudgetSummary({
    Key? key,
    required this.totalExpenses,
    required this.averagePerPerson,
    required this.totalMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Per Person (${totalMembers} total)',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${averagePerPerson.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpensesList extends StatelessWidget {
  final List<BudgetEntry> entries;

  const _ExpensesList({Key? key, required this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          title: Text(entry.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.category),
              Text(
                'Split: ${entry.currency} ${entry.perPersonAmount.toStringAsFixed(2)} × ${entry.memberCount} members',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.currency} ${entry.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'per person: ${entry.currency} ${entry.perPersonAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          leading: CircleAvatar(
            child: Text(entry.title[0].toUpperCase()),
          ),
        );
      },
    );
  }
}

class _AddExpenseForm extends StatefulWidget {
  const _AddExpenseForm({Key? key}) : super(key: key);

  @override
  _AddExpenseFormState createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _memberCountController = TextEditingController(text: '1');
  String _selectedCategory = 'Food';
  String _selectedCurrency = 'USD';
  final _notesController = TextEditingController();

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Accommodation',
    'Activities',
    'Shopping',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memberCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter an amount';
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _memberCountController,
                    decoration: const InputDecoration(
                      labelText: 'Members',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final count = int.tryParse(value!);
                      if (count == null || count < 1) {
                        return 'Min 1';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Expense'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final entry = BudgetEntry(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        currency: _selectedCurrency,
        memberCount: int.parse(_memberCountController.text),
      );

      context.read<BudgetBloc>().add(AddBudgetEntry(entry));
      Navigator.pop(context);
    }
  }
}
