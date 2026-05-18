import 'package:flutter/material.dart';
import 'package:frontend/screens/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showAlarm = true;

  final double _totalIncome = 5000000;
  final double _totalExpense = 3750000;
  final bool _isNearBudgetLimit = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan',   'amount': 1200000.0, 'color': AppTheme.primaryGreen,  'icon': Icons.restaurant_rounded,      'percent': 0.32},
    {'name': 'Transport', 'amount': 800000.0,  'color': AppTheme.accentBlue,    'icon': Icons.directions_car_rounded,  'percent': 0.21},
    {'name': 'Hiburan',   'amount': 600000.0,  'color': AppTheme.primaryPurple, 'icon': Icons.movie_outlined,          'percent': 0.16},
    {'name': 'Keluarga',  'amount': 750000.0,  'color': AppTheme.accentYellow,  'icon': Icons.people_outline_rounded,  'percent': 0.20},
    {'name': 'Lainnya',   'amount': 400000.0,  'color': AppTheme.accentCoral,   'icon': Icons.more_horiz_rounded,      'percent': 0.11},
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {'title': 'Grab Food',      'category': 'Makanan',  'amount': -45000.0,   'time': '2 jam lalu',  'icon': Icons.fastfood_rounded},
    {'title': 'Gaji Freelance', 'category': 'Income',   'amount': 1500000.0,  'time': '1 hari lalu', 'icon': Icons.laptop_mac_rounded},
    {'title': 'Token Listrik',  'category': 'Keluarga', 'amount': -200000.0,  'time': '2 hari lalu', 'icon': Icons.bolt_rounded},
    {'title': 'Indomaret',      'category': 'Makanan',  'amount': -87000.0,   'time': '3 hari lalu', 'icon': Icons.shopping_bag_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER (fixed, tidak scroll) ──
            _buildTopBar(),

            // ── ALARM (fixed, hanya muncul jika near budget) ──
            if (_isNearBudgetLimit && _showAlarm) _buildBudgetAlarm(),

            // ── KONTEN (scroll tanpa stretch) ──
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildCategoryChart(),
                  const SizedBox(height: 28),
                  _buildExpenseBreakdown(),
                  const SizedBox(height: 28),
                  _buildRecentTransactions(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/manage-finance'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.bgDark,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: AppTheme.bgDark,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Nunez! 👋',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bgCardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.accentBlue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'N',
                style: TextStyle(
                  color: AppTheme.bgDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Budget Alarm ─────────────────────────────────────────────────────────

  Widget _buildBudgetAlarm() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentCoral.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentCoral.withOpacity(_pulseAnimation.value),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentCoral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.accentCoral,
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Hampir Over-Budget!',
                      style: TextStyle(
                        color: AppTheme.accentCoral,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pengeluaran sudah 75% dari budget bulan ini.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showAlarm = false),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Balance Card ─────────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    final double remaining = _totalIncome - _totalExpense;
    final double progress = (_totalExpense / _totalIncome).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2E1A), Color(0xFF0F1F2A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sisa Budget Bulan Ini',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Mei 2025',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(remaining),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.bgCard,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.75
                    ? AppTheme.accentCoral
                    : AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(
                label: 'Pemasukan',
                value: _formatCurrency(_totalIncome),
                color: AppTheme.primaryGreen,
                icon: Icons.arrow_downward_rounded,
              ),
              const Spacer(),
              _buildMiniStat(
                label: 'Pengeluaran',
                value: _formatCurrency(_totalExpense),
                color: AppTheme.accentCoral,
                icon: Icons.arrow_upward_rounded,
                rightAlign: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool rightAlign = false,
  }) {
    return Column(
      crossAxisAlignment:
          rightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: rightAlign
              ? [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(width: 4),
                  Icon(icon, color: color, size: 13),
                ]
              : [
                  Icon(icon, color: color, size: 13),
                  const SizedBox(width: 4),
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'Tambah\nTransaksi',
        'icon': Icons.add_circle_outline_rounded,
        'route': '/manage-finance'
      },
      {
        'label': 'Alokasi\nBudget',
        'icon': Icons.pie_chart_outline_rounded,
        'route': '/budget-allocation'
      },
      {
        'label': 'Target\nTabungan',
        'icon': Icons.savings_outlined,
        'route': '/saving-goals'
      },
      {
        'label': 'Laporan',
        'icon': Icons.bar_chart_rounded,
        'route': '/reports'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, action['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Category Chart ───────────────────────────────────────────────────────

  Widget _buildCategoryChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pengeluaran Kategori',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              const Text(
                'Bulan Ini',
                style:
                    TextStyle(color: AppTheme.primaryGreen, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: _categories
                  .map((cat) => _buildCategoryBar(cat))
                  .toList(),
            ),
          ),
        ],
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
            children: _categories.map((item) {
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

  Widget _buildCategoryBar(Map<String, dynamic> cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  cat['icon'] as IconData,
                  color: cat['color'] as Color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cat['name'],
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatCurrency(cat['amount'] as double),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cat['percent'] as double,
              minHeight: 5,
              backgroundColor: AppTheme.bgCardElevated,
              valueColor:
                  AlwaysStoppedAnimation(cat['color'] as Color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Transactions ──────────────────────────────────────────────────

  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/reports'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                      color: AppTheme.primaryGreen, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._recentTransactions
              .map((tx) => _buildTransactionItem(tx))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final double amount = tx['amount'] as double;
    final bool isIncome = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isIncome
                      ? AppTheme.primaryGreen
                      : AppTheme.accentCoral)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tx['icon'] as IconData,
              color:
                  isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral,
              size: 20,
            ),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx['category']} · ${tx['time']}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${_formatCurrency(amount)}',
            style: TextStyle(
              color:
                  isIncome ? AppTheme.primaryGreen : AppTheme.accentCoral,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
        color: AppTheme.bgCard,
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (i) {
          setState(() => _selectedNavIndex = i);
          // Index 0 = Home (tidak push agar tidak double)
          // Index 2 = FAB placeholder, skip
          final routes = ['', '/manage-finance', '', '/reports'];
          if (routes[i].isNotEmpty) {
            Navigator.pushNamed(context, routes[i]);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi,';
    if (hour < 17) return 'Selamat Siang,';
    if (hour < 20) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  String _formatCurrency(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000) return 'Rp${(abs / 1000000).toStringAsFixed(1)}jt';
    if (abs >= 1000) return 'Rp${(abs / 1000).toStringAsFixed(0)}rb';
    return 'Rp${abs.toStringAsFixed(0)}';
  }
}