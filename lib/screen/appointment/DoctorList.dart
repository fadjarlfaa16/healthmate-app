import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/doctor.dart';

class DoctorListPage extends StatelessWidget {
  final Function(Doctor?) onDoctorSelected; // Update: boleh null untuk "balik"
  const DoctorListPage({Key? key, required this.onDoctorSelected})
    : super(key: key);

  Future<List<Doctor>> _fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    return snapshot.docs
        .map((doc) => Doctor.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tombol kembali
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 94, 131, 255),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    onDoctorSelected(null); // Update: trigger balik
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Available Doctors',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // List dokter
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: _fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 72, 115, 255),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No doctors found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final doctors = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];

                    return GestureDetector(
                      onTap: () {
                        onDoctorSelected(doctor); // Klik pilih dokter
                      },
                      child: Card(
                        elevation: 3,
                        color: Colors.transparent, // biar Card transparan
                        shadowColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ), // warna latar belakang baru di sini! 🎨
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      doctor.profile != null
                                          ? NetworkImage(doctor.profile!)
                                          : null,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  child:
                                      doctor.profile == null
                                          ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 30,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.fullname,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${doctor.specialist} · ${doctor.based}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
