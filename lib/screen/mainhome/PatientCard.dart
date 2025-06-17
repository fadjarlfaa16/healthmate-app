import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('User data not found');
    }
    final data = doc.data()!;

    // Parse accountCreated
    final rawJoined = data['accountCreated'];
    DateTime joined;
    if (rawJoined is Timestamp) {
      joined = rawJoined.toDate();
    } else if (rawJoined is String) {
      joined = DateTime.tryParse(rawJoined) ?? DateTime.now();
    } else {
      joined = DateTime.now();
    }

    // Profile map
    final profile = (data['profile'] as Map<String, dynamic>?) ?? {};
    final fullName = profile['fullname'] as String? ?? '';
    final imagePath = profile['imagePath'] as String? ?? '';

    // Birth date (string "dd:MM:yyyy")
    DateTime? birth;
    if (profile['birth'] is String) {
      try {
        birth = DateFormat('dd:MM:yyyy').parse(profile['birth']);
      } catch (_) {}
    }

    // Domicile & age
    final domicile = profile['domicile'] as String? ?? '';
    final rawAge = profile['age'];
    final age =
        rawAge is int ? rawAge : int.tryParse(rawAge?.toString() ?? '') ?? 0;

    return {
      'id': user.uid,
      'joined': joined,
      'fullName': fullName,
      'imageUrl': imagePath,
      'birth': birth,
      'domicile': domicile,
      'age': age,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final u = snap.data!;
          final joinStr = DateFormat(
            'dd MMM yyyy',
          ).format(u['joined'] as DateTime);
          final birthStr =
              u['birth'] != null
                  ? DateFormat('dd MMM yyyy').format(u['birth'] as DateTime)
                  : '–';
          final ageStr = '${u['age']} years';
          final domicile = u['domicile'] as String;
          final fullName = u['fullName'] as String;
          final imageUrl = u['imageUrl'] as String;
          final id = u['id'] as String;

          return Column(
            children: [
              // Drag handle
              Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Expanded(
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 16,
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9D7FFB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child:
                                imageUrl.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Colors.white70,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 20),

                          // Name
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ID
                          Text(
                            id,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white54),
                          const SizedBox(height: 20),

                          // Row 1: Member Since & Birth Date
                          Row(
                            children: [
                              Expanded(
                                child: _InfoColumn(
                                  icon: Icons.calendar_today,
                                  label: 'Member Since',
                                  value: joinStr,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _InfoColumn(
                                  icon: Icons.cake,
                                  label: 'Birth Date',
                                  value: birthStr,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Row 2: Age & Domicile
                          Row(
                            children: [
                              Expanded(
                                child: _InfoColumn(
                                  icon: Icons.hourglass_bottom,
                                  label: 'Age',
                                  value: ageStr,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _InfoColumn(
                                  icon: Icons.home,
                                  label: 'Domicile',
                                  value: domicile.isNotEmpty ? domicile : '–',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Close button
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6C63FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Close Card',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
