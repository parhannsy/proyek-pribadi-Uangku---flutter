// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arus_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ArusState {
  // Status Loading
  bool get isLoading =>
      throw _privateConstructorUsedError; // Data Utama (Daftar Transaksi)
  List<Arus> get aruses =>
      throw _privateConstructorUsedError; // Status Tab yang Aktif
  ArusType get currentActiveTab =>
      throw _privateConstructorUsedError; // Rekapitulasi Keuangan
  double get totalIncome => throw _privateConstructorUsedError;
  double get totalExpense =>
      throw _privateConstructorUsedError; // Anchor Periode (Cukup satu DateTime sebagai jangkar bulan/tahun)
  // KOREKSI MENTOR: endDate dihapus karena kita menggunakan query strftime MM-YYYY
  DateTime get startDate => throw _privateConstructorUsedError; // Status Error
  String? get failureMessage => throw _privateConstructorUsedError;

  /// Create a copy of ArusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArusStateCopyWith<ArusState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArusStateCopyWith<$Res> {
  factory $ArusStateCopyWith(ArusState value, $Res Function(ArusState) then) =
      _$ArusStateCopyWithImpl<$Res, ArusState>;
  @useResult
  $Res call({
    bool isLoading,
    List<Arus> aruses,
    ArusType currentActiveTab,
    double totalIncome,
    double totalExpense,
    DateTime startDate,
    String? failureMessage,
  });
}

/// @nodoc
class _$ArusStateCopyWithImpl<$Res, $Val extends ArusState>
    implements $ArusStateCopyWith<$Res> {
  _$ArusStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? aruses = null,
    Object? currentActiveTab = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? startDate = null,
    Object? failureMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            aruses: null == aruses
                ? _value.aruses
                : aruses // ignore: cast_nullable_to_non_nullable
                      as List<Arus>,
            currentActiveTab: null == currentActiveTab
                ? _value.currentActiveTab
                : currentActiveTab // ignore: cast_nullable_to_non_nullable
                      as ArusType,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            failureMessage: freezed == failureMessage
                ? _value.failureMessage
                : failureMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArusStateImplCopyWith<$Res>
    implements $ArusStateCopyWith<$Res> {
  factory _$$ArusStateImplCopyWith(
    _$ArusStateImpl value,
    $Res Function(_$ArusStateImpl) then,
  ) = __$$ArusStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    List<Arus> aruses,
    ArusType currentActiveTab,
    double totalIncome,
    double totalExpense,
    DateTime startDate,
    String? failureMessage,
  });
}

/// @nodoc
class __$$ArusStateImplCopyWithImpl<$Res>
    extends _$ArusStateCopyWithImpl<$Res, _$ArusStateImpl>
    implements _$$ArusStateImplCopyWith<$Res> {
  __$$ArusStateImplCopyWithImpl(
    _$ArusStateImpl _value,
    $Res Function(_$ArusStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? aruses = null,
    Object? currentActiveTab = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? startDate = null,
    Object? failureMessage = freezed,
  }) {
    return _then(
      _$ArusStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        aruses: null == aruses
            ? _value._aruses
            : aruses // ignore: cast_nullable_to_non_nullable
                  as List<Arus>,
        currentActiveTab: null == currentActiveTab
            ? _value.currentActiveTab
            : currentActiveTab // ignore: cast_nullable_to_non_nullable
                  as ArusType,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        failureMessage: freezed == failureMessage
            ? _value.failureMessage
            : failureMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ArusStateImpl implements _ArusState {
  const _$ArusStateImpl({
    this.isLoading = true,
    final List<Arus> aruses = const [],
    required this.currentActiveTab,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    required this.startDate,
    this.failureMessage,
  }) : _aruses = aruses;

  // Status Loading
  @override
  @JsonKey()
  final bool isLoading;
  // Data Utama (Daftar Transaksi)
  final List<Arus> _aruses;
  // Data Utama (Daftar Transaksi)
  @override
  @JsonKey()
  List<Arus> get aruses {
    if (_aruses is EqualUnmodifiableListView) return _aruses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aruses);
  }

  // Status Tab yang Aktif
  @override
  final ArusType currentActiveTab;
  // Rekapitulasi Keuangan
  @override
  @JsonKey()
  final double totalIncome;
  @override
  @JsonKey()
  final double totalExpense;
  // Anchor Periode (Cukup satu DateTime sebagai jangkar bulan/tahun)
  // KOREKSI MENTOR: endDate dihapus karena kita menggunakan query strftime MM-YYYY
  @override
  final DateTime startDate;
  // Status Error
  @override
  final String? failureMessage;

  @override
  String toString() {
    return 'ArusState(isLoading: $isLoading, aruses: $aruses, currentActiveTab: $currentActiveTab, totalIncome: $totalIncome, totalExpense: $totalExpense, startDate: $startDate, failureMessage: $failureMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArusStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._aruses, _aruses) &&
            (identical(other.currentActiveTab, currentActiveTab) ||
                other.currentActiveTab == currentActiveTab) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.failureMessage, failureMessage) ||
                other.failureMessage == failureMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    const DeepCollectionEquality().hash(_aruses),
    currentActiveTab,
    totalIncome,
    totalExpense,
    startDate,
    failureMessage,
  );

  /// Create a copy of ArusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArusStateImplCopyWith<_$ArusStateImpl> get copyWith =>
      __$$ArusStateImplCopyWithImpl<_$ArusStateImpl>(this, _$identity);
}

abstract class _ArusState implements ArusState {
  const factory _ArusState({
    final bool isLoading,
    final List<Arus> aruses,
    required final ArusType currentActiveTab,
    final double totalIncome,
    final double totalExpense,
    required final DateTime startDate,
    final String? failureMessage,
  }) = _$ArusStateImpl;

  // Status Loading
  @override
  bool get isLoading; // Data Utama (Daftar Transaksi)
  @override
  List<Arus> get aruses; // Status Tab yang Aktif
  @override
  ArusType get currentActiveTab; // Rekapitulasi Keuangan
  @override
  double get totalIncome;
  @override
  double get totalExpense; // Anchor Periode (Cukup satu DateTime sebagai jangkar bulan/tahun)
  // KOREKSI MENTOR: endDate dihapus karena kita menggunakan query strftime MM-YYYY
  @override
  DateTime get startDate; // Status Error
  @override
  String? get failureMessage;

  /// Create a copy of ArusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArusStateImplCopyWith<_$ArusStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
