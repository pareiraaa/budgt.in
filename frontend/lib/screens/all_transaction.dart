import 'package:flutter/material.dart';
import 'package:frontend/screens/app_theme.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage>
    with SingleTickerProviderStateMixin {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = 2025;
  String _selectedFilter = 'Semua';
  bool _showMonthPicker = false;

  late AnimationController _monthPickerController;
  late Animation<double> _monthPickerAnim;

  final ScrollController _monthScrollController = ScrollController();

  final List<String> _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final List<String> _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  // ── Mock Data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _allTransactions = [
    // Mei 2025
    {'title': 'Grab Food',      'category': 'Makanan',   'amount': -45000.0,  'date': DateTime(2025, 5, 18), 'icon': Icons.fastfood_rounded},
    {'title': 'Gaji Bulanan',   'category': 'Income',    'amount': 5000000.0, 'date': DateTime(2025, 5, 17), 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Token Listrik',  'category': 'Keluarga',  'amount': -200000.0, 'date': DateTime(2025, 5, 15), 'icon': Icons.bolt_rounded},
    {'title': 'Indomaret',      'category': 'Makanan',   'amount': -87000.0,  'date': DateTime(2025, 5, 14), 'icon': Icons.shopping_bag_outlined},
    {'title': 'Gaji Freelance', 'category': 'Income',    'amount': 1500000.0, 'date': DateTime(2025, 5, 12), 'icon': Icons.laptop_mac_rounded},
    {'title': 'Netflix',        'category': 'Hiburan',   'amount': -54000.0,  'date': DateTime(2025, 5, 10), 'icon': Icons.movie_outlined},
    {'title': 'Bensin',         'category': 'Transport', 'amount': -150000.0, 'date': DateTime(2025, 5, 9),  'icon': Icons.local_gas_station_rounded},
    {'title': 'Makan Siang',    'category': 'Makanan',   'amount': -35000.0,  'date': DateTime(2025, 5, 8),  'icon': Icons.restaurant_rounded},
    {'title': 'Transfer Ortu',  'category': 'Keluarga',  'amount': -500000.0, 'date': DateTime(2025, 5, 5),  'icon': Icons.people_outline_rounded},
    {'title': 'Spotify',        'category': 'Hiburan',   'amount': -29000.0,  'date': DateTime(2025, 5, 3),  'icon': Icons.music_note_rounded},
    {'title': 'GoPay Top Up',   'category': 'Income',    'amount': 200000.0,  'date': DateTime(2025, 5, 2),  'icon': Icons.account_balance_rounded},
    {'title': 'Ojek Online',    'category': 'Transport', 'amount': -25000.0,  'date': DateTime(2025, 5, 1),  'icon': Icons.directions_bike_rounded},
    // April 2025
    {'title': 'Gaji Bulanan',   'category': 'Income',    'amount': 5000000.0, 'date': DateTime(2025, 4, 17), 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Grab Food',      'category': 'Makanan',   'amount': -62000.0,  'date': DateTime(2025, 4, 15), 'icon': Icons.fastfood_rounded},
    {'title': 'Token Listrik',  'category': 'Keluarga',  'amount': -200000.0, 'date': DateTime(2025, 4, 14), 'icon': Icons.bolt_rounded},
    {'title': 'Gaji Freelance', 'category': 'Income',    'amount': 800000.0,  'date': DateTime(2025, 4, 10), 'icon': Icons.laptop_mac_rounded},
    {'title': 'Belanja Online', 'category': 'Belanja',   'amount': -320000.0, 'date': DateTime(2025, 4, 8),  'icon': Icons.shopping_cart_outlined},
    {'title': 'Bensin',         'category': 'Transport', 'amount': -120000.0, 'date': DateTime(2025, 4, 5),  'icon': Icons.local_gas_station_rounded},
    {'title': 'Netflix',        'category': 'Hiburan',   'amount': -54000.0,  'date': DateTime(2025, 4, 3),  'icon': Icons.movie_outlined},
    {'title': 'Transfer Ortu',  'category': 'Keluarga',  'amount': -500000.0, 'date': DateTime(2025, 4, 1),  'icon': Icons.people_outline_rounded},
    // Maret 2025
    {'title': 'Gaji Bulanan',   'category': 'Income',    'amount': 5000000.0, 'date': DateTime(2025, 3, 17), 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Makan Siang',    'category': 'Makanan',   'amount': -40000.0,  'date': DateTime(2025, 3, 15), 'icon': Icons.restaurant_rounded},
    {'title': 'Grab Food',      'category': 'Makanan',   'amount': -55000.0,  'date': DateTime(2025, 3, 12), 'icon': Icons.fastfood_rounded},
    {'title': 'Token Listrik',  'category': 'Keluarga',  'amount': -200000.0, 'date': DateTime(2025, 3, 10), 'icon': Icons.bolt_rounded},
    {'title': 'Ojek Online',    'category': 'Transport', 'amount': -35000.0,  'date': DateTime(2025, 3, 8),  'icon': Icons.directions_bike_rounded},
    {'title': 'Spotify',        'category': 'Hiburan',   'amount': -29000.0,  'date': DateTime(2025, 3, 3),  'icon': Icons.music_note_rounded},
    {'title': 'Transfer Ortu',  'category': 'Keluarga',  'amount': -500000.0, 'date': DateTime(2025, 3, 1),  'icon': Icons.people_outline_rounded},
    // Februari 2025
    {'title': 'Gaji Bulanan',   'category': 'Income',    'amount': 5000000.0, 'date': DateTime(2025, 2, 17), 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Grab Food',      'category': 'Makanan',   'amount': -48000.0,  'date': DateTime(2025, 2, 14), 'icon': Icons.fastfood_rounded},
    {'title': 'Token Listrik',  'category': 'Keluarga',  'amount': -185000.0, 'date': DateTime(2025, 2, 10), 'icon': Icons.bolt_rounded},
    {'title': 'Spotify',        'category': 'Hiburan',   'amount': -29000.0,  'date': DateTime(2025, 2, 3),  'icon': Icons.music_note_rounded},
    // Januari 2025
    {'title': 'Gaji Bulanan',   'category': 'Income',    'amount': 5000000.0, 'date': DateTime(2025, 1, 17), 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Transfer Ortu',  'category': 'Keluarga',  'amount': -500000.0, 'date': DateTime(2025, 1, 10), 'icon': Icons.people_outline_rounded},
    {'title': 'Bensin',         'category': 'Transport', 'amount': -130000.0, 'date': DateTime(2025, 1, 5),  'icon': Icons.local_gas_station_rounded},
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _monthPickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _monthPickerAnim = CurvedAnimation(
      parent: _monthPickerController,
      curve: Curves.easeOut,
    );

    // Auto scroll month list ke bulan yang dipilih
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedMonth());
  }

  @override
  void dispose() {
    _monthPickerController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  void _toggleMonthPicker() {
    setState(() => _showMonthPicker = !_showMonthPicker);
    if (_showMonthPicker) {
      _monthPickerController.forward();
      Future.delayed(const Duration(milliseconds: 50), _scrollToSelectedMonth);
    } else {
      _monthPickerController.reverse();
    }
  }

  void _scrollToSelectedMonth() {
    if (!_monthScrollController.hasClients) return;
    // Setiap item lebar ~72px, scroll ke posisi bulan terpilih
    final offset = (_selectedMonth - 1) * 72.0;
    _monthScrollController.animateTo(
      offset.clamp(0.0, _monthScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ── Filtered & Grouped Data ───────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((tx) {
      final date = tx['date'] as DateTime;
      final matchMonth =
          date.month == _selectedMonth && date.year == _selectedYear;
      final amount = tx['amount'] as double;
      if (!matchMonth) return false;
      if (_selectedFilter == 'Pemasukan') return amount > 0;
      if (_selectedFilter == 'Pengeluaran') return amount < 0;
      return true;
    }).toList()
      ..sort((a, b) =>
          (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  double get _totalIncome => _filteredTransactions
      .where((tx) => (tx['amount'] as double) > 0)
      .fold(0.0, (s, tx) => s + (tx['amount'] as double));

  double get _totalExpense => _filteredTransactions
      .where((tx) => (tx['amount'] as double) < 0)
      .fold(0.0, (s, tx) => s + (tx['amount'] as double));

  Map<String, List<Map<String, dynamic>>> get _groupedTransactions {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final tx in _filteredTransactions) {
      final key = _formatGroupDate(tx['date'] as DateTime);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedTransactions;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPeriodSelector(),
            // Month picker dropdown — animated
            SizeTransition(
              sizeFactor: _monthPickerAnim,
              axisAlignment: -1,
              child: _buildMonthPicker(),
            ),
            _buildSummaryBar(),
            _buildFilterChips(),
            const SizedBox(height: 4),
            Expanded(
              child: grouped.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      children: grouped.entries
                          .map((e) => _buildDateGroup(e.key, e.value))
                          .toList(),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semua Transaksi',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
                Text('Riwayat lengkap keuanganmu',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bgCardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.search_rounded,
                color: AppTheme.textSecondary, size: 19),
          ),
        ],
      ),
    );
  }

  // ── Period Selector (Tahun kiri + Bulan kanan dengan toggle) ──────────────

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          // ── YEAR SELECTOR (kiri) ──
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedYear--),
                  child: Container(
                    width: 36, height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_selectedYear',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedYear++),
                  child: Container(
                    width: 36, height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── MONTH TOGGLE BUTTON (kanan) ──
          GestureDetector(
            onTap: _toggleMonthPicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _showMonthPicker
                    ? AppTheme.primaryGreen.withOpacity(0.15)
                    : AppTheme.bgCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showMonthPicker
                      ? AppTheme.primaryGreen
                      : AppTheme.borderColor,
                  width: _showMonthPicker ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _monthNames[_selectedMonth - 1],
                    style: TextStyle(
                      color: _showMonthPicker
                          ? AppTheme.primaryGreen
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _showMonthPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _showMonthPicker
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Month Picker Dropdown (3 bulan visible, scrollable) ───────────────────

  Widget _buildMonthPicker() {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.bgCardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected = month == _selectedMonth;
          final hasData = _allTransactions.any((tx) {
            final d = tx['date'] as DateTime;
            return d.month == month && d.year == _selectedYear;
          });

          return GestureDetector(
            onTap: () {
              setState(() => _selectedMonth = month);
              _toggleMonthPicker(); // tutup setelah pilih
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _monthShort[index],
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.bgDark
                          : hasData
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dot indikator ada data
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.bgDark.withOpacity(0.5)
                          : hasData
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Summary Bar ───────────────────────────────────────────────────────────

  Widget _buildSummaryBar() {
    final net = _totalIncome + _totalExpense;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.accentBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              label: 'Pemasukan',
              value: _totalIncome,
              color: AppTheme.primaryGreen,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          Container(width: 1, height: 36, color: AppTheme.borderColor),
          Expanded(
            child: _buildSummaryItem(
              label: 'Pengeluaran',
              value: _totalExpense.abs(),
              color: AppTheme.accentCoral,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
          Container(width: 1, height: 36, color: AppTheme.borderColor),
          Expanded(
            child: _buildSummaryItem(
              label: 'Selisih',
              value: net.abs(),
              color: net >= 0 ? AppTheme.primaryGreen : AppTheme.accentCoral,
              icon: net >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: [
          ..._filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            final chipColor = filter == 'Pemasukan'
                ? AppTheme.primaryGreen
                : filter == 'Pengeluaran'
                    ? AppTheme.accentCoral
                    : AppTheme.accentBlue;

            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor.withOpacity(0.15)
                      : AppTheme.bgCardElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? chipColor : AppTheme.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? chipColor
                        : AppTheme.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
          const Spacer(),
          Text(
            '${_filteredTransactions.length} transaksi',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Date Group ────────────────────────────────────────────────────────────

  Widget _buildDateGroup(
      String label, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Container(
                      height: 1, color: AppTheme.borderColor)),
              const SizedBox(width: 10),
              Text(
                _formatDayTotal(transactions),
                style: TextStyle(
                  color: _getDayTotalColor(transactions),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...transactions.map((tx) => _buildTransactionItem(tx)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final double amount = tx['amount'] as double;
    final bool isIncome = amount > 0;
    final DateTime date = tx['date'] as DateTime;
    final color =
        isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tx['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'] as String,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  tx['category'] as String,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}${_formatCurrency(amount)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              const SizedBox(height: 3),
              Text(
                _formatItemDate(date),
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🗂️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi\ndi ${_monthNames[_selectedMonth - 1]} $_selectedYear',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih bulan lain atau tambah transaksi baru.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, '/manage-finance'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Transaksi'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Hari Ini';
    if (d == yesterday) return 'Kemarin';

    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${days[date.weekday - 1]}, ${date.day} ${_monthShort[date.month - 1]}';
  }

  String _formatItemDate(DateTime date) =>
      '${date.day} ${_monthShort[date.month - 1]}';

  String _formatDayTotal(List<Map<String, dynamic>> txs) {
    final total =
        txs.fold(0.0, (s, tx) => s + (tx['amount'] as double));
    return '${total >= 0 ? '+' : ''}${_formatCurrency(total)}';
  }

  Color _getDayTotalColor(List<Map<String, dynamic>> txs) {
    final total =
        txs.fold(0.0, (s, tx) => s + (tx['amount'] as double));
    return total >= 0 ? AppTheme.primaryGreen : AppTheme.accentCoral;
  }

  String _formatCurrency(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000) return 'Rp${(abs / 1000000).toStringAsFixed(1)}jt';
    if (abs >= 1000) return 'Rp${(abs / 1000).toStringAsFixed(0)}rb';
    return 'Rp${abs.toStringAsFixed(0)}';
  }
}