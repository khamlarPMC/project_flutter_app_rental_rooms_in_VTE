import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/photo_picker_widget.dart';
import '../models/room_model.dart';
import '../models/address_model.dart';
import '../models/amenity_model.dart';
import '../services/room_service.dart';
import '../utils/district_villages.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoomService _roomService = RoomService();
  bool _isLoading = false;

  // Photo state
  List<XFile> _selectedImages = [];

  // Amenity state
  List<Amenity> _allAmenities = [];
  final List<int> _selectedAmenityIds = [];
  bool _isLoadingAmenities = true;
  int? _selectedAmenityDropdownValue;

  // Form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _selectedDistrict;
  late String _selectedVillage;

  @override
  void initState() {
    super.initState();
    _selectedDistrict = districtVillages.keys.first;
    _selectedVillage = districtVillages[_selectedDistrict]!.first;
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

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final room = Room(
        roomName: _titleController.text,
        pricePerMonth: double.parse(_priceController.text),
        description: _descriptionController.text,
        roomStatus: 'available',
        address: Address(
          village: _selectedVillage,
          district: _selectedDistrict,
          province: 'Vientiane',
        ),
      );

      final result = await _roomService.createRoom(
        room,
        _selectedImages,
        _selectedAmenityIds,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('listingCreatedSuccess')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception('Failed to create listing');
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

    final isLao = LanguageProvider.instance.isLao;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        title: Text(context.tr('addNewRoom')),
        backgroundColor: const Color(0xFFD4A373),
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
                      onImagesChanged: (selected, removed) {
                        setState(() {
                          _selectedImages = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    Text(
                      context.tr('roomName'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: context.tr('roomName'),
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
                          ? context.tr('pleaseEnterTitle')
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    Text(
                      context.tr('pricePerMonth'),
                      style: const TextStyle(
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
                          ? context.tr('pleaseEnterPrice')
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Location Dropdowns
                    Text(
                      context.tr('location'),
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
                            isExpanded: true,
                            value: _selectedDistrict,
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
                                child: Text(getDistrictDisplay(district, isLao), overflow: TextOverflow.ellipsis),
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
                            isExpanded: true,
                            value: _selectedVillage,
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
                                child: Text(getVillageDisplay(village, isLao), overflow: TextOverflow.ellipsis),
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
                    Text(
                      context.tr('selectAmenities'),
                      style: const TextStyle(
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
                                        hintText: context.tr('selectAnAmenity'),
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
                                            0xFFD4A373,
                                          ).withValues(alpha: 0.1),
                                          labelStyle: const TextStyle(
                                            color: Color(0xFFD4A373),
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
                    Text(
                      context.tr('description'),
                      style: const TextStyle(
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
                        hintText: context.tr('descriptionHint'),
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
                          ? context.tr('pleaseEnterDescription')
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A373),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        context.tr('publishListing').toUpperCase(),
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
