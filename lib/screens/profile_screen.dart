import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubits/app_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../theme/app_theme.dart';
import 'dues_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _pendingPhotoBytes;
  bool _isUploadingPhoto = false;

  Future<void> _updateProfilePhoto(BuildContext context) async {
    final appCubit = context.read<AppCubit>();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _pendingPhotoBytes = bytes;
      _isUploadingPhoto = true;
    });

    final success = await appCubit.uploadProfilePhoto(pickedFile);
    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = false;
      if (!success) {
        _pendingPhotoBytes = null;
      }
    });
  }

  Widget _buildAvatar({
    required String? photoUrl,
    required String fallbackName,
  }) {
    final hasRemotePhoto = photoUrl != null && photoUrl.isNotEmpty;
    final remotePhotoUrl = photoUrl ?? '';

    Widget child;
    if (_pendingPhotoBytes != null) {
      child = Image.memory(
        _pendingPhotoBytes!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else if (hasRemotePhoto) {
      child = Image.network(
        remotePhotoUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              fallbackName.isNotEmpty
                  ? fallbackName.substring(0, 1).toUpperCase()
                  : 'S',
              style: const TextStyle(color: Colors.white, fontSize: 26),
            ),
          );
        },
      );
    } else {
      child = Center(
        child: Text(
          fallbackName.isNotEmpty
              ? fallbackName.substring(0, 1).toUpperCase()
              : 'S',
          style: const TextStyle(color: Colors.white, fontSize: 26),
        ),
      );
    }

    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: AppTheme.goldColor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final authUser = authState.user;

          return BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              final currentUserId =
                  context.read<AppCubit>().currentUserId ?? authUser?.uid;

              final me = state.members.firstWhere(
                (m) => m['id'] == currentUserId,
                orElse: () => {
                  'name':
                      authUser?.displayName ??
                      authUser?.email?.split('@').first ??
                      'Unknown',
                  'role': 'Member',
                  'email': authUser?.email ?? '',
                  'profilePhotoUrl': authUser?.photoURL,
                },
              );

              final displayName =
                  (me['name'] ?? authUser?.displayName ?? 'Unknown').toString();
              final photoUrl = me['profilePhotoUrl']?.toString();
              final role = (me['role'] ?? 'Member').toString();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: _isUploadingPhoto
                                ? null
                                : () => _updateProfilePhoto(context),
                            child: _buildAvatar(
                              photoUrl: photoUrl,
                              fallbackName: displayName,
                            ),
                          ),
                          if (state.isLoading || _isUploadingPhoto)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.goldColor,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingPhoto
                                  ? null
                                  : () => _updateProfilePhoto(context),
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
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
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
          );
        },
      ),
    );
  }
}
