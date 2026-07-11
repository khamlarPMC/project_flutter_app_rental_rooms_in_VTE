import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import '../l10n/app_localizations.dart';

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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).tr('profileUpdated')),
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
        title: Text(
          context.tr('userProfile'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                  // Profile Picture
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      shape: BoxShape.circle,
                      boxShadow: AppShadow.avatar,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
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
                      style: TextStyle(
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
                    title: context.tr('personalDetails'),
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: context.tr('fullName'),
                        hint: context.tr('fullName'),
                        icon: Icons.person,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.tr('nameRequired')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: context.tr('emailAddress'),
                        hint: context.tr('emailAddress'),
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
                              label: context.tr('phoneNumber'),
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
                              label: context.tr('age'),
                              hint: context.tr('age'),
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final age = int.tryParse(value);
                                  if (age == null || age <= 0 || age > 120) {
                                    return context.tr('invalidAge');
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGenderDropdown(context),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section: Address Info Card
                  _buildCard(
                    title: context.tr('addressInformation'),
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildTextField(
                        controller: _villageController,
                        label: context.tr('village'),
                        hint: context.tr('village'),
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _districtController,
                        label: context.tr('district'),
                        hint: context.tr('district'),
                        icon: Icons.domain,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _provinceController,
                        label: context.tr('province'),
                        hint: context.tr('province'),
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
                      label: Text(
                        context.tr('saveProfile').toUpperCase(),
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
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).tr('updatingProfile'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(
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

  Widget _buildGenderDropdown(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.tr('gender'),
          style: TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue:
              (_gender != null && AppGenders.options.contains(_gender))
              ? _gender
              : null,
          hint: Text(
            l.tr('selectGender'),
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: AppFontSize.md,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
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
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(
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
