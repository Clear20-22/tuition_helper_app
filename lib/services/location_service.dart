import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_model.dart';
import 'storage_service.dart';
import 'database_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  
  static const double _defaultRadius = 100.0; // meters

  // Initialize location service
  Future<void> initialize() async {
    await _requestLocationPermission();
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return _currentPosition;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Start location tracking
  Future<void> startLocationTracking() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _onLocationUpdate(position);
        },
        onError: (error) {
          print('Location tracking error: $error');
        },
      );
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // Handle location updates
  void _onLocationUpdate(Position position) {
    // Check if user is near any saved locations
    _checkNearbyLocations(position);
  }

  // Check if user is near any saved locations
  Future<void> _checkNearbyLocations(Position currentPosition) async {
    final savedLocations = _storageService.getActiveLocations();
    
    for (final location in savedLocations) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= _defaultRadius) {
        _onLocationEntered(location, distance);
      }
    }
  }

  // Handle location entered
  void _onLocationEntered(LocationModel location, double distance) {
    print('Entered location: ${location.name} (${distance.toStringAsFixed(2)}m away)');
    // You can add notification logic here
  }

  // Calculate distance between two locations
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get formatted address from coordinates
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'Unknown location';
  }

  // Get coordinates from address
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      print('Error getting coordinates: $e');
      return [];
    }
  }

  // Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode?.isNotEmpty == true) {
      parts.add(placemark.postalCode!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  // Save current location as a favorite
  Future<void> saveCurrentLocation({
    required String name,
    String? description,
    String? contactNumber,
  }) async {
    final position = await getCurrentPosition();
    if (position == null) {
      throw Exception('Unable to get current location');
    }

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final location = LocationModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
      description: description,
      contactNumber: contactNumber,
    );

    await _storageService.saveLocation(location);
    await _databaseService.insertLocation(location);
  }

  // Save location with coordinates
  Future<void> saveLocation({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? contactNumber,
  }) async {
    final address = await getAddressFromCoordinates(latitude, longitude);

    final location = LocationModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      contactNumber: contactNumber,
    );

    await _storageService.saveLocation(location);
    await _databaseService.insertLocation(location);
  }

  // Get all saved locations
  List<LocationModel> getAllLocations() {
    return _storageService.getAllLocations();
  }

  // Get active locations
  List<LocationModel> getActiveLocations() {
    return _storageService.getActiveLocations();
  }

  // Update location
  Future<void> updateLocation(LocationModel location) async {
    await _storageService.saveLocation(location);
    await _databaseService.updateLocation(location);
  }

  // Delete location
  Future<void> deleteLocation(String id) async {
    await _storageService.deleteLocation(id);
    await _databaseService.deleteLocation(id);
  }

  // Get nearby locations
  List<LocationModel> getNearbyLocations({
    Position? position,
    double radiusInMeters = 1000,
  }) {
    final currentPos = position ?? _currentPosition;
    if (currentPos == null) return [];

    final allLocations = getAllLocations();
    final nearbyLocations = <LocationModel>[];

    for (final location in allLocations) {
      final distance = calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= radiusInMeters) {
        nearbyLocations.add(location);
      }
    }

    // Sort by distance
    nearbyLocations.sort((a, b) {
      final distanceA = calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyLocations;
  }

  // Check if user is at a specific location
  Future<bool> isAtLocation(LocationModel location, {double radiusInMeters = 100}) async {
    final currentPosition = await getCurrentPosition();
    if (currentPosition == null) return false;

    final distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      location.latitude,
      location.longitude,
    );

    return distance <= radiusInMeters;
  }

  // Get location by name
  LocationModel? getLocationByName(String name) {
    final locations = getAllLocations();
    try {
      return locations.firstWhere(
        (location) => location.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Search locations
  List<LocationModel> searchLocations(String query) {
    final locations = getAllLocations();
    final lowerQuery = query.toLowerCase();
    
    return locations.where((location) {
      return location.name.toLowerCase().contains(lowerQuery) ||
             location.address.toLowerCase().contains(lowerQuery) ||
             (location.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get location statistics
  Map<String, dynamic> getLocationStats() {
    final locations = getAllLocations();
    final activeLocations = getActiveLocations();
    
    return {
      'totalLocations': locations.length,
      'activeLocations': activeLocations.length,
      'inactiveLocations': locations.length - activeLocations.length,
    };
  }

  // Export locations to JSON
  List<Map<String, dynamic>> exportLocations() {
    final locations = getAllLocations();
    return locations.map((location) => location.toJson()).toList();
  }

  // Import locations from JSON
  Future<void> importLocations(List<Map<String, dynamic>> locationsData) async {
    for (final locationData in locationsData) {
      final location = LocationModel.fromJson(locationData);
      await _storageService.saveLocation(location);
      await _databaseService.insertLocation(location);
    }
  }

  // Get current position as LocationModel
  Future<LocationModel?> getCurrentLocationModel({
    required String name,
    String? description,
  }) async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return LocationModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
      description: description,
    );
  }

  // Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
