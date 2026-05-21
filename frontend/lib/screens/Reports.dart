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

  // Mock data — silakan hubungkan dengan API/State Management Anda
  final double _totalIncome = 8500000;
  final double _totalAllocation = 5000000; // Total pendapatan di kantong utama yang dialokasikan
  final double _totalExpense = 5750000;

  // Mock data breakdown sumber pemasukan bulan berjalan
  final List<Map<String, dynamic>> _incomeBreakdown = [
    {'name': 'Gaji Pokok', 'amount': 6500000.0, 'color': AppTheme.primaryGreen},
    {'name': 'Freelance', 'amount': 1500000.0, 'color': AppTheme.accentBlue},
    {'name': 'Investasi', 'amount': 500000.0, 'color': AppTheme.accentYellow},
  ];

  // Mock data alokasi dana dari kantong utama ke dompet-dompet
  final List<Map<String, dynamic>> _allocationBreakdown = [
    {'name': 'Dompet Makanan', 'amount': 1000000.0, 'color': AppTheme.primaryGreen},
    {'name': 'Dompet Transport', 'amount': 1000000.0, 'color': AppTheme.accentBlue},
    {'name': 'Dompet Keluarga', 'amount': 1000000.0, 'color': AppTheme.accentYellow},
    {'name': 'Dompet Hiburan', 'amount': 1000000.0, 'color': AppTheme.primaryPurple},
    {'name': 'Dompet Darurat', 'amount': 1000000.0, 'color': AppTheme.accentCoral},
  ];

  // Mock data breakdown distribusi pengeluaran secara keseluruhan (dikembalikan seperti awal)
  final List<Map<String, dynamic>> _expenseBreakdown = [
    {'name': 'Makanan', 'amount': 1800000.0, 'color': AppTheme.primaryGreen},
    {'name': 'Transport', 'amount': 1200000.0, 'color': AppTheme.accentBlue},
    {'name': 'Keluarga', 'amount': 1000000.0, 'color': AppTheme.accentYellow},
    {'name': 'Hiburan', 'amount': 900000.0, 'color': AppTheme.primaryPurple},
    {'name': 'Lainnya', 'amount': 850000.0, 'color': AppTheme.accentCoral},
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
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        child: Column(
                          children: [
                            _buildIncomeExpenseCards(),
                            const SizedBox(height: 28),
                            _buildDonutSection(
                              title: 'Sumber Pemasukan',
                              items: _incomeBreakdown,
                              total: _totalIncome,
                              centerLabel: 'Sumber',
                            ),
                            const SizedBox(height: 28),
                            _buildDonutSection(
                              title: 'Alokasi Dana Kantong Utama',
                              items: _allocationBreakdown,
                              total: _totalAllocation,
                              centerLabel: 'Dompet',
                            ),
                            const SizedBox(height: 28),
                            _buildDonutSection(
                              title: 'Distribusi Pengeluaran',
                              items: _expenseBreakdown,
                              total: _totalExpense,
                              centerLabel: 'Transaksi',
                            ),
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
              width: 40,
              height: 40,
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
                color: _showMonthPicker ? AppTheme.primaryGreen.withOpacity(0.15) : AppTheme.bgCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showMonthPicker ? AppTheme.primaryGreen : AppTheme.borderColor,
                  width: _showMonthPicker ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _monthNames[_selectedMonth - 1],
                    style: TextStyle(
                      color: _showMonthPicker ? AppTheme.primaryGreen : AppTheme.textPrimary,
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
                      color: _showMonthPicker ? AppTheme.primaryGreen : AppTheme.textSecondary,
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
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _monthShort[index],
                  style: TextStyle(
                    color: isSelected ? AppTheme.bgDark : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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

  // Komponen Reusable untuk Sektor Donut Chart beserta Rincian Transaksinya
  Widget _buildDonutSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required double total,
    required String centerLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              // Grafik Donut & Mini-Legend Samping
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: _ReportDonutChartPainter(items, total),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${items.length}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              Text(centerLabel, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.map((item) {
                            final amount = item['amount'] as double;
                            final percent = total > 0 ? (amount / total * 100) : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(item['name'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                  Text('${percent.toStringAsFixed(0)}%', style: TextStyle(color: item['color'] as Color, fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppTheme.borderColor, height: 1),
              const SizedBox(height: 16),
              // Daftar List Item & Progress Bar di Bawah Grafik
              ...items.map((item) {
                final amount = item['amount'] as double;
                final percent = total > 0 ? (amount / total) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item['color'] as Color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item['name'], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            _formatCurrency(amount),
                            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 38,
                            child: Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
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
                          value: percent,
                          minHeight: 5,
                          backgroundColor: AppTheme.bgCardElevated,
                          valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    return 'Rp${amount.toStringAsFixed(0)}';
  }
}

// ─── Custom Painter Donut Chart untuk Reports ──────────────────────────────────

class _ReportDonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  final double total;

  _ReportDonutChartPainter(this.items, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.38;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -1.5708; // Mulai dari atas jam 12
    for (final item in items) {
      final amount = item['amount'] as double;
      final sweep = (amount / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweep - 0.04, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_ReportDonutChartPainter old) => true;
}