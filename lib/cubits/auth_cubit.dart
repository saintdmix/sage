import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage:
          errorMessage, // We want to be able to pass null or new error
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthState()) {
    checkAuth();
  }

  void checkAuth() {
    _auth.authStateChanges().listen((User? user) {
      debugPrint(
        'AuthCubit authStateChanges: ${user == null ? 'null' : user.uid}',
      );
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    debugPrint('AuthCubit signIn started for $email');
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint(
        'AuthCubit signIn successful: ${userCredential.user?.uid ?? 'null user'}',
      );
      if (userCredential.user != null) {
        await _firestore.collection('sages').doc(userCredential.user!.uid).set({
          'name':
              userCredential.user!.displayName ??
              userCredential.user!.email?.split('@').first ??
              'Sage',
          'email': userCredential.user!.email ?? email.trim(),
          'role': 'Sage',
          'myContribution': 0.0,
        }, SetOptions(merge: true));
      }
      emit(
        AuthState(status: AuthStatus.authenticated, user: userCredential.user),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthCubit signIn failed: ${e.code} ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.message ?? 'An error occurred during sign in.',
        ),
      );
    } catch (e) {
      debugPrint('AuthCubit signIn failed: $e');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String school,
    String location,
    String occupation,
    String whatsapp,
    XFile profilePhoto,
    DateTime dateOfBirth,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String? photoUrl;
      if (userCredential.user != null) {
        photoUrl = await _uploadProfilePhoto(
          userCredential.user!.uid,
          profilePhoto,
        );

        await _firestore.collection('sages').doc(userCredential.user!.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'role': 'Sage',
          'school': school.trim(),
          'location': location.trim(),
          'occupation': occupation.trim(),
          'whatsapp': whatsapp.trim(),
          'dateOfBirth': Timestamp.fromDate(dateOfBirth),
          'dateOfBirthIso': dateOfBirth.toIso8601String(),
          'profilePhotoUrl': photoUrl,
          'myContribution': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update display name
        await userCredential.user!.updateDisplayName(name.trim());
        await userCredential.user!.updatePhotoURL(photoUrl);
      }

      emit(
        AuthState(status: AuthStatus.authenticated, user: userCredential.user),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.message ?? 'An error occurred during sign up.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<String> _uploadProfilePhoto(String userId, XFile file) async {
    final ref = FirebaseStorage.instance.ref().child(
      'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(file.path));
    }

    return ref.getDownloadURL();
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _auth.signOut();
      emit(AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      emit(
        state.copyWith(
          status: state.user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          errorMessage: null,
        ),
      );
    }
  }
}
