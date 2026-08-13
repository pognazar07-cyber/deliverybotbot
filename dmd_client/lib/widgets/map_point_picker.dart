import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config.dart';

class PickedLocation {
  final LatLng point;
  final String label;
  const PickedLocation(this.point, this.label);
}

/// Full-screen OpenStreetMap picker: tap the map to drop a pin, or search
/// an address via Nominatim (OSM's free geocoder — no API key needed,
/// consistent with the OSRM routing the backend already relies on).
class MapPointPicker extends StatefulWidget {
  final String title;
  final LatLng? initial;

  const MapPointPicker({super.key, required this.title, this.initial});

  @override
  State<MapPointPicker> createState() => _MapPointPickerState();
}

class _MapPointPickerState extends State<MapPointPicker> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  LatLng? _selected;
  List<_SearchResult> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    if (_selected == null) {
      _tryUseCurrentLocation();
    }
  }

  Future<void> _tryUseCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = here);
      _mapController.move(here, 15);
    } catch (_) {
      // Silently fall back to the default Chisinau center.
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=6'
        '&countrycodes=md&addressdetails=0',
      );
      final resp = await http
          .get(uri, headers: {'User-Agent': 'DMD-client-app'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List;
        setState(() {
          _results = list
              .map((e) => _SearchResult(
                    LatLng(double.parse(e['lat']), double.parse(e['lon'])),
                    e['display_name'] as String,
                  ))
              .toList();
        });
      }
    } catch (_) {
      // Ignore transient geocoding failures; user can still tap the map.
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pick(LatLng point) {
    setState(() {
      _selected = point;
      _results = [];
    });
    _mapController.move(point, _mapController.camera.zoom < 14 ? 15 : _mapController.camera.zoom);
  }

  void _confirm() {
    if (_selected == null) return;
    Navigator.of(context).pop(
      PickedLocation(_selected!, '${_selected!.latitude.toStringAsFixed(5)}, ${_selected!.longitude.toStringAsFixed(5)}'),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected ?? const LatLng(AppConfig.defaultLat, AppConfig.defaultLon),
              initialZoom: 13,
              onTap: (_, point) => _pick(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.deliverymd.dmd_client',
              ),
              if (_selected != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _selected!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                  ),
                ]),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Chișinău, str. ...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (_results.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          final r = _results[i];
                          return ListTile(
                            dense: true,
                            title: Text(r.label, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              _searchController.text = r.label;
                              _pick(r.point);
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: FilledButton(
              onPressed: _selected == null ? null : _confirm,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final LatLng point;
  final String label;
  const _SearchResult(this.point, this.label);
}
