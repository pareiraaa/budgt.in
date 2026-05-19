import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Toggle States ─────────────────────────────────────────────────────────
  bool _notifBudgetAlert    = true;
  bool _notifTabungan       = false;
  bool _pinAktif            = true;
  bool _darkMode            = true;

  // ── User Info (mock) ──────────────────────────────────────────────────────
  final String _userName    = 'Nunez';
  final String _userEmail   = 'nunez@email.com';
  final String _userPlan    = 'Free Plan';
  final String _userPersona = 'Mahasiswa 🎓';

  // ── Currency & Language ───────────────────────────────────────────────────
  String _selectedCurrency  = 'IDR — Rupiah';
  String _selectedLanguage  = 'Bahasa Indonesia';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                children: [
                  const SizedBox(height: 20),
                  _buildProfileCard(),
                  const SizedBox(height: 28),
                  _buildSection('💰 Keuangan', [
                    _buildNavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Kelola Alokasi Budget',
                      color: AppTheme.primaryGreen,
                      onTap: () => Navigator.pushNamed(context, '/budget-allocation'),
                    ),
                    _buildNavItem(
                      icon: Icons.savings_outlined,
                      label: 'Target Tabungan',
                      color: AppTheme.accentBlue,
                      onTap: () => Navigator.pushNamed(context, '/saving-goals'),
                    ),
                    _buildNavItem(
                      icon: Icons.currency_exchange_rounded,
                      label: 'Mata Uang',
                      color: AppTheme.accentYellow,
                      trailing: Text(
                        _selectedCurrency,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      onTap: () => _showCurrencySheet(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('🔔 Notifikasi', [
                    _buildToggleItem(
                      icon: Icons.warning_amber_rounded,
                      label: 'Alert Over-Budget',
                      subtitle: 'Notifikasi saat hampir over-budget',
                      color: AppTheme.accentCoral,
                      value: _notifBudgetAlert,
                      onChanged: (v) => setState(() => _notifBudgetAlert = v),
                    ),
                    _buildToggleItem(
                      icon: Icons.flag_outlined,
                      label: 'Reminder Tabungan',
                      subtitle: 'Ingatkan untuk menabung tiap bulan',
                      color: AppTheme.accentBlue,
                      value: _notifTabungan,
                      onChanged: (v) => setState(() => _notifTabungan = v),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('🔒 Keamanan', [
                    _buildToggleItem(
                      icon: Icons.pin_outlined,
                      label: 'PIN Aplikasi',
                      subtitle: 'Kunci aplikasi dengan PIN 6 digit',
                      color: AppTheme.accentBlue,
                      value: _pinAktif,
                      onChanged: (v) => setState(() => _pinAktif = v),
                    ),
                    _buildNavItem(
                      icon: Icons.lock_reset_rounded,
                      label: 'Ubah PIN',
                      color: AppTheme.accentYellow,
                      onTap: () => _showChangePinSheet(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('🎨 Tampilan', [
                    _buildToggleItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Mode Gelap',
                      subtitle: 'Aktifkan tema dark mode',
                      color: AppTheme.primaryPurple,
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    _buildNavItem(
                      icon: Icons.language_rounded,
                      label: 'Bahasa',
                      color: AppTheme.accentBlue,
                      trailing: Text(
                        _selectedLanguage,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      onTap: () => _showLanguageSheet(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary, size: 17),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Pengaturan',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () => _showEditProfileSheet(),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.12),
              AppTheme.accentBlue.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('N',
                    style: TextStyle(
                        color: AppTheme.bgDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(_userEmail,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_userPersona,
                            style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_userPlan,
                            style: const TextStyle(
                                color: AppTheme.accentYellow,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Section ───────────────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                          height: 1, color: AppTheme.borderColor),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Toggle Item ───────────────────────────────────────────────────────────

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
            trackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }

  // ── Nav Item ──────────────────────────────────────────────────────────────

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: textColor ?? AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Logout Button ───────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentCoral,
          side: const BorderSide(color: AppTheme.accentCoral, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar dari Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }

  // ── Bottom Sheets & Dialogs ───────────────────────────────────────────────

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Edit Profil',
                style: TextStyle(color: AppTheme.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySheet() {
    final currencies = [
      'IDR — Rupiah',
      'USD — Dollar Amerika',
      'SGD — Dollar Singapura',
      'MYR — Ringgit Malaysia',
      'EUR — Euro',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Pilih Mata Uang',
                style: TextStyle(color: AppTheme.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...currencies.map((c) => GestureDetector(
              onTap: () {
                setState(() => _selectedCurrency = c);
                Navigator.pop(ctx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedCurrency == c
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : AppTheme.bgCardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCurrency == c
                        ? AppTheme.primaryGreen
                        : AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(c,
                          style: TextStyle(
                            color: _selectedCurrency == c
                                ? AppTheme.primaryGreen
                                : AppTheme.textPrimary,
                            fontWeight: _selectedCurrency == c
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )),
                    ),
                    if (_selectedCurrency == c)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryGreen, size: 18),
                  ],
                ),
              ),
            )).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    final languages = ['Bahasa Indonesia', 'English'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Pilih Bahasa',
                style: TextStyle(color: AppTheme.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...languages.map((lang) => GestureDetector(
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(ctx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedLanguage == lang
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : AppTheme.bgCardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLanguage == lang
                        ? AppTheme.primaryGreen
                        : AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(lang,
                          style: TextStyle(
                            color: _selectedLanguage == lang
                                ? AppTheme.primaryGreen
                                : AppTheme.textPrimary,
                            fontWeight: _selectedLanguage == lang
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )),
                    ),
                    if (_selectedLanguage == lang)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryGreen, size: 18),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showChangePinSheet() {
    final oldPin = TextEditingController();
    final newPin = TextEditingController();
    final confirmPin = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Ubah PIN',
                style: TextStyle(color: AppTheme.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: oldPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'PIN Lama',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'PIN Baru (6 digit)',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: confirmPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Konfirmasi PIN Baru',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: validate & update PIN via API
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('PIN berhasil diubah!'),
                      backgroundColor: AppTheme.bgCardElevated,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: AppTheme.primaryGreen)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                child: const Text('Simpan PIN Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Akun?',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text(
          'Kamu perlu login kembali untuk mengakses akunmu.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}