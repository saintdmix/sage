import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'cubits/app_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => AppCubit()),
      ],
      child: MaterialApp(
        title: 'Sages App',
        theme: AppTheme.theme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
