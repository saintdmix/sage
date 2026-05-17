import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AppState {
  final bool isLoading;
  final double totalGroupContribution;
  final double myContribution;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> duesHistory;
  final Map<String, dynamic>? accountDetails;
  final String? errorMessage;
  final String? successMessage;

  AppState({
    this.isLoading = false,
    this.totalGroupContribution = 0.0,
    this.myContribution = 0.0,
    this.members = const [],
    this.duesHistory = const [],
    this.accountDetails,
    this.errorMessage,
    this.successMessage,
  });

  AppState copyWith({
    bool? isLoading,
    double? totalGroupContribution,
    double? myContribution,
    List<Map<String, dynamic>>? members,
    List<Map<String, dynamic>>? duesHistory,
    Map<String, dynamic>? accountDetails,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      totalGroupContribution:
          totalGroupContribution ?? this.totalGroupContribution,
      myContribution: myContribution ?? this.myContribution,
      members: members ?? this.members,
      duesHistory: duesHistory ?? this.duesHistory,
      accountDetails: accountDetails ?? this.accountDetails,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  String? currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<StreamSubscription> _subscriptions = [];

  void initialize(String userId) {
    currentUserId = userId;
    _cancelSubscriptions();
    _fetchDataFromFirebase();
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void _fetchDataFromFirebase() {
    if (currentUserId == null) return;

    // 1. Fetch account details
    final sub1 = _firestore
        .doc('admin/account_number')
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              emit(state.copyWith(accountDetails: doc.data()));
            }
          },
          onError: (e) {
            debugPrint('Error fetching account details: $e');
          },
        );
    _subscriptions.add(sub1);

    // 2. Fetch total group contribution
    final sub2 = _firestore
        .doc('stats/contributions')
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final total = ((doc.data()?['totalAmount'] ?? 0) as num)
                  .toDouble();
              emit(state.copyWith(totalGroupContribution: total));
            }
          },
          onError: (e) {
            debugPrint('Error fetching total contributions: $e');
          },
        );
    _subscriptions.add(sub2);

    // 3. Fetch my contribution
    final sub3 = _firestore
        .collection('sages')
        .doc(currentUserId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final myContrib = ((doc.data()?['myContribution'] ?? 0) as num)
                  .toDouble();
              emit(state.copyWith(myContribution: myContrib));
            }
          },
          onError: (e) {
            debugPrint('Error fetching my contribution: $e');
          },
        );
    _subscriptions.add(sub3);

    // 4. Fetch members list
    final sub4 = _firestore
        .collection('sages')
        .snapshots()
        .listen(
          (query) {
            final members = query.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList();
            emit(state.copyWith(members: members));
          },
          onError: (e) {
            debugPrint('Error fetching members: $e');
          },
        );
    _subscriptions.add(sub4);

    // 5. Fetch my dues history
    final sub5 = _firestore
        .collection('dues')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (query) {
            final history = query.docs.map((doc) {
              final data = doc.data();
              final timestamp = data['timestamp'] as Timestamp?;
              final dateStr = timestamp != null
                  ? "${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')}"
                  : 'Just now';
              return {'id': doc.id, 'date': dateStr, ...data};
            }).toList();
            emit(state.copyWith(duesHistory: history));
          },
          onError: (e) {
            debugPrint('Error fetching dues history: $e');
          },
        );
    _subscriptions.add(sub5);
  }

  Future<void> uploadReceiptAndSubmitDue(XFile file, double amount) async {
    if (currentUserId == null) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      // Upload to Firebase Storage
      final ref = _storage.ref().child(
        'receipts/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(file.path));
      }

      final receiptUrl = await ref.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('dues').add({
        'userId': currentUserId,
        'amount': amount,
        'status': 'Pending', // Admin will confirm later
        'timestamp': FieldValue.serverTimestamp(),
        'receiptUrl': receiptUrl,
      });

      emit(
        state.copyWith(
          isLoading: false,
          successMessage:
              'Receipt uploaded successfully! Waiting for admin confirmation.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to upload receipt: $e',
        ),
      );
    }
  }

  Future<void> uploadProfilePhoto(XFile file) async {
    if (currentUserId == null) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final ref = _storage.ref().child(
        'profile_photos/${currentUserId}_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(file.path));
      }

      final photoUrl = await ref.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('sages').doc(currentUserId).update({
        'profilePhotoUrl': photoUrl,
      });

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Profile photo updated successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile photo: $e',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
