import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk FilteringTextInputFormatter & Custom Formatter
import 'package:frontend/screens/app_theme.dart'; // Pastikan path ini sesuai dengan project Anda

// Model data untuk Pocket (Kantong)
class Pocket {
  final String id;
  String name;
  String emoji;
  double balance;
  Color color;
  final bool isGoal;
  double? targetAmount; // Hanya diisi jika isGoal = true
  IconData icon;

  Pocket({
    required this.id,
    required this.name,
    required this.emoji,
    required this.balance,
    required this.color,
    required this.isGoal,
    this.targetAmount,
    required this.icon,
  });
}

// Model data untuk Transaksi spesifik Pocket
class PocketTransaction {
  final String id;
  final String pocketId;
  final String title;
  final double amount; // Negatif untuk pengeluaran, Positif untuk pemasukan
  final String time; 
  final DateTime date; 
  final IconData icon;

  PocketTransaction({
    required this.id,
    required this.pocketId,
    required this.title,
    required this.amount,
    required this.time,
    required this.date,
    required this.icon,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Daftar Pocket Utama & Pengeluaran (Spending Pockets)
  final List<Pocket> _pockets = [
    Pocket(
      id: 'utama',
      name: 'Kantong Utama',
      emoji: '💳',
      balance: 1850000.0,
      color: AppTheme.primaryGreen,
      isGoal: false,
      icon: Icons.account_balance_wallet_rounded,
    ),
    Pocket(
      id: 'makanan',
      name: 'Makanan & Jajan',
      emoji: '🍜',
      balance: 1200000.0,
      color: AppTheme.accentBlue,
      isGoal: false,
      icon: Icons.restaurant_rounded,
    ),
    Pocket(
      id: 'transport',
      name: 'Transportasi',
      emoji: '🚗',
      balance: 800000.0,
      color: AppTheme.primaryPurple,
      isGoal: false,
      icon: Icons.directions_car_rounded,
    ),
    Pocket(
      id: 'hiburan',
      name: 'Hiburan',
      emoji: '🎬',
      balance: 600000.0,
      color: AppTheme.accentCoral,
      isGoal: false,
      icon: Icons.movie_outlined,
    ),
    // Pocket Tabungan / Saving Goals (isGoal = true)
    Pocket(
      id: 'bali',
      name: 'Liburan Bali',
      emoji: '🏖️',
      balance: 3200000.0,
      targetAmount: 5000000.0,
      color: AppTheme.accentYellow,
      isGoal: true,
      icon: Icons.beach_access_rounded,
    ),
    Pocket(
      id: 'darurat',
      name: 'Dana Darurat',
      emoji: '🛡️',
      balance: 12000000.0,
      targetAmount: 30000000.0,
      color: AppTheme.primaryGreen,
      isGoal: true,
      icon: Icons.security_rounded,
    ),
    Pocket(
      id: 'laptop',
      name: 'Beli Laptop',
      emoji: '💻',
      balance: 4500000.0,
      targetAmount: 15000000.0,
      color: AppTheme.accentBlue,
      isGoal: true,
      icon: Icons.laptop_mac_rounded,
    ),
  ];

  // List transaksi awal aplikasi
  List<PocketTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _transactions = [
      PocketTransaction(
        id: 'tx1',
        pocketId: 'makanan',
        title: 'Grab Food',
        amount: -45000.0,
        time: '2 jam lalu',
        date: now.subtract(const Duration(hours: 2)),
        icon: Icons.fastfood_rounded,
      ),
      PocketTransaction(
        id: 'tx2',
        pocketId: 'utama',
        title: 'Gaji Freelance',
        amount: 1500000.0,
        time: '1 hari lalu',
        date: now.subtract(const Duration(days: 1)),
        icon: Icons.laptop_mac_rounded,
      ),
      PocketTransaction(
        id: 'tx3',
        pocketId: 'makanan',
        title: 'Indomaret',
        amount: -87000.0,
        time: '3 hari lalu',
        date: now.subtract(const Duration(days: 3)),
        icon: Icons.shopping_bag_outlined,
      ),
      PocketTransaction(
        id: 'tx4',
        pocketId: 'transport',
        title: 'Isi bensin Shell',
        amount: -100000.0,
        time: '4 hari lalu',
        date: now.subtract(const Duration(days: 4)),
        icon: Icons.local_gas_station_rounded,
      ),
      PocketTransaction(
        id: 'tx5',
        pocketId: 'darurat',
        title: 'Nabung Rutin',
        amount: 500000.0,
        time: '5 hari lalu',
        date: now.subtract(const Duration(days: 5)),
        icon: Icons.savings_rounded,
      ),
    ];
  }

  double get _totalBalance {
    return _pockets.fold(0.0, (sum, pocket) => sum + pocket.balance);
  }

  bool _hasSavedThisMonth(String pocketId) {
    final now = DateTime.now();
    return _transactions.any((tx) =>
        tx.pocketId == pocketId &&
        tx.amount > 0 && 
        tx.date.month == now.month &&
        tx.date.year == now.year);
  }

  @override
  Widget build(BuildContext context) {
    final spendingPockets = _pockets.where((p) => !p.isGoal).toList();
    final goalPockets = _pockets.where((p) => p.isGoal).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader(
                    title: 'Kantong Belanja & Bayar',
                    subtitle: '${spendingPockets.length} Kantong aktif',
                  ),
                  const SizedBox(height: 12),
                  _buildPocketsGrid(spendingPockets, isGoal: false),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionHeader(
                    title: 'Kantong Target Nabung',
                    subtitle: '${goalPockets.length} Target berjalan',
                  ),
                  const SizedBox(height: 12),
                  _buildPocketsGrid(goalPockets, isGoal: true),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
      // TOMBOL + DI TENGAH DENGAN LINGKARAN HIJAU
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(),
        backgroundColor: AppTheme.primaryGreen,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: AppTheme.bgDark, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Bottom Sheet Form Pengisian Transaksi Baru (Pengeluaran)
  void _showAddTransactionSheet() {
    final txNameController = TextEditingController();
    final txAmountController = TextEditingController();
    Pocket? selectedPocket = _pockets.first; // Default pilihan ke pocket pertama

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Catat Transaksi Baru',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Transaksi
                    const Text('Nama Transaksi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: txNameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Misal: Makan Siang Bakso, Grab',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Input Nominal Transaksi
                    const Text('Nominal Pengeluaran', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: txAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter()
                      ],
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '100.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dropdown Pemilihan Pocket
                    const Text('Pilih Kantong Sumber', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Pocket>(
                          value: selectedPocket,
                          dropdownColor: AppTheme.bgCardElevated,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                          items: _pockets.map((pocket) {
                            return DropdownMenuItem<Pocket>(
                              value: pocket,
                              child: Row(
                                children: [
                                  Text(pocket.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 10),
                                  Text(pocket.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                                  const Spacer(),
                                  Text(
                                    _formatCurrency(pocket.balance),
                                    style: TextStyle(color: pocket.color, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setSheetState(() => selectedPocket = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Konfirmasi Simpan Transaksi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = txNameController.text.trim();
                          final double? amount = double.tryParse(txAmountController.text.replaceAll('.', ''));

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harap masukkan nama transaksi')),
                            );
                            return;
                          }
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masukkan nominal yang valid')),
                            );
                            return;
                          }
                          if (amount > selectedPocket!.balance) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Saldo di ${selectedPocket!.name} tidak cukup')),
                            );
                            return;
                          }

                          setState(() {
                            // 1. Mengurangi saldo kantong yang dipilih
                            selectedPocket!.balance -= amount;

                            // 2. Memasukkan ke list histori transaksi utama
                            _transactions.insert(
                              0,
                              PocketTransaction(
                                id: DateTime.now().toString(),
                                pocketId: selectedPocket!.id,
                                title: name,
                                amount: -amount, // Negatif karena pengeluaran berkurang
                                time: 'Baru saja',
                                date: DateTime.now(),
                                icon: selectedPocket!.icon,
                              ),
                            );
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryGreen,
                              content: Text('Transaksi "$name" berhasil disimpan! Saldo berkurang.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(color: AppTheme.bgDark, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Bottom Sheet Form Pengisian Pendapatan (Pemasukan Baru)
  void _showAddIncomeSheet(Pocket mainPocket) {
    final incomeNameController = TextEditingController();
    final incomeAmountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catat Pendapatan Baru',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input Nama Pendapatan
                const Text('Sumber / Nama Pendapatan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: incomeNameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Misal: Gaji Bulanan, Bonus, Project Freelance',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCardElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),

                // Input Nominal Pendapatan
                const Text('Nominal Pemasukan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: incomeAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter()
                  ],
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '1.000.000',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: AppTheme.bgCardElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Konfirmasi Simpan Pendapatan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = incomeNameController.text.trim();
                      final double? amount = double.tryParse(incomeAmountController.text.replaceAll('.', ''));

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap masukkan nama pendapatan')),
                        );
                        return;
                      }
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Masukkan nominal yang valid')),
                        );
                        return;
                      }

                      setState(() {
                        // 1. Menambahkan saldo ke Kantong Utama
                        mainPocket.balance += amount;

                        // 2. Memasukkan ke list histori transaksi utama (Positif untuk pemasukan)
                        _transactions.insert(
                          0,
                          PocketTransaction(
                            id: DateTime.now().toString(),
                            pocketId: mainPocket.id,
                            title: name,
                            amount: amount, 
                            time: 'Baru saja',
                            date: DateTime.now(),
                            icon: Icons.monetization_on_rounded,
                          ),
                        );
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryGreen,
                          content: Text('Pendapatan "$name" berhasil dicatat! Saldo bertambah.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Simpan Pendapatan',
                      style: TextStyle(color: AppTheme.bgDark, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16251C), Color(0xFF0F1A24)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saldo Semua Kantong',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            _formatFullCurrency(_totalBalance),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStatIndicator(
                label: 'Belanja',
                amount: _pockets
                    .where((p) => !p.isGoal)
                    .fold(0.0, (s, p) => s + p.balance),
                color: AppTheme.accentBlue,
              ),
              const SizedBox(width: 24),
              _buildMiniStatIndicator(
                label: 'Tabungan',
                amount: _pockets
                    .where((p) => p.isGoal)
                    .fold(0.0, (s, p) => s + p.balance),
                color: AppTheme.accentYellow,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStatIndicator({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            Text(
              _formatCurrency(amount),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPocketsGrid(List<Pocket> pockets, {required bool isGoal}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: pockets.length + 1, 
      itemBuilder: (context, index) {
        if (index == pockets.length) {
          return _buildAddPocketCard(isGoal: isGoal);
        }

        final pocket = pockets[index];
        final bool hasSavedThisMonth = isGoal ? _hasSavedThisMonth(pocket.id) : true;

        return GestureDetector(
          onTap: () => _showPocketDetailSheet(pocket),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGoal ? pocket.color.withOpacity(0.08) : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isGoal ? pocket.color.withOpacity(0.3) : AppTheme.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: pocket.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          pocket.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    if (isGoal && !hasSavedThisMonth)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: pocket.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco_rounded, size: 12, color: pocket.color),
                            const SizedBox(width: 4),
                            Text(
                              'Yuk nabung',
                              style: TextStyle(
                                color: pocket.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(pocket.icon, color: AppTheme.textMuted, size: 16),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pocket.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(pocket.balance),
                      style: TextStyle(
                        color: pocket.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddPocketCard({required bool isGoal}) {
    return GestureDetector(
      onTap: () => _showAddPocketSheet(isGoal: isGoal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isGoal ? AppTheme.accentYellow.withOpacity(0.5) : AppTheme.borderColor,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: isGoal ? AppTheme.accentYellow : AppTheme.primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              isGoal ? 'Buat Target' : 'Tambah Kantong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isGoal ? AppTheme.accentYellow : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPocketDetailSheet(Pocket pocket) {
    final pocketTxs = _transactions.where((tx) => tx.pocketId == pocket.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: pocket.isGoal ? Border.all(color: pocket.color.withOpacity(0.5), width: 2) : null,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: pocket.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(pocket.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pocket.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              pocket.isGoal ? 'Kantong Target Nabung' : 'Kantong Belanja',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardElevated,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Saat Ini', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          _formatFullCurrency(pocket.balance),
                          style: TextStyle(
                            color: pocket.color,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            if(pocket.isGoal) {
                               _showAddMoneyToGoalSheet(pocket);
                            } else {
                               _showTransferSheet(pocket);
                            }
                          },
                          icon: Icon(pocket.isGoal ? Icons.savings_rounded : Icons.swap_horiz_rounded, size: 18),
                          label: Text(pocket.isGoal ? 'Nabung' : 'Transfer Dana'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pocket.isGoal ? pocket.color : AppTheme.bgCardElevated,
                            foregroundColor: pocket.isGoal ? AppTheme.bgDark : AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: pocket.isGoal ? BorderSide.none : const BorderSide(color: AppTheme.borderColor),
                            ),
                          ),
                        ),
                      ),
                      // JIKA INI KANTONG UTAMA, TAMBAHKAN TOMBOL UNTUK MENCATAT PENDAPATAN
                      if (pocket.id == 'utama') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddIncomeSheet(pocket);
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                            label: const Text('Tambah Dana'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: AppTheme.bgDark,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (pocket.id != 'utama') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _confirmDeletePocket(pocket);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: const Text('Hapus Kantong'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCoral.withOpacity(0.12),
                              foregroundColor: AppTheme.accentCoral,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: pocketTxs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, color: AppTheme.textMuted, size: 40),
                                const SizedBox(height: 8),
                                const Text(
                                  'Belum ada transaksi di kantong ini.',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: pocketTxs.length,
                            itemBuilder: (context, index) {
                              final tx = pocketTxs[index];
                              final bool isExpense = tx.amount < 0;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCardElevated,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(tx.icon, color: pocket.color, size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tx.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(tx.time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isExpense ? '' : '+'}${_formatCurrency(tx.amount)}',
                                      style: TextStyle(
                                        color: isExpense ? AppTheme.accentCoral : AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeletePocket(Pocket pocket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Hapus "${pocket.name}"?'),
          content: Text(
            'Seluruh saldo Anda sebesar ${_formatFullCurrency(pocket.balance)} akan otomatis ditransfer ke "Kantong Utama". Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final mainPocket = _pockets.firstWhere((p) => p.id == 'utama');
                  mainPocket.balance += pocket.balance;
                  _pockets.removeWhere((p) => p.id == pocket.id);
                  
                  for (var tx in _transactions) {
                    if (tx.pocketId == pocket.id) {
                      _transactions[_transactions.indexOf(tx)] = PocketTransaction(
                        id: tx.id,
                        pocketId: 'utama',
                        title: '${tx.title} (${pocket.name})',
                        amount: tx.amount,
                        time: tx.time,
                        date: tx.date,
                        icon: tx.icon,
                      );
                    }
                  }
                });
                Navigator.pop(context); 
                Navigator.pop(context); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.accentCoral,
                    content: Text('Kantong "${pocket.name}" berhasil dihapus & saldo dipindahkan.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
              child: const Text('Hapus & Transfer Saldo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showTransferSheet(Pocket sourcePocket) {
    final transferController = TextEditingController();
    Pocket? targetPocket = _pockets.firstWhere((p) => p.id != sourcePocket.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final eligibleTargets = _pockets.where((p) => p.id != sourcePocket.id).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transfer Antar Kantong',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStaticPocketIndicator('Dari', sourcePocket)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ke Kantong', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCardElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Pocket>(
                                    value: targetPocket,
                                    dropdownColor: AppTheme.bgCardElevated,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                                    items: eligibleTargets.map((p) {
                                      return DropdownMenuItem<Pocket>(
                                        value: p,
                                        child: Text('${p.emoji} ${p.name}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setSheetState(() => targetPocket = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Jumlah Transfer', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: transferController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter()
                      ],
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp',
                        prefixStyle: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final double? amount = double.tryParse(transferController.text.replaceAll('.', ''));
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal yang valid')));
                            return;
                          }
                          if (amount > sourcePocket.balance) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo kantong pengirim tidak cukup')));
                            return;
                          }

                          setState(() {
                            sourcePocket.balance -= amount;
                            targetPocket!.balance += amount;

                            final now = DateTime.now();
                            _transactions.insert(0, PocketTransaction(
                              id: DateTime.now().toString(),
                              pocketId: sourcePocket.id,
                              title: 'Trf ke ${targetPocket!.name}',
                              amount: -amount,
                              time: 'Baru saja',
                              date: now,
                              icon: Icons.outbox_rounded,
                            ));

                            _transactions.insert(0, PocketTransaction(
                              id: DateTime.now().toString() + '_2',
                              pocketId: targetPocket!.id,
                              title: 'Trf dari ${sourcePocket.name}',
                              amount: amount,
                              time: 'Baru saja',
                              date: now,
                              icon: Icons.move_to_inbox_rounded,
                            ));
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppTheme.primaryGreen, content: Text('Berhasil transfer ${_formatFullCurrency(amount)}!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kirim Dana', style: TextStyle(color: AppTheme.bgDark, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaticPocketIndicator(String label, Pocket pocket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgCardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Text(pocket.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pocket.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showAddMoneyToGoalSheet(Pocket goalPocket) {
    final amountController = TextEditingController();
    Pocket sourcePocket = _pockets.firstWhere((p) => p.id == 'utama');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final spendingPockets = _pockets.where((p) => !p.isGoal).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nabung: ${goalPocket.emoji} ${goalPocket.name}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    const Text('Gunakan Saldo Dari Kantong', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Pocket>(
                          value: sourcePocket,
                          dropdownColor: AppTheme.bgCardElevated,
                          isExpanded: true,
                          items: spendingPockets.map((p) {
                            return DropdownMenuItem<Pocket>(
                              value: p,
                              child: Text('${p.emoji} ${p.name} (Sisa: ${_formatCurrency(p.balance)})', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setSheetState(() => sourcePocket = val!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Jumlah Nabung', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter()
                      ],
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 150.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp',
                        prefixStyle: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final double? amount = double.tryParse(amountController.text.replaceAll('.', ''));
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal yang valid')));
                            return;
                          }
                          if (amount > sourcePocket.balance) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo di kantong sumber tidak mencukupi')));
                            return;
                          }

                          setState(() {
                            sourcePocket.balance -= amount;
                            goalPocket.balance += amount;

                            final now = DateTime.now();
                            _transactions.insert(0, PocketTransaction(
                              id: DateTime.now().toString(),
                              pocketId: sourcePocket.id,
                              title: 'Nabung untuk ${goalPocket.name}',
                              amount: -amount,
                              time: 'Baru saja',
                              date: now,
                              icon: Icons.savings_rounded,
                            ));

                            _transactions.insert(0, PocketTransaction(
                              id: DateTime.now().toString() + '_goal',
                              pocketId: goalPocket.id,
                              title: 'Nabung dari ${sourcePocket.name}',
                              amount: amount,
                              time: 'Baru saja',
                              date: now,
                              icon: Icons.savings_rounded,
                            ));
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppTheme.primaryGreen, content: Text('Ditambahkan ke "${goalPocket.name}"!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goalPocket.color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Konfirmasi Nabung', style: TextStyle(color: AppTheme.bgDark, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPocketSheet({required bool isGoal}) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final targetController = TextEditingController();
    Color selectedColor = isGoal ? AppTheme.accentYellow : AppTheme.primaryGreen;
    String selectedEmoji = isGoal ? '🏝️' : '📁';

    final colors = [AppTheme.primaryGreen, AppTheme.accentBlue, AppTheme.primaryPurple, AppTheme.accentYellow, AppTheme.accentCoral];
    final emojis = ['📁', '🍲', '🚌', '🎮', '💡', '🏝️', '🏠', '📈', '🎁', '🩺'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7, 
                decoration: const BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isGoal ? 'Buat Target Nabung Baru' : 'Buat Kantong Belanja Baru', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppTheme.textSecondary))
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(isGoal ? 'Nama Target' : 'Nama Kantong', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: isGoal ? 'Misal: Beli Motor, Dana Haji' : 'Misal: Makan Siang, Kost',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Saldo Awal (Rp)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: balanceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ThousandsSeparatorInputFormatter()
                                ],
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                                  filled: true,
                                  fillColor: AppTheme.bgCardElevated,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isGoal) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Target Nabung (Rp)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: targetController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ThousandsSeparatorInputFormatter()
                                  ],
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: '1.000.000',
                                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                                    filled: true,
                                    fillColor: AppTheme.bgCardElevated,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Pilih Emoji', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: emojis.map((emo) {
                          final isSelected = emo == selectedEmoji;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedEmoji = emo),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? selectedColor.withOpacity(0.2) : AppTheme.bgCardElevated,
                                border: Border.all(color: isSelected ? selectedColor : AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: Text(emo, style: const TextStyle(fontSize: 18))),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Pilih Tema Warna', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: colors.map((col) {
                        final isSelected = col == selectedColor;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedColor = col),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final double initialBalance = double.tryParse(balanceController.text.replaceAll('.', '')) ?? 0.0;
                          final double? targetAmt = isGoal ? (double.tryParse(targetController.text.replaceAll('.', '')) ?? 1000000.0) : null;

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi Nama')));
                            return;
                          }

                          setState(() {
                            _pockets.add(Pocket(
                              id: DateTime.now().toString(),
                              name: name,
                              emoji: selectedEmoji,
                              balance: initialBalance,
                              color: selectedColor,
                              isGoal: isGoal,
                              targetAmount: targetAmt,
                              icon: isGoal ? Icons.savings_outlined : Icons.account_balance_wallet_outlined,
                            ));
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryGreen,
                              content: Text(isGoal ? 'Target "$name" Berhasil Dibuat!' : 'Kantong "$name" Berhasil Ditambahkan!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Simpan ${isGoal ? 'Target' : 'Kantong'}',
                          style: TextStyle(color: selectedColor == AppTheme.accentYellow ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
        color: AppTheme.bgCard,
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
          if (i == 1) return; // Slot kosong untuk ditumpuk FAB Lingkaran
          if (i == 2) Navigator.pushNamed(context, '/reports');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
        ],
      ),
    );
  }

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

  String _formatFullCurrency(double amount) {
    final abs = amount.abs();
    final valueString = abs.toStringAsFixed(0);
    final valueChars = valueString.split('');
    var result = '';
    var count = 0;
    for (var i = valueChars.length - 1; i >= 0; i--) {
      result = valueChars[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.' + result;
        count = 0;
      }
    }
    return 'Rp$result';
  }
}

// FORMATTER KUSTOM UNTUK SEPARATOR RIBUAN (TITIK) SECARA REAL-TIME
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Bersihkan string dari titik yang ada sebelum memformat ulang
    String cleanText = newValue.text.replaceAll('.', '');
    
    // Format ulang string dengan titik setiap 3 digit dari belakang
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final valueChars = cleanText.split('');
    var result = '';
    var count = 0;
    
    for (var i = valueChars.length - 1; i >= 0; i--) {
      result = valueChars[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.' + result;
        count = 0;
      }
    }

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}