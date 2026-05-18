import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/app_theme.dart';


class ManageFinancePage extends StatefulWidget {
  const ManageFinancePage({super.key});

  @override
  State<ManageFinancePage> createState() => _ManageFinancePageState();
}

class _ManageFinancePageState extends State<ManageFinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _incomeFormKey = GlobalKey<FormState>();
  final _expenseFormKey = GlobalKey<FormState>();

  // Income fields
  final _incomeAmountController = TextEditingController();
  final _incomeNoteController = TextEditingController();
  String _selectedIncomeCategory = 'Gaji Bulanan';

  // Expense fields
  final _expenseAmountController = TextEditingController();
  final _expenseNoteController = TextEditingController();
  String _selectedExpenseCategory = 'Makanan';

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Mock current balance — replace with state/provider
  double _currentBalance = 1250000;

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Gaji Bulanan', 'icon': Icons.account_balance_wallet_rounded, 'color': AppTheme.primaryGreen},
    {'name': 'Freelance', 'icon': Icons.laptop_mac_rounded, 'color': AppTheme.accentBlue},
    {'name': 'Bisnis', 'icon': Icons.store_rounded, 'color': AppTheme.accentYellow},
    {'name': 'Investasi', 'icon': Icons.trending_up_rounded, 'color': AppTheme.primaryPurple},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': AppTheme.textSecondary},
  ];

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Makanan', 'icon': Icons.restaurant_rounded, 'color': AppTheme.primaryGreen},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded, 'color': AppTheme.accentBlue},
    {'name': 'Hiburan', 'icon': Icons.movie_outlined, 'color': AppTheme.primaryPurple},
    {'name': 'Keluarga', 'icon': Icons.people_outline_rounded, 'color': AppTheme.accentYellow},
    {'name': 'Kesehatan', 'icon': Icons.medical_services_outlined, 'color': AppTheme.accentCoral},
    {'name': 'Belanja', 'icon': Icons.shopping_bag_outlined, 'color': Color(0xFFFF9F43)},
    {'name': 'Tagihan', 'icon': Icons.receipt_long_outlined, 'color': Color(0xFF54A0FF)},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': AppTheme.textSecondary},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeAmountController.dispose();
    _incomeNoteController.dispose();
    _expenseAmountController.dispose();
    _expenseNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryGreen,
            surface: AppTheme.bgCardElevated,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    final isIncome = _tabController.index == 0;
    final formKey = isIncome ? _incomeFormKey : _expenseFormKey;
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: POST to API endpoint
    await Future.delayed(const Duration(milliseconds: 1200));

    final amount = double.tryParse(
          (isIncome ? _incomeAmountController : _expenseAmountController)
              .text
              .replaceAll('.', ''),
        ) ??
        0;

    setState(() {
      _currentBalance += isIncome ? amount : -amount;
      _isLoading = false;
    });

    _showSuccessSnackbar(isIncome, amount);
    if (isIncome) {
      _incomeAmountController.clear();
      _incomeNoteController.clear();
    } else {
      _expenseAmountController.clear();
      _expenseNoteController.clear();
    }
  }

  void _showSuccessSnackbar(bool isIncome, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              '${isIncome ? 'Pemasukan' : 'Pengeluaran'} Rp${_formatNumber(amount)} dicatat!',
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.bgCardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBalanceBanner(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildIncomeForm(),
                  _buildExpenseForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
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
            'Catat Keuangan',
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

  Widget _buildBalanceBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.15),
            AppTheme.accentBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Saldo Saat Ini',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            'Rp ${_formatNumber(_currentBalance)}',
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bgCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _tabController.index == 0
              ? AppTheme.primaryGreen
              : AppTheme.accentCoral,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.bgDark,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '💰  Pemasukan'),
          Tab(text: '💸  Pengeluaran'),
        ],
      ),
    );
  }

  Widget _buildIncomeForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _incomeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Kategori Pemasukan'),
            const SizedBox(height: 12),
            _buildCategoryGrid(_incomeCategories, _selectedIncomeCategory, (val) {
              setState(() => _selectedIncomeCategory = val);
            }),
            const SizedBox(height: 24),
            _buildAmountField(_incomeAmountController, AppTheme.primaryGreen),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildNoteField(_incomeNoteController),
            const SizedBox(height: 32),
            _buildSubmitButton(true),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _expenseFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Kategori Pengeluaran'),
            const SizedBox(height: 12),
            _buildCategoryGrid(_expenseCategories, _selectedExpenseCategory, (val) {
              setState(() => _selectedExpenseCategory = val);
            }),
            const SizedBox(height: 24),
            _buildAmountField(_expenseAmountController, AppTheme.accentCoral),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildNoteField(_expenseNoteController),
            const SizedBox(height: 32),
            _buildSubmitButton(false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Map<String, dynamic>> categories,
    String selected,
    Function(String) onSelect,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = selected == cat['name'];
        final color = cat['color'] as Color;
        return GestureDetector(
          onTap: () => onSelect(cat['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : AppTheme.bgCardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppTheme.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat['icon'] as IconData, color: isSelected ? color : AppTheme.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  cat['name'],
                  style: TextStyle(
                    color: isSelected ? color : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountField(TextEditingController controller, Color accentColor) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: accentColor,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsSeparatorInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Jumlah',
        prefixText: 'Rp  ',
        prefixStyle: TextStyle(
          color: accentColor.withOpacity(0.7),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Jumlah tidak boleh kosong';
        final amount = double.tryParse(v.replaceAll('.', '')) ?? 0;
        if (amount <= 0) return 'Jumlah harus lebih dari 0';
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Catatan (opsional)',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.notes_rounded),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton(bool isIncome) {
    final color = isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral;
    final label = isIncome ? 'Simpan Pemasukan' : 'Simpan Pengeluaran';
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppTheme.bgDark,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppTheme.bgDark)),
              )
            : Icon(icon, size: 20),
        label: _isLoading ? const Text('Menyimpan...') : Text(label),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatNumber(double value) {
    final str = value.toStringAsFixed(0);
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll('.', '');
    final result = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) result.write('.');
      result.write(digits[i]);
    }
    return TextEditingValue(
      text: result.toString(),
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}