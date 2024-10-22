import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/auth_bloc.dart';
import 'package:mitcampus/firebase_options.dart';
import 'package:mitcampus/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MIT Campus App',
        theme: ThemeData(
          primaryColor: const Color(0xFF2563EB),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFFF3F4F6),
            error: const Color(0xFFDC2626),
          ),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFF1F2937),
            displayColor: const Color(0xFF1F2937),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
