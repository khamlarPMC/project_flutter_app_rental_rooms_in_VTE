import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class DetailUserScreen extends StatefulWidget {
  final String initialRole;

  const DetailUserScreen({super.key, this.initialRole = 'User'});

  @override
  State<DetailUserScreen> createState() => _DetailUserScreenState();
}

class _DetailUserScreenState extends State<DetailUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _villageController;
  late TextEditingController _districtController;
  late TextEditingController _provinceController;

  String? _gender;
  String _roleName = 'User';
  bool _isLoading = false;

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _villageController = TextEditingController();
    _districtController = TextEditingController();
    _provinceController = TextEditingController();

    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    // Populate with cached user first
    final cachedUser = AuthService.currentUser;
    if (cachedUser != null) {
      _populateFields(cachedUser);
    }

    try {
      final freshUser = await _authService.getProfile();
      if (freshUser != null) {
        setState(() {
          _populateFields(freshUser);
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFields(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _ageController.text = user.age != null ? user.age.toString() : '';
    _gender = user.gender;
    _villageController.text = user.address?.village ?? '';
    _districtController.text = user.address?.district ?? '';
    _provinceController.text = user.address?.province ?? '';
    _roleName = user.role?.roleName ?? widget.initialRole;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          _profileImage = pickedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = await _authService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        gender: _gender,
        village: _villageController.text.trim().isEmpty
            ? null
            : _villageController.text.trim(),
        district: _districtController.text.trim().isEmpty
            ? null
            : _districtController.text.trim(),
        province: _provinceController.text.trim().isEmpty
            ? null
            : _provinceController.text.trim(),
      );

      if (!mounted) return;

      if (updatedUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        String errorMsg =
            AuthService.lastErrorMessage ?? 'Failed to update profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.screenPaddingH,
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            shape: BoxShape.circle,
                            boxShadow: AppShadow.avatar,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(File(_profileImage!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _profileImage == null
                              ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Display Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text(
                      _roleName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSize.sm,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section: Personal Info Card
                  _buildCard(
                    title: 'Personal Details',
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Your email address',
                        icon: Icons.email_outlined,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'e.g. 020...',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              hint: 'Age',
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final age = int.tryParse(value);
                                  if (age == null || age <= 0 || age > 120) {
                                    return 'Invalid age';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGenderDropdown(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section: Address Info Card
                  _buildCard(
                    title: 'Address Information',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildTextField(
                        controller: _villageController,
                        label: 'Village',
                        hint: 'Enter village name',
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _districtController,
                        label: 'District',
                        hint: 'Enter district name',
                        icon: Icons.domain,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _provinceController,
                        label: 'Province',
                        hint: 'Enter province name',
                        icon: Icons.map_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Save Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        'SAVE PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderLg,
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Updating Profile...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.borderXxl,
        boxShadow: AppShadow.card,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: FontWeight.bold,
            color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: enabled ? const Color(0xFF334155) : Colors.grey.shade600,
            fontSize: AppFontSize.body,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: AppFontSize.md,
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
              size: 20,
            ),
            filled: true,
            fillColor: enabled
                ? AppColors.backgroundField
                : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: (_gender != null && AppGenders.options.contains(_gender))
              ? _gender
              : null,
          hint: Text(
            'Select Gender',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: AppFontSize.md,
            ),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.transgender,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.backgroundField,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          items: AppGenders.options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: AppFontSize.body),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _gender = newValue;
            });
          },
        ),
      ],
    );
  }
}
