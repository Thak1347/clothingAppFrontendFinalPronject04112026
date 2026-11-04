import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});
  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  static const _defaultLocation = LatLng(11.5564, 104.9282);
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _selected = _defaultLocation;
  String _addressLine = '';
  String _province = '';
  bool _loading = false;
  bool _mapLoading = true;
  bool _mapUnavailable = false;
  bool _hasLocatedUser = false;
  int _mapRetryKey = 0;
  int _selectionRequestId = 0;
  Timer? _mapInitializationTimeout;
  String? _message;

  @override
  void initState() {
    super.initState();
    _startMapInitializationTimeout();
    unawaited(_useCurrentLocation());
  }

  void _startMapInitializationTimeout() {
    _mapInitializationTimeout?.cancel();
    _mapInitializationTimeout = Timer(const Duration(seconds: 20), () {
      if (!mounted || _mapController != null) return;
      setState(() {
        _mapLoading = false;
        _mapUnavailable = true;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapInitializationTimeout?.cancel();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() {
      _mapController = controller;
      _mapLoading = false;
      _mapUnavailable = false;
    });
    if (_hasLocatedUser) {
      unawaited(
          controller.animateCamera(CameraUpdate.newLatLngZoom(_selected, 16)));
    }
  }

  void _retryMapInitialization() {
    setState(() {
      _mapUnavailable = false;
      _mapLoading = true;
      _mapRetryKey++;
      _mapController = null;
    });
    _startMapInitializationTimeout();
  }

  void _showAddressLookupError() {
    if (mounted) {
      setState(() => _message =
          'Could not find a readable address. You can enter it manually.');
    }
  }

  Future<void> _reverseGeocode(LatLng point, {int? requestId}) async {
    if (!mounted) return;
    final lookupId = requestId ?? ++_selectionRequestId;
    setState(() {
      _selected = point;
      _loading = true;
      _message = null;
    });
    try {
      final places =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (places.isEmpty) throw StateError('No address found.');
      final place = places.first;
      final line = [place.street, place.subLocality]
          .where((part) => part != null && part.isNotEmpty)
          .join(', ');
      if (!mounted || lookupId != _selectionRequestId) return;
      setState(() {
        _addressLine = line.isEmpty ? place.name ?? '' : line;
        _province = place.administrativeArea ?? place.locality ?? '';
      });
    } on StateError {
      if (lookupId == _selectionRequestId) _showAddressLookupError();
    } on Exception {
      if (lookupId == _selectionRequestId) _showAddressLookupError();
    } finally {
      if (mounted && lookupId == _selectionRequestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || !mounted) {
      if (mounted) {
        setState(() => _message = 'Enter a place or address to search.');
      }
      return;
    }

    final requestId = ++_selectionRequestId;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final locations = await locationFromAddress(query);
      if (!mounted || requestId != _selectionRequestId) return;
      if (locations.isEmpty) {
        throw StateError('No matching location found.');
      }
      final location = locations.first;
      final point = LatLng(location.latitude, location.longitude);
      _hasLocatedUser = true;
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
      if (!mounted || requestId != _selectionRequestId) return;
      await _reverseGeocode(point, requestId: requestId);
    } on StateError {
      if (mounted && requestId == _selectionRequestId) {
        setState(
            () => _message = 'No matching location found. Try another search.');
      }
    } on Exception {
      if (mounted && requestId == _selectionRequestId) {
        setState(
            () => _message = 'Could not search for that location. Try again.');
      }
    } finally {
      if (mounted && requestId == _selectionRequestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    if (!mounted) return;
    final requestId = ++_selectionRequestId;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
            'Turn on location services or choose a point on the map.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
            'Location permission is unavailable. Choose a point on the map or enter your address manually.');
      }
      if (!mounted || requestId != _selectionRequestId) return;
      final position = await Geolocator.getCurrentPosition();
      if (!mounted || requestId != _selectionRequestId) return;
      final point = LatLng(position.latitude, position.longitude);
      _hasLocatedUser = true;
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
      await _reverseGeocode(point, requestId: requestId);
    } catch (error) {
      if (!mounted || requestId != _selectionRequestId) return;
      setState(() {
        _message = error is StateError
            ? error.message.toString()
            : 'Could not get your location. Select a point on the map.';
      });
    } finally {
      if (mounted && requestId == _selectionRequestId) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Choose delivery location')),
        body: Column(children: [
          Expanded(
            child: _mapUnavailable
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.margin),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'The map could not be initialized. Check your internet connection and Android Google Maps SDK key configuration.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: _retryMapInitialization,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      GoogleMap(
                        key: ValueKey(_mapRetryKey),
                        initialCameraPosition: const CameraPosition(
                          target: _defaultLocation,
                          zoom: 12,
                        ),
                        onMapCreated: _onMapCreated,
                        onTap: _reverseGeocode,
                        markers: {
                          Marker(
                            markerId: const MarkerId('delivery'),
                            position: _selected,
                            draggable: true,
                            onDragEnd: _reverseGeocode,
                          ),
                        },
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      Positioned(
                        top: AppSpacing.margin,
                        left: AppSpacing.margin,
                        right: AppSpacing.margin,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _searchLocation(),
                            decoration: InputDecoration(
                              hintText: 'Search for a place or address',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                tooltip: 'Search location',
                                onPressed: _loading ? null : _searchLocation,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      if (_mapLoading)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading) const LinearProgressIndicator(),
                    if (_message != null)
                      Text(_message!, style: AppTextStyles.bodySm),
                    if (_addressLine.isNotEmpty)
                      Text(
                          '$_addressLine${_province.isNotEmpty ? ', $_province' : ''}',
                          style: AppTextStyles.bodyMd),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                        onPressed: _loading ? null : _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use current location')),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                        onPressed: _addressLine.isEmpty || _province.isEmpty
                            ? null
                            : () => Navigator.pop(context, {
                                  'address_line': _addressLine,
                                  'province': _province,
                                  'latitude': _selected.latitude,
                                  'longitude': _selected.longitude
                                }),
                        child: const Text('Confirm location')),
                  ])),
        ]),
      );

  @override
  void dispose() {
    _mapInitializationTimeout?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
