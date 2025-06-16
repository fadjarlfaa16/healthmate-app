import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenStreetHospitalService {
  Future<List<Map<String, dynamic>>> getNearbyHospitals(double lat, double lng,
      {int radius = 5000}) async {
    final overpassUrl =
        'https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="hospital"](around:$radius,$lat,$lng);out;';

    final response = await http.get(Uri.parse(overpassUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final elements = data['elements'] as List<dynamic>;

      return elements
          .map((e) => {
                'name': e['tags']?['name'] ?? 'Unnamed Hospital',
                'lat': e['lat'],
                'lon': e['lon'],
              })
          .toList();
    } else {
      throw Exception('Failed to fetch hospitals from Overpass API');
    }
  }
}
