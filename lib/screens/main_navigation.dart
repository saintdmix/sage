import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../cubits/auth_cubit.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'auth/sign_in_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const HomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.loading ||
            authState.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authState.status == AuthStatus.unauthenticated ||
            authState.user == null) {
          return const SignInScreen();
        }

        // Authenticated
        return BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AuthStatus.authenticated,
          listener: (context, state) {
            if (state.user != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed in successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                context.read<AppCubit>().initialize(state.user!.uid);
              });
            }
          },
          child: Scaffold(
            body: BlocListener<AppCubit, AppState>(
              listener: (context, appState) {
                if (appState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<AppCubit>().clearMessages();
                }
                if (appState.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<AppCubit>().clearMessages();
                }
              },
              child: _pages[_currentIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
