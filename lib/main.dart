// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // WAJIB
import 'package:intl/date_symbol_data_local.dart'; // WAJIB untuk inisialisasi locale

// Import Services & Repositories
import 'package:uangku/data/services/database_service.dart';
import 'package:uangku/data/repositories/arus_repository.dart';
import 'package:uangku/data/impl/sqflite/arus_repository_impl.dart';
import 'package:uangku/data/repositories/debt_repository.dart';
import 'package:uangku/data/impl/sqflite/debt_repository_impl.dart';
import 'package:uangku/data/repositories/needs_repository.dart';
import 'package:uangku/data/impl/sqflite/needs_repository_impl.dart';

// Import Cubits
import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/needs/needs_cubit.dart';

// Import UI
import 'package:uangku/presentation/features/main_app.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

void main() async {
  // 1. Inisialisasi binding wajib
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. SOLUSI RED SCREEN: Inisialisasi Lokalisasi (PENTING!)
  // Ini akan menyelesaikan error 'locale data has not been initialized'
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // 3. Inisialisasi Database Service
  final databaseService = DatabaseService();

  // 4. Inisialisasi Repository Instance
  final arusRepository = ArusRepositoryImpl(databaseService);
  final debtRepository = DebtRepositoryImpl(databaseService);
  final needsRepository = NeedsRepositoryImpl(databaseService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ArusRepository>(create: (_) => arusRepository),
        RepositoryProvider<DebtRepository>(create: (_) => debtRepository),
        RepositoryProvider<NeedsRepository>(create: (_) => needsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ArusCubit>(
            create: (context) => ArusCubit(
              context.read<ArusRepository>(),
            )..initialize(), // Memanggil data awal (bulan ini)
          ),
          BlocProvider<DebtCubit>(
            create: (context) => DebtCubit(
              context.read<DebtRepository>(),
              context.read<ArusRepository>(),
            )..loadActiveDebts(),
          ),
          BlocProvider<NeedsCubit>(
            create: (context) => NeedsCubit(
              context.read<NeedsRepository>(),
            )..loadNeeds(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fulus',
      debugShowCheckedModeBanner: false,
      // MENTOR TIP: Set locale di sini juga agar widget internal Flutter (Calendar, dll) ikut berubah ke bahasa Indonesia
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.surfaceColor,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentGold,
          surface: AppColors.surfaceColor,
          // ignore: deprecated_member_use
          background: AppColors.primaryBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceColor,
          elevation: 0,
        ),
        fontFamily: 'Roboto', 
      ),
      home: const MainAppScreen(), 
    );
  }
}