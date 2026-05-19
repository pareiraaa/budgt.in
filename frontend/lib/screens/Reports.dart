import 'package:flutter/material.dart';
import 'package:frontend/screens/app_theme.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  int _selectedMonth = DateTime.now().month;
int _selectedYear = 2025;
bool _showMonthPicker = false;

late AnimationController _monthPickerController;
late Animation<double> _monthPickerAnim;

final ScrollController _monthScrollController = ScrollController();

final List<String> _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

final List<String> _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];


  // Mock data — replace with API/state
  final double _totalIncome = 8500000;
  final double _totalExpense = 5750000;

  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Jan', 'income': 6000000.0, 'expense': 4200000.0},
    {'month': 'Feb', 'income': 7000000.0, 'expense': 5000000.0},
    {'month': 'Mar', 'income': 5500000.0, 'expense': 4800000.0},
    {'month': 'Apr', 'income': 8000000.0, 'expense': 5200000.0},
    {'month': 'Mei', 'income': 8500000.0, 'expense': 5750000.0},
  ];

  final List<Map<String, dynamic>> _expenseBreakdown = [
    {'name': 'Makanan', 'amount': 1800000.0, 'color': AppTheme.primaryGreen, 'percent': 0.31},
    {'name': 'Transport', 'amount': 1200000.0, 'color': AppTheme.accentBlue, 'percent': 0.21},
    {'name': 'Keluarga', 'amount': 1000000.0, 'color': AppTheme.accentYellow, 'percent': 0.17},
    {'name': 'Hiburan', 'amount': 900000.0, 'color': AppTheme.primaryPurple, 'percent': 0.16},
    {'name': 'Lainnya', 'amount': 850000.0, 'color': AppTheme.accentCoral, 'percent': 0.15},
  ];

  final List<Map<String, dynamic>> _savingGoalProgress = [
    {'name': 'Beli Laptop', 'emoji': '💻', 'progress': 0.30, 'saved': 4500000.0, 'target': 15000000.0, 'color': AppTheme.accentBlue},
    {'name': 'Dana Darurat', 'emoji': '🛡️', 'progress': 0.40, 'saved': 12000000.0, 'target': 30000000.0, 'color': AppTheme.primaryGreen},
    {'name': 'Liburan Bali', 'emoji': '🏖️', 'progress': 0.64, 'saved': 3200000.0, 'target': 5000000.0, 'color': AppTheme.accentYellow},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _monthPickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _monthPickerAnim = CurvedAnimation(
      parent: _monthPickerController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _monthPickerController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  void _toggleMonthPicker() {
  setState(() => _showMonthPicker = !_showMonthPicker);

  if (_showMonthPicker) {
    _monthPickerController.forward();

    Future.delayed(
      const Duration(milliseconds: 50),
      _scrollToSelectedMonth,
    );
  } else {
    _monthPickerController.reverse();
  }
}

void _scrollToSelectedMonth() {
  if (!_monthScrollController.hasClients) return;

  final offset = (_selectedMonth - 1) * 72.0;

  _monthScrollController.animateTo(
    offset.clamp(
      0.0,
      _monthScrollController.position.maxScrollExtent,
    ),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    SizeTransition(
                      sizeFactor: _monthPickerAnim,
                      axisAlignment: -1,
                      child: _buildMonthPicker(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24,40,),
                      child: Column(
                        children: [
                          _buildIncomeExpenseCards(),
                          const SizedBox(height: 28),
                          _buildBarChart(),
                          const SizedBox(height: 28),
                          _buildExpenseBreakdown(),
                          const SizedBox(height: 28),
                          _buildSavingGoalTrack(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 17),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan Keuangan', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                Text('Ringkasan aktivitas finansialmu', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPeriodSelector() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
    child: Row(
      children: [
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
                  width: 36,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
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
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedYear++),
                child: Container(
                  width: 36,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        GestureDetector(
          onTap: _toggleMonthPicker,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
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
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected = month == _selectedMonth;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedMonth = month);
            _toggleMonthPicker();
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
            ),
            child: Center(
              child: Text(
                _monthShort[index],
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.bgDark
                      : AppTheme.textPrimary,
                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildIncomeExpenseCards() {
    final net = _totalIncome - _totalExpense;
    final savingsRate = _totalIncome > 0 ? (net / _totalIncome * 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                label: 'Total Pemasukan',
                value: _formatCurrency(_totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                label: 'Total Pengeluaran',
                value: _formatCurrency(_totalExpense),
                icon: Icons.arrow_upward_rounded,
                color: AppTheme.accentCoral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: net >= 0
                  ? [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.accentBlue.withOpacity(0.05)]
                  : [AppTheme.accentCoral.withOpacity(0.1), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: net >= 0 ? AppTheme.primaryGreen.withOpacity(0.3) : AppTheme.accentCoral.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Net Tabungan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(net),
                    style: TextStyle(
                      color: net >= 0 ? AppTheme.primaryGreen : AppTheme.accentCoral,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Savings Rate', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${savingsRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: savingsRate >= 20 ? AppTheme.primaryGreen : AppTheme.accentYellow,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxVal = _monthlyData.fold(0.0, (m, d) =>
        [m, d['income'] as double, d['expense'] as double].reduce((a, b) => a > b ? a : b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Tren Keuangan', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
            const Spacer(),
            _buildChartLegend('Masuk', AppTheme.primaryGreen),
            const SizedBox(width: 12),
            _buildChartLegend('Keluar', AppTheme.accentCoral),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _monthlyData.map((data) {
                    final incomeH = maxVal > 0 ? ((data['income'] as double) / maxVal) * 130 : 0.0;
                    final expenseH = maxVal > 0 ? ((data['expense'] as double) / maxVal) * 130 : 0.0;
                    return _buildBarGroup(data['month'], incomeH, expenseH);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _monthlyData.map((d) => Text(
                  d['month'],
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildBarGroup(String month, double incomeH, double expenseH) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(incomeH, AppTheme.primaryGreen),
            const SizedBox(width: 3),
            _buildBar(expenseH, AppTheme.accentCoral),
          ],
        ),
      ],
    );
  }

  Widget _buildBar(double height, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: 16,
      height: height.clamp(4.0, 130.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Breakdown Pengeluaran', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: _expenseBreakdown.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item['name'],
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        Text(
                          _formatCurrency(item['amount'] as double),
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 38,
                          child: Text(
                            '${((item['percent'] as double) * 100).toStringAsFixed(0)}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: item['color'] as Color, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item['percent'] as double,
                        minHeight: 5,
                        backgroundColor: AppTheme.bgCardElevated,
                        valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingGoalTrack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Goal Track Tabungan', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/saving-goals'),
              child: const Text('Kelola', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._savingGoalProgress.map((goal) => _buildGoalTrackCard(goal)).toList(),
      ],
    );
  }

  Widget _buildGoalTrackCard(Map<String, dynamic> goal) {
    final progress = goal['progress'] as double;
    final color = goal['color'] as Color;
    final saved = goal['saved'] as double;
    final target = goal['target'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Text(goal['emoji'], style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal['name'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    const Spacer(),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppTheme.bgCardElevated,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(_formatCurrency(saved), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(' / ${_formatCurrency(target)}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    return 'Rp${amount.toStringAsFixed(0)}';
  }
}