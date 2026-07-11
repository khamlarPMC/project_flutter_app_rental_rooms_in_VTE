import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_constants.dart';

class PhotoPickerWidget extends StatefulWidget {
  final List<XFile> initialImages;
  final List<String> existingImageUrls;
  final Function(List<XFile> selected, List<String> removed) onImagesChanged;
  final int maxImages;

  const PhotoPickerWidget({
    super.key,
    required this.onImagesChanged,
    this.initialImages = const [],
    this.existingImageUrls = const [],
    this.maxImages = 4,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  late List<XFile> _selectedImages;
  late List<String> _currentExistingUrls;
  final List<String> _removedUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImages = List.from(widget.initialImages);
    _currentExistingUrls = List.from(widget.existingImageUrls);
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      debugPrint('PhotoPicker: pickedImages raw => $pickedImages');
      if (pickedImages.isNotEmpty) {
        final int remainingSlots =
            widget.maxImages -
            (_selectedImages.length + _currentExistingUrls.length);

        if (pickedImages.length > remainingSlots && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only add up to ${widget.maxImages} photos. Extra photos were ignored.',
              ),
            ),
          );
        }

        setState(() {
          if (remainingSlots > 0) {
            _selectedImages.addAll(pickedImages.take(remainingSlots));
          }
        });
        widget.onImagesChanged(_selectedImages, _removedUrls);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesChanged(_selectedImages, _removedUrls);
  }

  void _removeExistingImage(int index) {
    setState(() {
      final removed = _currentExistingUrls.removeAt(index);
      _removedUrls.add(removed);
    });
    widget.onImagesChanged(_selectedImages, _removedUrls);
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = _selectedImages.length + _currentExistingUrls.length;

    if (totalCount == 0) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add up to ${widget.maxImages} photos',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalCount < widget.maxImages
                  ? totalCount + 1
                  : totalCount,
              itemBuilder: (context, index) {
                if (index == totalCount && totalCount < widget.maxImages) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                }

                // Show existing images first
                if (index < _currentExistingUrls.length) {
                  return _buildImageItem(
                    index: index,
                    isExisting: true,
                    imageUrl: _currentExistingUrls[index],
                  );
                }

                // Show newly selected images
                final selectedIndex = index - _currentExistingUrls.length;
                return _buildImageItem(
                  index: selectedIndex,
                  isExisting: false,
                  file: File(_selectedImages[selectedIndex].path),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalCount / ${widget.maxImages} photos selected',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      );
    }
  }

  Widget _buildImageItem({
    required int index,
    required bool isExisting,
    String? imageUrl,
    File? file,
  }) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundField,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isExisting
                  ? (imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            placeholder: (context, url) => Container(
                              color: AppColors.backgroundField,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundField,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.textSecondary,
                                  size: 36,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            color: AppColors.backgroundField,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                              size: 36,
                            ),
                          ))
                  : Image.file(
                      file!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 16,
            child: GestureDetector(
              onTap: () => isExisting
                  ? _removeExistingImage(index)
                  : _removeSelectedImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
