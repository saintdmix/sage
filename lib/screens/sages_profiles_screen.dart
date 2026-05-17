import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../theme/app_theme.dart';
import 'sage_details_screen.dart';

class SagesProfilesScreen extends StatelessWidget {
  const SagesProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sages Profiles')),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.members.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          return ListView.builder(
            itemCount: state.members.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final member = state.members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.wineColor,
                    backgroundImage: member['profilePhotoUrl'] != null
                        ? NetworkImage(member['profilePhotoUrl'])
                        : null,
                    child: member['profilePhotoUrl'] == null
                        ? Text(
                            (member['name'] != null && member['name'].toString().isNotEmpty)
                                ? member['name'].toString().substring(0, 1).toUpperCase()
                                : 'S',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    member['name'] ?? 'Unknown Member',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(member['school'] ?? 'Member'),
                  trailing: Text(
                    '₦${((member['myContribution'] ?? 0) as num).toDouble().toStringAsFixed(2)}',
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
