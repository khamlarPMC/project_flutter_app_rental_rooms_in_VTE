import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final User user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String roleName = 'Unknown';
    if (user.roleId == 1) roleName = 'User';
    if (user.roleId == 2) roleName = 'Owner';
    if (user.roleId == 3) roleName = 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFD4A373),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.person, 'Name', user.name),
                const Divider(height: 24),
                _buildDetailRow(Icons.email, 'Email', user.email),
                const Divider(height: 24),
                _buildDetailRow(
                  Icons.phone,
                  'Phone',
                  user.phone ?? 'Not provided',
                ),
                const Divider(height: 24),
                _buildDetailRow(Icons.badge, 'Role', roleName),
                const Divider(height: 24),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Age',
                  user.age?.toString() ?? 'Not provided',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  Icons.people,
                  'Gender',
                  user.gender ?? 'Not provided',
                ),
                if (user.createdAt != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.access_time,
                    'Joined',
                    DateFormat('MMM dd, yyyy').format(user.createdAt!),
                  ),
                ],
                if (user.address != null) ...[
                  const Divider(height: 24),
                  const Text(
                    'Address Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.home,
                    'Village',
                    user.address!.village ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.map,
                    'District',
                    user.address!.district ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.public,
                    'Province',
                    user.address!.province ?? 'N/A',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD4A373), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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
}
