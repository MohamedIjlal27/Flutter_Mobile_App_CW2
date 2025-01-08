import 'package:e_travel/core/constants/app_constants.dart';
import 'package:e_travel/core/config/firebase_options.dart';
import 'package:e_travel/features/auth/bloc/auth_bloc.dart';
import 'package:e_travel/features/auth/repositories/auth_repository.dart';
import 'package:e_travel/screens/splash_screen.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/core/services/offline_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize offline service
  final offlineService = OfflineService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          ),
        ),
      ],
      child: MyApp(offlineService: offlineService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final OfflineService offlineService;

  const MyApp({
    super.key,
    required this.offlineService,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appname,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
