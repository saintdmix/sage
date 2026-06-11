import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'sage_details_screen.dart';

class SagesProfilesScreen extends StatelessWidget {
  const SagesProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sages Profiles')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('sages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load sages profiles.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final member = {'id': doc.id, ...doc.data()};
              final name = (member['name'] ?? 'Unknown Member').toString();
              final photoUrl = member['profilePhotoUrl']?.toString();
              final contribution = ((member['myContribution'] ?? 0) as num)
                  .toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.wineColor,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(
                            name.isNotEmpty
                                ? name.substring(0, 1).toUpperCase()
                                : 'S',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(member['school']?.toString() ?? 'Member'),
                  trailing: Text(
                    '₦${contribution.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.wineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SageDetailsScreen(member: member),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
