import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/pollution_report_model.dart';
import '../models/mission_model.dart';
import 'api_service.dart';

class MapService {
  final ApiService _api = ApiService();

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('La localisation est désactivée');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Stream<Position> trackLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const p = pi / 180;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<PollutionReportModel>> getPollutionReports() async {
    final response = await _api.get('/pollution-reports');
    final data = response.data as List;
    return data
        .map((e) => PollutionReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PollutionReportModel> reportPollution(PollutionReportModel report) async {
    final response = await _api.post('/pollution-reports', data: report.toJson());
    return PollutionReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MissionModel>> getNearbyMissions(double lat, double lng, {double radiusKm = 10}) async {
    final response = await _api.get('/missions/nearby', params: {
      'latitude': lat,
      'longitude': lng,
      'radius': radiusKm,
    });
    final data = response.data as List;
    return data.map((e) => MissionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<List<Map<String, dynamic>>> clusterPoints(
    List<Map<String, dynamic>> points,
    double zoom,
  ) {
    if (points.isEmpty) return [];
    final clusterRadius = 50 / zoom;
    final clusters = <List<Map<String, dynamic>>>[];
    final used = <int>{};

    for (int i = 0; i < points.length; i++) {
      if (used.contains(i)) continue;
      final cluster = <Map<String, dynamic>>[points[i]];
      used.add(i);

      for (int j = i + 1; j < points.length; j++) {
        if (used.contains(j)) continue;
        final dist = calculateDistance(
          points[i]['latitude'] as double,
          points[i]['longitude'] as double,
          points[j]['latitude'] as double,
          points[j]['longitude'] as double,
        );
        if (dist < clusterRadius) {
          cluster.add(points[j]);
          used.add(j);
        }
      }
      clusters.add(cluster);
    }
    return clusters;
  }
}
