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
import 'package:e_travel/core/constants/locations.dart';
import 'package:e_travel/features/details/repositories/details_repository.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/repositories/review_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize offline service
  final offlineService = OfflineService();

  // Initialize locations in Firestore
  await initializeLocations();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => ReviewBloc(
            reviewRepository: ReviewRepository(),
          ),
        ),
      ],
      child: MyApp(offlineService: offlineService),
    ),
  );
}

// Initialize all locations in Firestore
Future<void> initializeLocations() async {
  try {
    final detailsRepository = DetailsRepository();
    await detailsRepository.createAllLocations(locations);
    print('Locations initialized successfully');
  } catch (e) {
    print('Error initializing locations: $e');
  }
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
