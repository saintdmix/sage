import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SageDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> member;

  const SageDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member['name'] ?? 'Sage Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.wineColor,
                backgroundImage: member['profilePhotoUrl'] != null
                    ? NetworkImage(member['profilePhotoUrl'])
                    : null,
                child: member['profilePhotoUrl'] == null
                    ? Text(
                        (member['name'] != null &&
                                member['name'].toString().isNotEmpty)
                            ? member['name'].toString().substring(0, 1).toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              member['name'] ?? 'Unknown Member',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              member['role'] ?? 'Member',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.goldColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailCard(),
            const SizedBox(height: 24),
            _buildContributionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.wineColor,
              ),
            ),
            const Divider(),
            _buildDetailRow(Icons.email, 'Email', member['email']),
            _buildDetailRow(Icons.phone, 'WhatsApp', member['whatsapp']),
            _buildDetailRow(Icons.school, 'School', member['school']),
            _buildDetailRow(Icons.location_city, 'Location', member['location']),
            _buildDetailRow(Icons.work, 'Occupation', member['occupation']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.goldColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCard() {
    final contribution = ((member['myContribution'] ?? 0) as num).toDouble();
    return Card(
      color: AppTheme.goldColor.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.goldColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Total Contribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.wineColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₦${contribution.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.wineColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
