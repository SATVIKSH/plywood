import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

import 'package:plywood_project/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Uploader',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final imageFile = useState<File?>(null);
    final widthController = useTextEditingController();
    final isUploading = useState<bool>(false);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    }

    Future<void> uploadImage() async {
      if (imageFile.value == null || widthController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select an image and enter a width"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        isUploading.value = true;
        var uri = Uri.parse("https://fast-api-5dm5.onrender.com/process"); //

        var request = http.MultipartRequest('POST', uri);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // 🔥 This should match the API's expected key
            imageFile.value!.path,
            filename: basename(imageFile.value!.path),
          ),
        );

        request.fields['image_width_feet'] = widthController.text;

        // Add headers if required
        request.headers.addAll({"Content-Type": "multipart/form-data"});

        var response = await request.send().timeout(
          const Duration(seconds: 300), // ⏳ Set timeout duration
          onTimeout: () {
            throw TimeoutException("The request timed out. Please try again.");
          },
        );
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);

        isUploading.value = false;

        // Show response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Response: ${decodedResponse.toString()}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(responseData: decodedResponse),
          ),
        );

        print("Response: $decodedResponse");
      } catch (e) {
        isUploading.value = false;
        print("Upload failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Image',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF292D3E),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white54, width: 1.5),
                    ),
                    child: imageFile.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child:
                                Image.file(imageFile.value!, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo,
                                color: Colors.white60, size: 40),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter Width",
                    labelStyle: GoogleFonts.poppins(color: Colors.white60),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    prefixIcon:
                        const Icon(Icons.width_full, color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isUploading.value ? null : uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isUploading.value ? Colors.grey : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isUploading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Upload",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
