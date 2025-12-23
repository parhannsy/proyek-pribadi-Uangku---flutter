// lib/data/models/transaction_model.dart


enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final TransactionType type;
  final DateTime date;
  final String sourceOrPurpose; // Sumber jika Pemasukan, Tujuan jika Pengeluaran
  final int amount;
  final String? detailReference; // Ref ke ID Debt/Needs jika ada

  TransactionModel({
    required this.id,
    required this.type,
    required this.date,
    required this.sourceOrPurpose,
    required this.amount,
    this.detailReference,
  });
}

// Data Dummy untuk menampilkan UI sesuai gambar
final List<TransactionModel> dummyIncomeList = [
  TransactionModel(
    id: 'i1',
    type: TransactionType.income,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'antah berantah',
    amount: 1000000,
  ),
  TransactionModel(
    id: 'i2',
    type: TransactionType.income,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'antah berantah',
    amount: 1000000,
  ),
  TransactionModel(
    id: 'i3',
    type: TransactionType.income,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'antah berantah',
    amount: 1000000,
  ),
];

final List<TransactionModel> dummyExpenseList = [
  TransactionModel(
    id: 'e1',
    type: TransactionType.expense,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'hutang > kredivo',
    amount: 1000000,
    detailReference: 'x1', // Referensi ke tenor ke-1
  ),
  TransactionModel(
    id: 'e2',
    type: TransactionType.expense,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'antah berantah',
    amount: 1000000,
  ),
  TransactionModel(
    id: 'e3',
    type: TransactionType.expense,
    date: DateTime(2025, 1, 1),
    sourceOrPurpose: 'antah berantah',
    amount: 1000000,
  ),
];