import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:updated_smart_home/screans/dashed_border.dart';

class UploadContractPage extends StatefulWidget {
  const UploadContractPage({super.key});

  @override
  _UploadContractPageState createState() => _UploadContractPageState();
}

class _UploadContractPageState extends State<UploadContractPage> {
  String? _filePath;
  bool _isFileSelected = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'pdf'],
    );

    if (result != null) {
      // التحقق من صيغة الملف
      String fileExtension = result.files.single.extension?.toLowerCase() ?? '';
      List<String> allowedExtensions = ['png', 'jpg', 'pdf'];
      if (!allowedExtensions.contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported file format.')),
        );
        return;
      }

      // التحقق من حجم الملف (5 MB = 5,242,880 bytes)
      int fileSize = result.files.single.size;
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File exceeds max size (5 MB).')),
        );
        return;
      }

      // إذا كانت الصيغة والحجم صحيحين، بنحدث الحالة
      setState(() {
        _filePath = result.files.single.name;
        _isFileSelected = true;
      });
      print('File picked: ${result.files.single.path}');
    }
  }

  Future<void> _submitFile() async {
    if (_filePath != null) {
      setState(() {
        _isFileSelected = false;
        _filePath = null; // إعادة تعيين الملف بعد الإرسال
      });
      // Placeholder لتخزين الملف في قاعدة البيانات
      // await saveToDatabase(_filePath!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File submitted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a contract to continue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 85,
              color: Color(0xFF232344),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload Ownership Contract',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Please upload a copy of your home contract to\n complete verification.\n Your contract will only be used for verification\n purposes and kept secure.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            DashedBorder(
              color: Colors.black,
              strokeWidth: 1.0,
              gap: 5.0,
              child: Container(
                height: 250,
                width: 250,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _filePath != null ? _filePath! : 'Drag & Drop',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    if (_filePath == null) const SizedBox(height: 5),
                    if (_filePath == null)
                      const Text(
                        'Supported Format Files',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.green),
                            Positioned(
                              top: 5,
                              child: Text(
                                'PNG',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.orange),
                            Positioned(
                              top: 5,
                              child: Text(
                                'JPG',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Supported format: PDF, JPG, PNG',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Max size: 5 MB',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5857AA),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Browse',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFileSelected
                  ? _submitFile
                  : null, // معطل لو مفيش ملف
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFileSelected
                    ? const Color(0xFF5857AA)
                    : Colors.grey[400],
                foregroundColor: _isFileSelected ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
