import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubits/auth_cubit.dart';
import '../../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _profilePhoto;
  DateTime? _dateOfBirth;
  String? _profilePhotoError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schoolController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _whatsappController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null && mounted) {
      setState(() {
        _profilePhoto = pickedFile;
        _profilePhotoError = null;
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _dateOfBirth = pickedDate;
        _dateOfBirthController.text = MaterialLocalizations.of(
          context,
        ).formatMediumDate(pickedDate);
      });
    }
  }

  void _signUp() {
    final isFormValid = _formKey.currentState!.validate();
    final hasPhoto = _profilePhoto != null;
    final hasDob = _dateOfBirth != null;

    setState(() {
      _profilePhotoError = hasPhoto ? null : 'Please select a profile photo';
    });

    if (!isFormValid || !hasPhoto || !hasDob) {
      final message = !hasPhoto
          ? 'Please upload a profile photo'
          : 'Please select your date of birth';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<AuthCubit>().signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _schoolController.text,
      _locationController.text,
      _occupationController.text,
      _whatsappController.text,
      _profilePhoto!,
      _dateOfBirth!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<AuthCubit>().clearError();
          } else if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.wineColor, Colors.black],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: AppTheme.goldColor,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'CREATE ACCOUNT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.goldColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      InkWell(
                        onTap: _pickProfilePhoto,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.goldColor,
                                child: _profilePhoto == null
                                    ? const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile Photo',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap to upload a photo',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.upload,
                                color: AppTheme.goldColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_profilePhoto != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _profilePhoto!.name,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      if (_profilePhotoError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _profilePhotoError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateOfBirthController,
                        readOnly: true,
                        onTap: _pickDateOfBirth,
                        decoration: InputDecoration(
                          hintText: 'Date of Birth',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.calendar_month,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (_dateOfBirth == null ||
                              value == null ||
                              value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _schoolController,
                        decoration: InputDecoration(
                          hintText: 'School Served As a Student',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.school,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your School Served As a Student';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Current Location',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Current Location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _occupationController,
                        decoration: InputDecoration(
                          hintText: 'Occupation/Interest/Handwork',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.work,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Occupation/Interest/Handwork';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _whatsappController,
                        decoration: InputDecoration(
                          hintText: 'WhatsApp Number',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your WhatsApp Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppTheme.goldColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.status == AuthStatus.loading
                                ? null
                                : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldColor,
                              foregroundColor: AppTheme.wineColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: state.status == AuthStatus.loading
                                ? const CircularProgressIndicator(
                                    color: AppTheme.wineColor,
                                  )
                                : const Text('CREATE ACCOUNT'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Already have an account? Sign In",
                          style: TextStyle(color: AppTheme.goldColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
