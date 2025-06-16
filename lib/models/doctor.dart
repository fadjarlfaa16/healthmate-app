// class Doctor {
//   final String name;
//   final int age;
//   final String based;
//   final String contact;

//   const Doctor({
//     required this.name,
//     required this.age,
//     required this.based,
//     required this.contact,
//   });
// }

class Doctor {
  final String id;
  final String fullname;
  final int age;
  final String based;
  final String contact;
  final String specialist;
  final int? appointmentCount;
  final String? profile;

  Doctor({
    required this.id,
    required this.fullname,
    required this.age,
    required this.based,
    required this.contact,
    required this.specialist,
    this.appointmentCount,
    this.profile,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Doctor(
      id: docId,
      fullname: data['fullname'] ?? '',
      age: data['age'] ?? 0,
      based: data['based'] ?? '',
      contact: data['contact'] ?? '',
      specialist: data['specialist'] ?? '',
      appointmentCount: data['appointmentCount'],
      profile: data['profile'],
    );
  }
}
