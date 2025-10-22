import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';

class ImageUploadService {
  // Upload single image
  static Future<String?> uploadSingleImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/single'),
      );

      // Add image file
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonData['data']['url'] as String;
      } else {
        print('Error uploading image: ${jsonData['message']}');
        return null;
      }
    } catch (e) {
      print('Error in uploadSingleImage: $e');
      return null;
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/multiple'),
      );

      // Add all image files
      for (var imageFile in imageFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonData['data'];
        return data.map((item) => item['url'] as String).toList();
      } else {
        print('Error uploading images: ${jsonData['message']}');
        return [];
      }
    } catch (e) {
      print('Error in uploadMultipleImages: $e');
      return [];
    }
  }
}
