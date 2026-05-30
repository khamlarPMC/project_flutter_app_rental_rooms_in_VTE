import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/photo_picker_widget.dart';
import '../models/room_model.dart';
import '../models/address_model.dart';
import '../models/amenity_model.dart';
import '../services/room_service.dart';
import '../utils/district_villages.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;

  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoomService _roomService = RoomService();
  bool _isLoading = false;

  // Photo state
  List<XFile> _selectedImages = [];
  final List<String> _removedImageUrls = [];

  // Amenity state
  List<Amenity> _allAmenities = [];
  List<int> _selectedAmenityIds = [];
  bool _isLoadingAmenities = true;
  int? _selectedAmenityDropdownValue;

  // Form fields
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  late String _selectedDistrict;
  late String _selectedVillage;

  @override
  void initState() {
    super.initState();
    final room = widget.room;

    _titleController = TextEditingController(text: room.roomName);
    _priceController = TextEditingController(
      text: room.pricePerMonth.toStringAsFixed(0),
    );
    _descriptionController = TextEditingController(
      text: room.description ?? '',
    );

    // Initialize district and village defaults
    _selectedDistrict = districtVillages.keys.first;
    _selectedVillage = districtVillages[_selectedDistrict]!.first;

    if (room.address != null) {
      final district = room.address!.district;
      if (district != null && districtVillages.containsKey(district)) {
        _selectedDistrict = district;

        final village = room.address!.village;
        if (village != null && districtVillages[_selectedDistrict]!.contains(village)) {
          _selectedVillage = village;
        }
      }
    }

    // Initialize selected amenities
    if (room.amenities != null) {
      _selectedAmenityIds = room.amenities!.map((a) => a.amenityId!).toList();
    }

    _fetchAmenities();
  }

  Future<void> _fetchAmenities() async {
    setState(() => _isLoadingAmenities = true);
    try {
      final amenities = await _roomService.getAmenities();
      setState(() {
        _allAmenities = amenities;
        _isLoadingAmenities = false;
      });
    } catch (e) {
      setState(() => _isLoadingAmenities = false);
      print('Error fetching amenities: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedRoom = Room(
        roomName: _titleController.text,
        pricePerMonth: double.parse(_priceController.text),
        description: _descriptionController.text,
        roomStatus: widget.room.roomStatus,
        address: Address(
          village: _selectedVillage,
          district: _selectedDistrict,
          province: widget.room.address?.province ?? 'Vientiane',
        ),
      );

      final result = await _roomService.updateRoom(
        widget.room.roomId!,
        updatedRoom,
        _selectedImages,
        _removedImageUrls,
        _selectedAmenityIds,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update room');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard: ensure _selectedDistrict and _selectedVillage are always valid
    if (!districtVillages.containsKey(_selectedDistrict)) {
      _selectedDistrict = districtVillages.keys.first;
      _selectedVillage = districtVillages[_selectedDistrict]!.first;
    } else if (!districtVillages[_selectedDistrict]!.contains(_selectedVillage)) {
      _selectedVillage = districtVillages[_selectedDistrict]!.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Room'),
        backgroundColor: const Color(0xFF3B5998),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo Section
                    PhotoPickerWidget(
                      initialImages: _selectedImages,
                      existingImageUrls:
                          widget.room.images
                              ?.map((img) => img.fullImageUrl)
                              .toList() ??
                          [],
                      onImagesChanged: (selected, removed) {
                        setState(() {
                          _selectedImages = selected;
                          _removedImageUrls.clear();
                          _removedImageUrls.addAll(removed);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    const Text(
                      'Listing Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Cozy Modern Apartment',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    const Text(
                      'Monthly Price (\$)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g., 150',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a price'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Location Dropdowns
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDistrict,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            items: districtVillages.keys.map((String district) {
                              return DropdownMenuItem<String>(
                                value: district,
                                child: Text(district),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedDistrict = newValue;
                                  _selectedVillage = districtVillages[newValue]!.first;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('village_dropdown_$_selectedDistrict'),
                            initialValue: _selectedVillage,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            items: districtVillages[_selectedDistrict]!.map((String village) {
                              return DropdownMenuItem<String>(
                                value: village,
                                child: Text(village),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedVillage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amenities Section
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingAmenities
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final seenAmenityIds = <int>{};
                              final filteredAmenities = <Amenity>[];

                              for (final amenity in _allAmenities) {
                                final id = amenity.amenityId;
                                if (id == null) continue;
                                if (_selectedAmenityIds.contains(id)) continue;
                                if (seenAmenityIds.add(id)) {
                                  filteredAmenities.add(amenity);
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (filteredAmenities.isNotEmpty)
                                    DropdownButtonFormField<int>(
                                      key: ValueKey(
                                        filteredAmenities
                                            .map((a) => a.amenityId)
                                            .join(','),
                                      ),
                                      initialValue:
                                          _selectedAmenityDropdownValue,
                                      decoration: InputDecoration(
                                        hintText: 'Select an amenity',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                      ),
                                      items: filteredAmenities.map((amenity) {
                                        return DropdownMenuItem<int>(
                                          value: amenity.amenityId,
                                          child: Text(
                                            amenity.amenityName ?? '',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedAmenityIds.add(newValue);
                                            _selectedAmenityDropdownValue =
                                                null;
                                          });
                                        }
                                      },
                                    ),
                                  if (_selectedAmenityIds.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _selectedAmenityIds.map((id) {
                                        final amenity = _allAmenities
                                            .firstWhere(
                                              (a) => a.amenityId == id,
                                              orElse: () => Amenity(
                                                amenityId: id,
                                                amenityName: 'Unknown',
                                              ),
                                            );
                                        return InputChip(
                                          label: Text(
                                            amenity.amenityName ?? '',
                                          ),
                                          onDeleted: () {
                                            setState(() {
                                              _selectedAmenityIds.remove(id);
                                            });
                                          },
                                          deleteIconColor: Colors.red.shade400,
                                          backgroundColor: const Color(
                                            0xFF3B5998,
                                          ).withValues(alpha: 0.1),
                                          labelStyle: const TextStyle(
                                            color: Color(0xFF3B5998),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    // Description Field
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the room, facilities, and rules...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a description'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5998),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
