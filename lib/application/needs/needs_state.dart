// lib/application/needs/needs_state.dart

import 'package:equatable/equatable.dart';
import 'package:uangku/data/models/needs_model.dart';

abstract class NeedsState extends Equatable {
  const NeedsState();

  @override
  List<Object?> get props => [];
}

// 1. Keadaan awal
class NeedsInitial extends NeedsState {}

// 2. Keadaan saat loading
class NeedsLoading extends NeedsState {}

// 3. Keadaan saat data berhasil dimuat
class NeedsLoadSuccess extends NeedsState {
  final List<NeedsModel> needs;
  
  const NeedsLoadSuccess({required this.needs});

  @override
  List<Object?> get props => [needs];
}

// 4. Keadaan saat terjadi error
class NeedsLoadFailure extends NeedsState {
  final String message;
  
  const NeedsLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// 5. State feedback untuk UI (Snackbar/Toast)
class NeedsOperationSuccess extends NeedsState {
  final String message;
  final List<NeedsModel> needs;
  // MENTOR TIP: Tambahkan timestamp agar Equatable selalu mendeteksi 
  // perubahan state meskipun list datanya identik.
  final DateTime timestamp;

  NeedsOperationSuccess({
    required this.message, 
    required this.needs,
  }) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [message, needs, timestamp];
}