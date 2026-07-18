import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_toggle_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRole = 'User';
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.backgroundCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const LanguageToggleButton(),
                ),
              ),
              Positioned(top: 12, right: 12, child: const ThemeToggleButton()),
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l.tr('createAccount'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.tr('registerSubtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => v == null || v.isEmpty
                              ? l.tr('pleaseEnterName')
                              : null,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('fullName'),
                            icon: Icons.person_outline,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          validator: (v) => v == null || !v.contains('@')
                              ? l.tr('pleaseEnterValidEmail')
                              : null,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('emailAddress'),
                            icon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          dropdownColor: AppColors.backgroundCard,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: _inputDecoration(
                            hint: l.tr('selectRole'),
                            icon: Icons.badge_outlined,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'User',
                              child: Text(
                                l.tr('user'),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Owner',
                              child: Text(
                                l.tr('owner'),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                          validator: (v) =>
                              v == null ? l.tr('pleaseSelectRole') : null,
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedRole = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('phoneNumber'),
                            icon: Icons.phone_outlined,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('age'),
                            icon: Icons.calendar_today_outlined,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          dropdownColor: AppColors.backgroundCard,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: _inputDecoration(
                            hint: l.tr('gender'),
                            icon: Icons.person_outline,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text(
                                l.tr('male'),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text(
                                l.tr('female'),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text(
                                l.tr('other'),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedGender = v),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.tr('addressDetails'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _villageController,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('villageStreet'),
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _districtController,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('district'),
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _provinceController,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l.tr('province'),
                            icon: Icons.map_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          validator: (v) => v == null || v.length < 8
                              ? l.tr('passwordTooShort')
                              : null,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration:
                              _inputDecoration(
                                hint: l.tr('password'),
                                icon: Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return l.tr('pleaseConfirmPassword');
                            if (v != _passwordController.text)
                              return l.tr('passwordsDoNotMatch');
                            return null;
                          },
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration:
                              _inputDecoration(
                                hint: l.tr('confirmPassword'),
                                icon: Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
                                    final user = await AuthService().register(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      roleId: _selectedRole == 'Owner' ? 2 : 1,
                                      phone: _phoneController.text.trim(),
                                      age: int.tryParse(_ageController.text),
                                      gender: _selectedGender,
                                      village: _villageController.text.trim(),
                                      district: _districtController.text.trim(),
                                      province: _provinceController.text.trim(),
                                    );
                                    if (!mounted) return;
                                    if (user != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l.tr('registrationSuccess'),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (r) => false,
                                      );
                                    } else {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l.tr('registrationFailed'),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l.tr('register').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l.tr('alreadyHaveAccount'),
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                l.tr('logIn'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
