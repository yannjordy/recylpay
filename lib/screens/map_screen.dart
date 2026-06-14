import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/pollution_report_model.dart';
import '../models/recycling_company_model.dart';
import '../providers/auth_provider.dart';
import '../providers/map_provider.dart';
import '../providers/market_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _showCollecteurs = true;
  bool _showTrieurs = true;
  bool _showLivreurs = true;
  bool _showPollution = true;
  bool _showRecycleurs = true;
  bool _isDarkMap = true;
  bool _showReportForm = false;

  Map<String, dynamic>? _selectedUser;
  PollutionReportModel? _selectedReport;
  RecyclingCompany? _selectedCompany;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = context.read<MapProvider>();
      mp.getCurrentLocation();
      mp.loadNearbyMissions(Constants.cameroonLat, Constants.cameroonLng);
      mp.loadPollutionReports();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUser = null;
      _selectedReport = null;
      _selectedCompany = null;
    });
  }

  void _centerOnUser() {
    final mp = context.read<MapProvider>();
    if (mp.currentPosition != null) {
      _mapController.move(mp.currentPosition!, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProv = context.watch<MapProvider>();
    final market = context.watch<MarketProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapProv.currentPosition ?? const LatLng(Constants.cameroonLat, Constants.cameroonLng),
              initialZoom: 14,
              maxZoom: 18,
              minZoom: 5,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => _clearSelection(),
            ),
            children: [
              TileLayer(
                urlTemplate: _isDarkMap
                    ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.recylpay.app',
              ),
              MarkerLayer(markers: _buildMarkers(mapProv, market)),
            ],
          ),
          _buildLegend(),
          _buildMapControls(),
          if (_selectedUser != null) _buildUserPopup(_selectedUser!),
          if (_selectedReport != null) _buildReportPopup(_selectedReport!),
          if (_selectedCompany != null) _buildCompanyPopup(_selectedCompany!),
          if (_showReportForm) _buildReportForm(),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      left: 12, bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.softBlack.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                _controlButton(
                  icon: _isDarkMap ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppColors.yellow,
                  onTap: () => setState(() => _isDarkMap = !_isDarkMap),
                ),
                Container(height: 1, color: AppColors.glassBorder.withValues(alpha: 0.3)),
                _controlButton(
                  icon: Icons.my_location_rounded,
                  color: AppColors.green,
                  onTap: _centerOnUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 12, right: 12,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.softBlack.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem('Collecteurs', AppColors.blue, false, () => setState(() => _showCollecteurs = !_showCollecteurs)),
            _legendItem('Trieurs', AppColors.yellow, false, () => setState(() => _showTrieurs = !_showTrieurs)),
            _legendItem('Livreurs', AppColors.orange, false, () => setState(() => _showLivreurs = !_showLivreurs)),
            _legendItem('Pollution', AppColors.red, false, () => setState(() => _showPollution = !_showPollution)),
            _legendItem('Recycleurs', AppColors.green, false, () => setState(() => _showRecycleurs = !_showRecycleurs)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _showReportForm = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 14),
                  SizedBox(width: 4),
                  Text('Signaler', style: TextStyle(color: AppColors.red, fontSize: 11)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color, bool bold, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: bold ? Border.all(color: Colors.white, width: 2) : null)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          if (onTap != null) ...[const SizedBox(width: 4), Icon(Icons.visibility_rounded, size: 10, color: Colors.white38)],
        ]),
      ),
    );
  }

  List<Marker> _buildMarkers(MapProvider mapProv, MarketProvider market) {
    final markers = <Marker>[];

    if (mapProv.currentPosition != null) {
      markers.add(_selfMarker(mapProv.currentPosition!));
    }
    if (_showCollecteurs) {
      for (final u in mapProv.collecteurs.take(5)) {
        markers.add(_userMarker(u, AppColors.blue));
      }
    }
    if (_showTrieurs) {
      for (final u in mapProv.trieurs.take(3)) {
        markers.add(_userMarker(u, AppColors.yellow));
      }
    }
    if (_showLivreurs) {
      for (final u in mapProv.livreurs.take(3)) {
        markers.add(_userMarker(u, AppColors.orange));
      }
    }
    if (_showPollution) {
      for (final r in mapProv.reports.take(20)) {
        markers.add(_pollutionMarker(r));
      }
    }
    if (_showRecycleurs) {
      for (final c in market.allCompanies) {
        markers.add(_recyclerMarker(c));
      }
    }
    return markers;
  }

  Marker _selfMarker(LatLng pos) {
    return Marker(
      point: pos, width: 56, height: 56,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.green, width: 4),
          boxShadow: [
            BoxShadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 18, spreadRadius: 4),
          ],
        ),
        child: const Center(child: Icon(Icons.my_location_rounded, color: Colors.white, size: 28)),
      ),
    );
  }

  Marker _userMarker(Map<String, dynamic> user, Color color) {
    final pos = LatLng(user['latitude'] as double, user['longitude'] as double);
    final isSelected = _selectedUser == user;
    return Marker(
      point: pos, width: isSelected ? 56 : 36, height: isSelected ? 56 : 36,
      child: GestureDetector(
        onTap: () => setState(() {
          _clearSelection();
          _selectedUser = user;
        }),
        child: _circle(user['photoUrl'] as String?, color, false, user['isOnline'] as bool? ?? false),
      ),
    );
  }

  Marker _pollutionMarker(PollutionReportModel r) {
    final isSelected = _selectedReport == r;
    return Marker(
      point: LatLng(r.latitude, r.longitude), width: isSelected ? 56 : 32, height: isSelected ? 56 : 32,
      child: GestureDetector(
        onTap: () => setState(() {
          _clearSelection();
          _selectedReport = r;
        }),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.red.withValues(alpha: r.isCritical ? 0.5 : 0.25),
            border: Border.all(color: AppColors.red, width: isSelected ? 4 : 2),
            boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: 0.3), blurRadius: 8)],
          ),
          child: r.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(r.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.warning_rounded, color: Colors.white, size: 16)))
              : Center(child: Icon(Icons.warning_rounded, color: Colors.white, size: isSelected ? 24 : 14)),
        ),
      ),
    );
  }

  Marker _recyclerMarker(RecyclingCompany c) {
    final isSelected = _selectedCompany == c;
    final icon = _matIcon(c.materials.isNotEmpty ? c.materials.first.name : '');
    return Marker(
      point: LatLng(c.latitude, c.longitude), width: isSelected ? 48 : 36, height: isSelected ? 48 : 36,
      child: GestureDetector(
        onTap: () => setState(() {
          _clearSelection();
          _selectedCompany = c;
        }),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.dark,
            border: Border.all(color: AppColors.green, width: isSelected ? 4 : 2),
            boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: isSelected ? 0.5 : 0.25), blurRadius: 8)],
          ),
          child: Center(child: Icon(icon, color: AppColors.green, size: isSelected ? 24 : 18)),
        ),
      ),
    );
  }

  Widget _circle(String? photoUrl, Color color, bool isSelf, bool isOnline) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: photoUrl != null ? null : AppColors.dark,
        border: Border.all(color: color, width: isSelf ? 3 : 2.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)],
        image: photoUrl != null ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) : null,
      ),
      child: photoUrl == null
          ? Center(child: Icon(isSelf ? Icons.person_rounded : Icons.person_outline_rounded, color: color, size: isSelf ? 22 : 16))
          : (isOnline
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 12, height: 12,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                  ),
                )
              : null),
    );
  }

  IconData _matIcon(String mat) {
    final m = mat.toLowerCase();
    if (m.contains('pet') || m.contains('plastique') || m.contains('pehd') || m.contains('ldpe')) return Icons.local_drink_rounded;
    if (m.contains('ferraille') || m.contains('métal') || m.contains('aluminium')) return Icons.handyman_rounded;
    if (m.contains('carton') || m.contains('papier')) return Icons.inventory_2_rounded;
    if (m.contains('verre')) return Icons.wine_bar_rounded;
    if (m.contains('organique') || m.contains('compost')) return Icons.eco_rounded;
    return Icons.recycling_rounded;
  }

  Widget _buildUserPopup(Map<String, dynamic> user) {
    final name = user['name'] as String? ?? '';
    final role = user['role'] as String? ?? '';
    final photo = user['photoUrl'] as String?;
    final online = user['isOnline'] as bool? ?? false;
    final roleLabel = role == 'collecteur' ? 'Collecteur' : role == 'trieur' ? 'Trieur' : 'Livreur';
    final roleColor = role == 'collecteur' ? AppColors.blue : role == 'trieur' ? AppColors.yellow : AppColors.orange;

    return Positioned(
      left: 12, right: 12, bottom: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 16)],
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dark,
                border: Border.all(color: roleColor, width: 2.5),
                image: photo != null ? DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover) : null,
              ),
              child: photo == null ? Icon(Icons.person_rounded, color: roleColor, size: 30) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (online) ...[const SizedBox(width: 6), Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green))],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _clearSelection,
              child: const Icon(Icons.close_rounded, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPopup(PollutionReportModel r) {
    return Positioned(
      left: 12, right: 12, bottom: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 16)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zone polluée', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (r.address != null) Text(r.address!, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(onTap: _clearSelection, child: const Icon(Icons.close_rounded, color: AppColors.grey)),
              ],
            ),
            if (r.photoUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(r.photoUrl!, height: 160, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.dark, child: const Center(child: Icon(Icons.broken_image_rounded, color: AppColors.grey)))),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.description_rounded, size: 14, color: AppColors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(r.description, style: const TextStyle(color: Colors.white70, fontSize: 13))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _severityBadge(r.severity),
                const Spacer(),
                if (r.reportCount > 1)
                  Text('${r.reportCount} signalements', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityBadge(String severity) {
    Color c;
    String label;
    switch (severity) {
      case 'critical': c = AppColors.red; label = 'Critique'; break;
      case 'high': c = AppColors.orange; label = 'Élevée'; break;
      case 'medium': c = AppColors.yellow; label = 'Moyenne'; break;
      default: c = AppColors.grey; label = 'Faible'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCompanyPopup(RecyclingCompany c) {
    return Positioned(
      left: 12, right: 12, bottom: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 16, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.recycling_rounded, color: AppColors.green, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                GestureDetector(onTap: _clearSelection, child: const Icon(Icons.close_rounded, color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(c.city, style: const TextStyle(color: AppColors.grey, fontSize: 12))),
                if (c.rating > 0) ...[const Icon(Icons.star_rounded, size: 14, color: AppColors.yellow), const SizedBox(width: 2), Text(c.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.yellow, fontSize: 12))],
              ],
            ),
            if (c.phone != null) ...[
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.phone_rounded, size: 12, color: AppColors.green), const SizedBox(width: 4), Text(c.phone!, style: const TextStyle(color: AppColors.green, fontSize: 11))]),
            ],
            if (c.materials.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: c.materials.map((m) {
                  final p = m.priceMin ?? m.priceMax;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green.withValues(alpha: 0.2))),
                    child: Text('${m.name}${p != null ? ' ${p.toInt()} FCFA/kg' : ''}${m.priceNote != null ? ' ${m.priceNote}' : ''}', style: const TextStyle(color: AppColors.green, fontSize: 10)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=${c.latitude},${c.longitude}';
                      html.window.open(url, '_blank');
                    },
                    icon: const Icon(Icons.directions_rounded, size: 16),
                    label: const Text('Itinéraire', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.green, side: const BorderSide(color: AppColors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return Positioned(
      left: 12, right: 12, bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.red),
                const SizedBox(width: 8),
                const Text('Signaler une pollution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                GestureDetector(onTap: () => setState(() => _showReportForm = false), child: const Icon(Icons.close_rounded, color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Bientôt disponible.\nSignale les dépôts sauvages, caniveaux bouchés et décharges.', style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _showReportForm = false),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    context.read<MapProvider>().stopTracking();
    _mapController.dispose();
    super.dispose();
  }
}
