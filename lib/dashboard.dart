// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html; // for drag & drop in Flutter Web
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'starry_background.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showUploadBox = false;
  bool isDragging = false;
  html.File? selectedFile;
  String? fileName;

  void _toggleUploadBox() {
    setState(() {
      showUploadBox = !showUploadBox;
    });
  }

  void _setupDragDrop() {
    html.document.body!.addEventListener('dragover', (event) {
      event.preventDefault();
      if (showUploadBox) setState(() => isDragging = true);
    });

    html.document.body!.addEventListener('dragleave', (event) {
      event.preventDefault();
      if (showUploadBox) setState(() => isDragging = false);
    });

    html.document.body!.addEventListener('drop', (event) {
      event.preventDefault();
      if (!showUploadBox) return;

      final html.DataTransfer? data = (event as html.MouseEvent).dataTransfer;
      final files = data?.files;
      if (files != null && files.isNotEmpty) {
        selectedFile = files[0];
        fileName = files[0].name;
        _toggleUploadBox(); // close overlay
        _uploadFileToSupabase(selectedFile!);
        analyzeWithGemini(selectedFile!);
      }
    });
  }

  Future<Uint8List> _readFile(html.File file) {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  Future<void> analyzeWithGemini(html.File file) async {
    final bytes = await _readFile(file);
    final base64Image = base64Encode(bytes);

    // Build request body in the documented format
    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Which constellation is this in the picture? Just give the name, no details.",
            },
            {
              "inline_data": {
                "mime_type": file.type, // e.g. "image/png"
                "data": base64Image,
              },
            },
          ],
        },
      ],
      "generationConfig": {
        "thinkingConfig": {"thinkingBudget": 0},
      },
    };

    final response = await http.post(
      Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
      ),
      headers: {
        "x-goog-api-key": "AIzaSyAtKBs-tRVZZp4I42owbsnPg59kKX1Snjc",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final outputText = result["candidates"][0]["content"]["parts"][0]["text"];

      // append output to Firestore array
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "constellation": FieldValue.arrayUnion([outputText]),
      }, SetOptions(merge: true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Some error occurred")));
    }
  }

  Future<void> saveImageToFirestore(String downloadUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Not logged in

    final userId = user.uid;

    final docRef = FirebaseFirestore.instance.collection("users").doc(userId);

    await docRef.set({
      "images": FieldValue.arrayUnion([downloadUrl]), // create or append
    }, SetOptions(merge: true)); // merge ensures existing data is kept
  }

  Future<void> _uploadFileToSupabase(html.File file) async {
    final bytes = await _readFile(file);

    final fileNameUnique =
        "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
    final storage = Supabase.instance.client.storage.from('images');

    try {
      // Upload returns the path as a String
      final path = await storage.uploadBinary(
        fileNameUnique,
        bytes,
        fileOptions: FileOptions(cacheControl: '3600', upsert: false),
      );
      // Get public URL directly
      final publicUrl = storage.getPublicUrl(
        path.replaceFirst(RegExp(r'^images/'), ''),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully!")),
      );

      saveImageToFirestore(publicUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload error: $e")));
    }
  }

  void _pickFile() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files!.first;
      _toggleUploadBox(); // close overlay
      _uploadFileToSupabase(file);
      analyzeWithGemini(file);
    });
  }

  @override
  void initState() {
    super.initState();
    _setupDragDrop();
  }

  @override
  Widget build(BuildContext context) {
    return StarryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.7),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text("Celestia Gallery"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _toggleUploadBox,
            ),
            const SizedBox(width: 8,),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 43, 43, 43),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        // inside your _DashboardPageState build method's body Stack
        body: Stack(
          children: [
            // GridView of cards
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final doc = snapshot.data!;
                final images = List<String>.from(doc['images'] ?? []);
                final constellations = List<String>.from(
                  doc['constellation'] ?? [],
                );
                if (images.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Add your first image by clicking the + icon",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ); //Show a text at the center saying Try adding images
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100, // reduce from 300 so it adapts better
                    vertical: 50,
                  ),
                  child: GridView.builder(
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              300, // each card won't shrink below ~300px
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1, // keep square-ish
                        ),
                    itemBuilder: (context, index) {
                      final imageUrl = images[index];
                      final text = index < constellations.length
                          ? constellations[index]
                          : 'Analyzing..';
                      return Card(
                        color: const Color.fromARGB(255, 45, 45, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Overlay file upload box
            if (showUploadBox)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 400,
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 80,
                          color: isDragging ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          fileName != null
                              ? "Selected file: $fileName"
                              : "Drag & drop an image here\nor click below to upload",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Choose File"),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _toggleUploadBox,
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
