import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Current Position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  // Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print('🔍 Getting address for: $latitude, $longitude');
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'en',
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build a more readable address
        final addressParts = <String>[];
        
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        final address = addressParts.join(', ');
        print('📍 Address: $address');
        return address.isNotEmpty ? address : 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('❌ Error getting address: $e');
      return 'Location unavailable';
    }
  }

  // Validate an address by geocoding it
  static Future<Map<String, dynamic>?> validateAndGeocodeAddress(
    String address,
  ) async {
    try {
      print('🔍 Validating address: $address');
      
      // Try to get coordinates from the address
      final locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        print('❌ Address not found');
        return null;
      }

      final location = locations.first;
      
      // Reverse geocode to get the standardized address
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        print('❌ Could not verify address');
        return null;
      }

      final place = placemarks.first;
      final standardizedAddress = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      print('✅ Valid address: $standardizedAddress');
      print('📍 Coordinates: ${location.latitude}, ${location.longitude}');

      return {
        'isValid': true,
        'address': standardizedAddress,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'locality': place.locality ?? '',
        'administrativeArea': place.administrativeArea ?? '',
        'country': place.country ?? '',
      };
    } catch (e) {
      print('❌ Error validating address: $e');
      return {
        'isValid': false,
        'error': 'Invalid or unrecognized address',
      };
    }
  }

  // Get current location with address
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address == null) return null;

      return {
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('❌ Error getting current location with address: $e');
      return null;
    }
  }
}
