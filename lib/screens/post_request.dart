import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/image_upload_service.dart';
import '../services/help_request_api_service.dart';
import '../services/user_api_service.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool anonymous = false;
  String? category = 'Food';
  String urgency = 'Medium';
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _uploadedImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      final imageUrl = await ImageUploadService.uploadSingleImage(_selectedImage!);
      
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
          _isUploading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('🔵 Creating help request for user: ${currentUser.uid}');
      
      // Ensure user exists in MongoDB
      try {
        await UserApiService.createOrUpdateUser(
          firebaseUid: currentUser.uid,
          email: currentUser.email ?? '',
          username: currentUser.displayName ?? 'User',
          mobile: currentUser.phoneNumber ?? '',
        );
        print('✅ User synced to MongoDB');
      } catch (e) {
        print('⚠️ Failed to sync user: $e');
      }
      
      final result = await HelpRequestApiService.createHelpRequest(
        firebaseUid: currentUser.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: category ?? 'Other',
        urgency: urgency,
        location: {
          'address': _locationController.text.trim(),
          'coordinates': [0.0, 0.0],
        },
      );

      setState(() => _isSubmitting = false);

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _uploadedImageUrl != null
                    ? '✅ Request posted with image! +2 karma earned'
                    : '✅ Request posted! +2 karma earned',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: 0,
          );
        }
      } else {
        throw Exception('Server returned null response');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);

      print('🔴 Error submitting request: $e');

      String errorMessage = 'Error creating post';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Is the backend running?';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User sync failed. Try logging out and back in.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.85, 1.0);

          return ListView(
            padding: EdgeInsets.all(12 * scale),
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 12 * scale),
                decoration: BoxDecoration(color: AppTheme.warmGradient.colors.first, borderRadius: BorderRadius.circular(6)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)), SizedBox(width: 8 * scale), Text('Post Help Request', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale))]),
                  SizedBox(height: 6 * scale),
                  Text('Let the community know how they can help', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale)),
                ]),
              ),
              SizedBox(height: 12 * scale),
              Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Title *'),
                  SizedBox(height: 6 * scale),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'E.g., Need food supplies for elderly neighbor',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please fill out this field.' : null,
                  ),
                  SizedBox(height: 12 * scale),
                  Text('Description *'),
                  SizedBox(height: 6 * scale),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Provide details about what help you need...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 6,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please fill out this field.' : null,
                  ),
                  SizedBox(height: 12 * scale),
                  Text('Category *'),
                  SizedBox(height: 6 * scale),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['Food', 'Books', 'Clothes', 'Medical', 'Elderly Care', 'Education', 'Emergency', 'Other']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => category = v),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white),
                  ),
                  SizedBox(height: 12 * scale),
                  Text('Urgency Level'),
                  SizedBox(height: 8 * scale),
                  Row(children: [
                    Expanded(child: ChoiceChip(label: const Text('High Priority'), selected: urgency == 'High', selectedColor: AppTheme.destructive, onSelected: (_) => setState(() => urgency = 'High'))),
                    SizedBox(width: 8 * scale),
                    Expanded(child: ChoiceChip(label: const Text('Medium'), selected: urgency == 'Medium', selectedColor: Color.fromARGB(255, 255, 244, 196), onSelected: (_) => setState(() => urgency = 'Medium'))),
                    SizedBox(width: 8 * scale),
                    Expanded(child: ChoiceChip(label: const Text('Low Priority'), selected: urgency == 'Low', selectedColor: AppTheme.success, onSelected: (_) => setState(() => urgency = 'Low'))),
                  ]),
                  SizedBox(height: 12 * scale),
                  Text('Location *'),
                  SizedBox(height: 6 * scale),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'E.g., Downtown area, Street name...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please fill out this field.' : null,
                  ),
                  SizedBox(height: 12 * scale),
                  
                  // Image Upload Section
                  Text('Add Photo (Optional)'),
                  SizedBox(height: 8 * scale),
                  if (_selectedImage == null)
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Select Image'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        backgroundColor: Colors.white,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200 * scale,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isUploading ? null : _uploadImage,
                                icon: _isUploading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        _uploadedImageUrl != null
                                            ? Icons.check_circle
                                            : Icons.cloud_upload,
                                        size: 18,
                                      ),
                                label: Text(
                                  _uploadedImageUrl != null ? 'Uploaded' : 'Upload',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _uploadedImageUrl != null
                                      ? Colors.green
                                      : AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 18 * scale),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    )),
                    SizedBox(width: 12 * scale),
                    Expanded(child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warmGradient.colors.first,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.send),
                                SizedBox(width: 8),
                                Text('Submit Request'),
                              ],
                            ),
                    )),
                  ])
                ]),
              )
            ],
          );
        }),
      ),
      bottomNavigationBar: const SizedBox(height: 0),
    ),
    );
  }
}
