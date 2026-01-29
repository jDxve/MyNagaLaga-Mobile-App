import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/drop_down.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import 'map_location_picker.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  double? _latitude;
  double? _longitude;

  final List<String> _categories = [
    'Infrastructure',
    'Utilities',
    'Public Safety',
    'Health Services',
    'Environmental Issue',
    'Others',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _addressController.text = address;
              _latitude = lat;
              _longitude = lng;
            });
          },
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem')),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on map')),
      );
      return;
    }

    // TODO: Submit complaint with all data including lat/lng
    print('Category: ${_categoryController.text}');
    print('Description: ${_descriptionController.text}');
    print('Address: ${_addressController.text}');
    print('Latitude: $_latitude');
    print('Longitude: $_longitude');
    print('Has Image: ${_selectedImage != null}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'File a Complaint'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Complaint Category'),
              8.gapH,
              Dropdown(
                controller: _categoryController,
                hintText: 'Select Category',
                items: _categories,
              ),
              20.gapH,
              _buildLabel('State Your Problem'),
              8.gapH,
              TextInput(
                controller: _descriptionController,
                hintText: 'Please describe the issue you\'re experiencing in details...',
                maxLines: 6,
              ),
              20.gapH,
              _buildLabel('Address / Nearest Landmark'),
              8.gapH,
              GestureDetector(
                onTap: _openMapPicker,
                child: AbsorbPointer(
                  child: TextInput(
                    controller: _addressController,
                    hintText: 'Tap to select location on map',
                    suffixIcon: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              20.gapH,
              _buildLabel('Upload Image (Optional)'),
              8.gapH,
              UploadImage(
                image: _selectedImage,
                title: 'Add Photo',
                subtitle: 'Tap to take or upload photo',
                height: 180.h,
                onRemove: _removeImage,
                onPickImage: _pickImage,
                showActions: true,
                iconBackgroundColor: AppColors.lightPrimary,
                iconColor: AppColors.primary,
              ),
              40.gapH,
              PrimaryButton(
                text: 'Submit Complaint',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.medium,
        color: AppColors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}