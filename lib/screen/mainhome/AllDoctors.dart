import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllDoctorsPage extends StatelessWidget {
  const AllDoctorsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],

        // Body with custom header + list
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Header text like BMI screen
              const Text(
                "Our Doctors",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),

              const SizedBox(height: 20),

              // The list
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final doctors = snapshot.data ?? [];
                    if (doctors.isEmpty) {
                      return const Center(child: Text("No doctors found"));
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = doctors[index];
                        final imageUrl = doc['profile'] as String?;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // TODO: navigate to details if needed
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      imageUrl != null
                                          ? NetworkImage(imageUrl)
                                          : null,
                                  child:
                                      imageUrl == null
                                          ? const Icon(
                                            Icons.person,
                                            size: 32,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['fullname'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${doc['specialist'] ?? '–'} • ${doc['based'] ?? '–'}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
