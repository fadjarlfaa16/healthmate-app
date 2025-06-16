// appointment/Appointment.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DoctorList.dart';
import 'DoctorDetails.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  Widget? _childPage;

  @override
  void initState() {
    super.initState();
    _childPage = _defaultPage();
  }

  Widget _defaultPage() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("User not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: userId)
              // .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "No Appointments Yet",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tap + to book a doctor",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 192, 192, 192),
                  ),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data!.docs;

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              return AnimationConfiguration.staggeredList(
                position: index,
                delay: const Duration(milliseconds: 100),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: _AppointmentCard(data)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _AppointmentCard(Map<String, dynamic> data) {
    final doctorId = data['doctorId'];
    final date = data['date'] ?? '-';
    final time = data['time'] ?? '-';
    final isScheduled = data['isScheduled'] ?? false;
    final status = isScheduled ? 'Scheduled' : 'Pending';

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('doctors').doc(doctorId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctorData = snapshot.data!.data() as Map<String, dynamic>?;

        if (doctorData == null) {
          return const ListTile(
            title: Text("Doctor data not found"),
            subtitle: Text("Invalid doctor ID"),
          );
        }

        final doctorName = doctorData['fullname'] ?? '-';
        final based = doctorData['based'] ?? '-';
        final specialist = doctorData['specialist'] ?? '-';
        final profile = doctorData['profile'];

        return Card(
          elevation: 3,
          color: Colors.white,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              collapsedBackgroundColor: Colors.white,
              backgroundColor: Colors.white,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading:
                  profile != null
                      ? CircleAvatar(backgroundImage: NetworkImage(profile))
                      : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                doctorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                specialist,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      status == 'Scheduled'
                          ? Colors.green[100]
                          : Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == 'Scheduled' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.pink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$date at $time',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.pink, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      based,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToDoctorList() {
    setState(() {
      _childPage = DoctorListPage(
        onDoctorSelected: (doctor) {
          if (doctor == null) {
            // Tombol back, kembali ke appointment list
            setState(() => _childPage = _defaultPage());
          } else {
            // Pilih dokter, ke halaman detail dokter
            setState(() {
              _childPage = DoctorDetailPage(
                doctor: doctor,
                onAppointmentBooked: () {
                  setState(() => _childPage = _defaultPage());
                },
              );
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _childPage,
      ),
      floatingActionButton:
          _childPage.runtimeType != DoctorListPage &&
                  _childPage.runtimeType != DoctorDetailPage
              ? FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 120, 205, 226),
                onPressed: _goToDoctorList,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
