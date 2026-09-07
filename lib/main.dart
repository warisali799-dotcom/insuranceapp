import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TPLInspectionApp());
}

class TPLInspectionApp extends StatelessWidget {
  const TPLInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TPL Insurance Inspection',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const InspectorPortalScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InspectorPortalScreen extends StatefulWidget {
  const InspectorPortalScreen({super.key});

  @override
  State<InspectorPortalScreen> createState() => _InspectorPortalScreenState();
}

class _InspectorPortalScreenState extends State<InspectorPortalScreen> {
  final _vehicleNoController = TextEditingController();
  final _adminEmailController = TextEditingController(text: 'admin@tplinsurance.com');
  final List<XFile> _capturedImages = [];

  Future<void> _captureLivePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _capturedImages.add(image);
      });
    }
  }

  void _sendReportViaEmail() async {
    if (_vehicleNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Vehicle Registration Number')),
      );
      return;
    }

    if (_capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture at least one live vehicle photo')),
      );
      return;
    }

    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    String emailBody = '''
TPL Insurance Field Inspection Report
-------------------------------------
Vehicle No: ${_vehicleNoController.text.trim()}
Inspection Time: $currentTime
Total Live Photos Attached: ${_capturedImages.length}
-------------------------------------
Please find the attached live captured vehicle verification photos.
''';

    await Share.shareXFiles(
      _capturedImages,
      text: emailBody,
      subject: 'Inspection Report - Vehicle: ${_vehicleNoController.text.trim()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TPL Live Inspector Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Vehicle Inspection Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _vehicleNoController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Registration Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adminEmailController,
                decoration: const InputDecoration(
                  labelText: 'Admin Email for Report',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _captureLivePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Live Vehicle Photo (No Gallery)'),
              ),
              const SizedBox(height: 10),
              Text(
                'Live Photos Captured: ${_capturedImages.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _sendReportViaEmail,
                child: const Text(
                  'Send Report & Photos via Email to Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
