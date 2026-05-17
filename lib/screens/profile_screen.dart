import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dues_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _updateProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<AppCubit>().uploadProfilePhoto(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final me = state.members.firstWhere(
            (m) => m['id'] == context.read<AppCubit>().currentUserId,
            orElse: () => {'name': 'Unknown', 'role': 'Member'},
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _updateProfilePhoto(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.goldColor,
                          backgroundImage: me['profilePhotoUrl'] != null
                              ? NetworkImage(me['profilePhotoUrl'])
                              : null,
                          child: me['profilePhotoUrl'] == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      if (state.isLoading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(
                            color: AppTheme.wineColor,
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _updateProfilePhoto(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.wineColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  me['name'] ?? 'Unknown',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  me['role'] ?? 'Member',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Pay Dues Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DuesHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Dues'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.wineColor),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppTheme.wineColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.wineColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const Spacer(),
                const Center(
                  child: Text(
                    'Sages Group v1.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
