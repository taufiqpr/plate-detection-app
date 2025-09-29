import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  var plate = RxnString();
  var kendaraan = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var isError = false.obs;

  final picker = ImagePicker();

  Future<void> pickAndUpload() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    isLoading.value = true;
    try {
      const baseUrl = "http://127.0.0.1";
      var uri = Uri.parse("$baseUrl/detect");
      var request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("file", pickedFile.path),
      );

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data["plate"] != null &&
            data["plate"].toString().trim().isNotEmpty) {
          plate.value = data["plate"];

          final match = data["match"];

          if (match is Map && match.containsKey("nama_pemilik")) {
            kendaraan.value = Map<String, dynamic>.from(match);
            isError.value = false;
          } else {
            kendaraan.value = {
              "nama_pemilik": null,
              "no_mesin": null,
              "no_rangka": null,
              "no_plat": null,
              "jenis_kendaraan": null,
              "status": "Kendaraan Tidak Terdaftar",
            };
            isError.value = true;
          }
        } else {
          plate.value = "Tidak ada plat";
          kendaraan.value = null;
          isError.value = true;
        }
      } else {
        plate.value = "Error: ${res.statusCode}";
        kendaraan.value = null;
        isError.value = true;
      }
    } catch (e) {
      plate.value = "Error: $e";
      kendaraan.value = null;
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
