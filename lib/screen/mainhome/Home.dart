import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../../HospitalService.dart';
import 'BMI.dart';
import 'AllDoctors.dart';

class HomePageUI extends StatefulWidget {
  const HomePageUI({Key? key}) : super(key: key);

  @override
  State<HomePageUI> createState() => _HomePageUIState();
}

class _FullScreenBMIPredictionPage extends StatelessWidget {
  const _FullScreenBMIPredictionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1.0, // full screen
      builder:
          (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const BMIPredictionPage(), // panggil BMI page kamu di sini
          ),
    );
  }
}

class _FullScreenDoctorListPage extends StatelessWidget {
  const _FullScreenDoctorListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1.0,
      builder:
          (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const AllDoctorsPage(), // Ganti dengan halaman Doctor kamu
          ),
    );
  }
}

// class _FullScreenAppointmentPage extends StatelessWidget {
//   const _FullScreenAppointmentPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 1.0,
//       builder: (_, controller) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: const AppointmentPage(), // Ganti dengan halaman Appointment kamu
//       ),
//     );
//   }
// }

class _HomePageUIState extends State<HomePageUI> {
  Future<List<Map<String, dynamic>>>? _hospitalFuture;
  List<Map<String, dynamic>> _hospitals = [];
  LatLng? _currentPosition;
  final ScrollController _scrollController = ScrollController();
  int _visibleItemCount = 5;

  @override
  void initState() {
    super.initState();
    _hospitalFuture = _loadHospitals();
    _scrollController.addListener(_scrollListener);
  }

  Future<List<Map<String, dynamic>>> _loadHospitals() async {
    final pos = await _getCurrentLocation();
    final service = OpenStreetHospitalService();
    final hospitals = await service.getNearbyHospitals(
      pos.latitude,
      pos.longitude,
      radius: 10000,
    );

    setState(() {
      _hospitals = hospitals;
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    return hospitals;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _visibleItemCount += 5;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    final Distance distance = const Distance();
    return distance(_currentPosition!, LatLng(lat, lon)) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.monitor_heart_outlined,
        'label': 'BMI',
        'route': '/bmi',
        'color': Color.fromARGB(255, 33, 154, 224),
      },
      {
        'icon': Icons.people_alt_rounded,
        'label': 'Doctors',
        'route': '/doctorlist',
        'color': Color.fromARGB(255, 33, 154, 224),
      },
      {
        'icon': Icons.event_note,
        'label': 'Appointment',
        'route': '/appointment',
        'color': Color.fromARGB(255, 33, 154, 224),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF3282F7),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _hospitalFuture = _loadHospitals();
          });
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250,
              pinned: false,
              backgroundColor: const Color(0xFF3282F7),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 90, 24, 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome, User",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Consult your Health with us!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed:
                                      () =>
                                          Navigator.pushNamed(context, '/chat'),
                                  icon: const Icon(Icons.chat_bubble),
                                  label: const Text("Chat Healthmate.AI"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF3282F7),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Positioned(
                        right: -10,
                        bottom: 0,
                        // left: 5,
                        child: Image(
                          image: AssetImage(
                            'lib/assets/images/greet-doctor.png',
                          ),
                          width: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Our Features",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: features.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 20),
                          itemBuilder: (context, index) {
                            final feature = features[index];
                            return GestureDetector(
                              onTap: () {
                                final route = feature['route'];

                                if (route == '/bmi') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (_) =>
                                            const _FullScreenBMIPredictionPage(),
                                  );
                                } else if (route == '/doctorlist') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (_) =>
                                            const _FullScreenDoctorListPage(),
                                  );
                                } else if (route == '/appointment') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (_) =>
                                            const _FullScreenDoctorListPage(),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        feature['icon'] as IconData,
                                        color: feature['color'] as Color,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    feature['label'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Nearest Hospitals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 250,
                        child:
                            _currentPosition == null
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : FlutterMap(
                                  options: MapOptions(
                                    center: _currentPosition,
                                    zoom: 13,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      subdomains: ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers:
                                          _hospitals.map((hospital) {
                                            return Marker(
                                              width: 50,
                                              height: 50,
                                              point: LatLng(
                                                hospital['lat'],
                                                hospital['lon'],
                                              ),
                                              child: const Icon(
                                                Icons.local_hospital,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _hospitalFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Column(
                              children: List.generate(
                                5,
                                (index) => _buildShimmer(),
                              ),
                            );
                          }
                          final hospitals =
                              snapshot.data!..sort((a, b) {
                                final distA = _calculateDistance(
                                  a['lat'],
                                  a['lon'],
                                );
                                final distB = _calculateDistance(
                                  b['lat'],
                                  b['lon'],
                                );
                                return distA.compareTo(distB);
                              });
                          final visibleHospitals =
                              hospitals.take(_visibleItemCount).toList();
                          return Column(
                            children:
                                visibleHospitals.map((hospital) {
                                  final dist = _calculateDistance(
                                    hospital['lat'],
                                    hospital['lon'],
                                  );
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.local_hospital,
                                      color: Colors.redAccent,
                                    ),
                                    title: Text(hospital['name']),
                                    subtitle: Text(
                                      'Lat: ${hospital['lat']}, Lon: ${hospital['lon']}\n${dist.toStringAsFixed(2)} km from you',
                                    ),
                                    onTap: () {
                                      final lat = hospital['lat'];
                                      final lon = hospital['lon'];
                                      final url = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                                      );
                                      launchUrl(url);
                                    },
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 10,
          color: Colors.white,
        ),
        subtitle: Container(width: 150, height: 10, color: Colors.white),
      ),
    );
  }
}
