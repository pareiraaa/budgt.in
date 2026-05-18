import 'package:flutter/material.dart';
import 'package:frontend/screens/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _selectedPersona = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _personas = [
    {
      'id': 'mahasiswa',
      'name': 'Mahasiswa',
      'emoji': '🎓',
      'desc': 'Tracking otomatis agar gak lapar mata',
    },
    {
      'id': 'freelancer',
      'name': 'Freelancer',
      'emoji': '💻',
      'desc': 'Simulasi saving plan dari income variatif',
    },
    {
      'id': 'sandwich',
      'name': 'Sandwich Gen',
      'emoji': '🏠',
      'desc': 'Alokasi otomatis gaji pribadi & keluarga',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPersona.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih persona keuanganmu dulu!'),
          backgroundColor: AppTheme.accentCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // TODO: Integrate with register API
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 28),
                _buildHeader(),
                const SizedBox(height: 36),
                _buildPersonaSelector(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 28),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.bgCardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.15),
            children: [
              TextSpan(text: 'Buat Akun\n', style: TextStyle(color: AppTheme.textPrimary)),
              TextSpan(text: 'Budgt.in ', style: TextStyle(color: AppTheme.primaryGreen)),
              TextSpan(text: '✨', style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mulai perjalanan finansialmu sekarang.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildPersonaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aku adalah...',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        ...(_personas.map((persona) => _PersonaCard(
              persona: persona,
              isSelected: _selectedPersona == persona['id'],
              onTap: () => setState(() => _selectedPersona = persona['id']!),
            ))).toList(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
              if (v.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
              if (v != _passwordController.text) return 'Password tidak cocok';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppTheme.bgDark),
                ),
              )
            : const Text('Buat Akun'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah punya akun? ',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Masuk',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final Map<String, dynamic> persona;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : AppTheme.bgCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(persona['emoji'], style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona['name'],
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    persona['desc'],
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppTheme.bgDark, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}