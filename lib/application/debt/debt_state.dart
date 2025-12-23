// lib/application/debt/debt_state.dart

import 'package:equatable/equatable.dart';
import 'package:uangku/data/models/debt_model.dart';

// Equatable memungkinkan kita membandingkan dua object State
abstract class DebtState extends Equatable {
  const DebtState();

  @override
  List<Object?> get props => [];

  get debts => null;
}

// 1. STATE AWAL/LOADING
class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

// 2. STATE SUKSES MEMUAT DATA
class DebtLoadSuccess extends DebtState {
  @override
  final List<DebtModel> debts;
  
  const DebtLoadSuccess({required this.debts});

  @override
  List<Object?> get props => [debts];
}

// 3. STATE ERROR
class DebtLoadFailure extends DebtState {
  final String message;
  
  const DebtLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// 4. STATE UNTUK OPERASI (Menambahkan/Menyelesaikan Hutang)
// Berguna untuk menampilkan loading indicator pada tombol/modal saat operasi berjalan
class DebtOperationInProgress extends DebtState {}

// >>> KOREKSI UTAMA: Tambahkan properti 'message' dan gunakan timestamp di props
class DebtOperationSuccess extends DebtState {
  final String message;
  
  // Default message jika dipanggil tanpa argumen
  const DebtOperationSuccess({this.message = 'Operasi berhasil.'}); 

  @override
  List<Object?> get props => [
    message, 
    // WAJIB: Tambahkan pembeda waktu untuk memastikan BlocListener terpicu
    DateTime.now().millisecondsSinceEpoch, 
  ];
}

class DebtOperationFailure extends DebtState {
  final String message;
  const DebtOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}