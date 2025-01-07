import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

// Events
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgetEntries extends BudgetEvent {}

class AddBudgetEntry extends BudgetEvent {
  final BudgetEntry entry;

  const AddBudgetEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteBudgetEntry extends BudgetEvent {
  final String entryId;

  const DeleteBudgetEntry(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

class UpdateBudgetEntry extends BudgetEvent {
  final BudgetEntry entry;

  const UpdateBudgetEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class BudgetEntriesUpdated extends BudgetEvent {
  final List<BudgetEntry> entries;

  const BudgetEntriesUpdated(this.entries);

  @override
  List<Object?> get props => [entries];
}

// States
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetEntry> entries;
  final double totalExpenses;
  final double averagePerPerson;
  final int totalMembers;

  const BudgetLoaded({
    required this.entries,
    required this.totalExpenses,
    required this.averagePerPerson,
    required this.totalMembers,
  });

  @override
  List<Object?> get props =>
      [entries, totalExpenses, averagePerPerson, totalMembers];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _repository;
  StreamSubscription? _budgetSubscription;

  BudgetBloc({required BudgetRepository repository})
      : _repository = repository,
        super(BudgetInitial()) {
    on<LoadBudgetEntries>(_onLoadEntries);
    on<AddBudgetEntry>(_onAddEntry);
    on<DeleteBudgetEntry>(_onDeleteEntry);
    on<UpdateBudgetEntry>(_onUpdateEntry);
    on<BudgetEntriesUpdated>(_onEntriesUpdated);

    // Start listening to budget entries
    add(LoadBudgetEntries());
  }

  void _onLoadEntries(LoadBudgetEntries event, Emitter<BudgetState> emit) {
    emit(BudgetLoading());
    try {
      _budgetSubscription?.cancel();
      _budgetSubscription = _repository.getBudgetEntries().listen(
            (entries) => add(BudgetEntriesUpdated(entries)),
          );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onAddEntry(AddBudgetEntry event, Emitter<BudgetState> emit) async {
    try {
      await _repository.addBudgetEntry(event.entry);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onDeleteEntry(
      DeleteBudgetEntry event, Emitter<BudgetState> emit) async {
    try {
      await _repository.deleteBudgetEntry(event.entryId);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onUpdateEntry(
      UpdateBudgetEntry event, Emitter<BudgetState> emit) async {
    try {
      await _repository.updateBudgetEntry(event.entry);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onEntriesUpdated(
      BudgetEntriesUpdated event, Emitter<BudgetState> emit) {
    final entries = event.entries;
    final total = entries.fold<double>(0.0, (sum, entry) => sum + entry.amount);
    final totalMembers =
        entries.fold(0, (sum, entry) => sum + entry.memberCount);
    final averagePerPerson = totalMembers > 0 ? total / totalMembers : 0;

    emit(BudgetLoaded(
      entries: entries,
      totalExpenses: total,
      averagePerPerson: averagePerPerson.toDouble(),
      totalMembers: totalMembers,
    ));
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
