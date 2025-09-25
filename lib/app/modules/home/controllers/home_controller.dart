import 'dart:io';
import 'dart:convert'; // ⬅️ penting buat decode JSON
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  var plate = "".obs;
  var isLoading = false.obs;

  final picker = ImagePicker();

  Future<void> pickAndUpload() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    isLoading.value = true;
    try {
      var uri = Uri.parse("http://192.168.0.24:5000/detect");
      var request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("file", pickedFile.path),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();

        final data = jsonDecode(body);

        plate.value = data["plate"] ?? "Tidak ada hasil";
      } else {
        plate.value = "Error: ${response.statusCode}";
      }
    } catch (e) {
      plate.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
