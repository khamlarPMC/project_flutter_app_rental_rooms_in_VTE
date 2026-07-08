import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'owner_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_toggle_button.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
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

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEFAE0), Color(0xFFFAEDCD)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const LanguageToggleButton(),
                ),
              ),
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
                        const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Color(0xFFD4A373)),
                        const SizedBox(height: 24),
                        Text(
                          l.tr('createAccount'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333), letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.tr('registerSubtitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => v == null || v.isEmpty ? l.tr('pleaseEnterName') : null,
                          decoration: _inputDecoration(hint: l.tr('fullName'), icon: Icons.person_outline),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          validator: (v) => v == null || !v.contains('@') ? l.tr('pleaseEnterValidEmail') : null,
                          decoration: _inputDecoration(hint: l.tr('emailAddress'), icon: Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: _inputDecoration(hint: l.tr('selectRole'), icon: Icons.badge_outlined),
                          items: [
                            DropdownMenuItem(value: 'User', child: Text(l.tr('user'))),
                            DropdownMenuItem(value: 'Owner', child: Text(l.tr('owner'))),
                          ],
                          validator: (v) => v == null ? l.tr('pleaseSelectRole') : null,
                          onChanged: (v) { if (v != null) setState(() => _selectedRole = v); },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration(hint: l.tr('phoneNumber'), icon: Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: _inputDecoration(hint: l.tr('age'), icon: Icons.calendar_today_outlined),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: _inputDecoration(hint: l.tr('gender'), icon: Icons.person_outline),
                          items: [
                            DropdownMenuItem(value: 'Male', child: Text(l.tr('male'))),
                            DropdownMenuItem(value: 'Female', child: Text(l.tr('female'))),
                            DropdownMenuItem(value: 'Other', child: Text(l.tr('other'))),
                          ],
                          onChanged: (v) => setState(() => _selectedGender = v),
                        ),
                        const SizedBox(height: 16),
                        Text(l.tr('addressDetails'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                        const SizedBox(height: 8),
                        TextFormField(controller: _villageController, decoration: _inputDecoration(hint: l.tr('villageStreet'), icon: Icons.home_outlined)),
                        const SizedBox(height: 12),
                        TextFormField(controller: _districtController, decoration: _inputDecoration(hint: l.tr('district'), icon: Icons.location_city_outlined)),
                        const SizedBox(height: 12),
                        TextFormField(controller: _provinceController, decoration: _inputDecoration(hint: l.tr('province'), icon: Icons.map_outlined)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          validator: (v) => v == null || v.length < 8 ? l.tr('passwordTooShort') : null,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(hint: l.tr('password'), icon: Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l.tr('pleaseConfirmPassword');
                            if (v != _passwordController.text) return l.tr('passwordsDoNotMatch');
                            return null;
                          },
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration(hint: l.tr('confirmPassword'), icon: Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () async {
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
                                if (_selectedRole == 'Owner') {
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()), (r) => false);
                                } else {
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
                                }
                              } else {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.tr('registrationFailed')), backgroundColor: Colors.red));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A373),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: const Color(0xFFD4A373).withValues(alpha: 0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(l.tr('register').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.tr('alreadyHaveAccount'), style: const TextStyle(color: Colors.black54)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l.tr('logIn'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4A373))),
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
