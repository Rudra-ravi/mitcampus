import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mitcampus/blocs/auth_bloc.dart';
import 'package:mitcampus/blocs/connectivity_bloc.dart';
import 'package:mitcampus/firebase_options.dart';
import 'package:mitcampus/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable offline persistence with a larger cache size
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => ConnectivityBloc(Connectivity()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MIT Campus',
        theme: ThemeData(
          primaryColor: const Color(0xFF2563EB),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFFF3F4F6),
            error: const Color(0xFFDC2626),
            // Add more colors for settings page
            surface: const Color(0xFFFFFFFF),
            background: const Color(0xFFF9FAFB),
            onPrimary: const Color(0xFFFFFFFF),
            onSecondary: const Color(0xFF1F2937),
            onSurface: const Color(0xFF1F2937),
            onBackground: const Color(0xFF6B7280),
          ),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFF1F2937),
            displayColor: const Color(0xFF1F2937),
          ),
          // Add settings specific theme data
          cardTheme: const CardTheme(
            color: Color(0xFFFFFFFF),
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          listTileTheme: const ListTileThemeData(
            tileColor: Color(0xFFFFFFFF),
            selectedTileColor: Color(0xFFF3F4F6),
            iconColor: Color(0xFF2563EB),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF2563EB);
              }
              return const Color(0xFF9CA3AF);
            }),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFFBFDBFE);
              }
              return const Color(0xFFE5E7EB);
            }),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
