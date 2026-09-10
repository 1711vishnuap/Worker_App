// lib/screens/customer/add_work_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/category_model.dart';
import '../../providers/work_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

class AddWorkScreen extends StatefulWidget {
  const AddWorkScreen({super.key});

  @override
  State<AddWorkScreen> createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationService = LocationService();
  final _picker = ImagePicker();

  XFile? _photo;
  double? _lat;
  double? _lng;
  bool _locatingInProgress = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureLocation());
  }

  Future<void> _captureLocation() async {
    setState(() => _locatingInProgress = true);
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _lat = result.position?.latitude;
      _lng = result.position?.longitude;
      _locatingInProgress = false;
    });
    if (result.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (photo != null) setState(() => _photo = photo);
  }

  Future<void> _submit(CategoryModel category) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the work')),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available yet, please wait or retry')),
      );
      return;
    }

    setState(() => _submitting = true);

    // NOTE: photo upload to cloud storage (S3/Cloudinary/etc.) is out of
    // scope for this MVP. photoUrl is left null here — wire up a real
    // upload step later and pass the resulting URL through.
    final success = await context.read<WorkProvider>().createWork(
          categoryId: category.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          photoUrl: null,
          lat: _lat!,
          lng: _lng!,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      final work = context.read<WorkProvider>().currentWork!;
      Navigator.pushReplacementNamed(context, AppRoutes.workTracking, arguments: work.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<WorkProvider>().errorMessage ?? 'Failed to post work')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as CategoryModel;

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(controller: _titleController, label: 'Work title', hint: 'e.g. Fan not working'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'Describe the issue in a bit more detail',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Photo
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _photo == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 32),
                            SizedBox(height: 8),
                            Text('Add a photo (optional)', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(_photo!.path), fit: BoxFit.cover, width: double.infinity),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Location status
              Row(
                children: [
                  Icon(
                    _locatingInProgress ? Icons.gps_not_fixed : Icons.gps_fixed,
                    size: 18,
                    color: _locatingInProgress ? AppColors.textSecondary : AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locatingInProgress
                          ? 'Getting your current location...'
                          : (_lat != null ? 'Location captured' : 'Location unavailable — tap to retry'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  if (!_locatingInProgress && _lat == null)
                    TextButton(onPressed: _captureLocation, child: const Text('Retry')),
                ],
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Submit Work',
                isLoading: _submitting,
                onPressed: () => _submit(category),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
