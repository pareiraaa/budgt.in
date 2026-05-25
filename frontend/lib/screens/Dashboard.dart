import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/app_theme.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/profile_services.dart';
import 'package:frontend/services/pocket_services.dart';
import 'package:frontend/services/transaction_services.dart';
import 'package:http/http.dart' as http;

// Model data untuk Pocket (Kantong)
class Pocket {
  final String id;
  String name;
  String emoji;
  double balance;
  Color color;
  final bool isGoal;
  final String pocketType;
  double? targetAmount;
  DateTime? deadline;
  DateTime? createdAt;
  IconData icon;

  Pocket({
    required this.id,
    required this.name,
    required this.emoji,
    required this.balance,
    required this.color,
    required this.isGoal,
    required this.pocketType,
    this.targetAmount,
    this.deadline,
    this.createdAt,
    required this.icon,
  });

  factory Pocket.fromJson(Map<String, dynamic> json) {
    final String type = json['pocketType'] ?? 'Spending';

    String emoji;
    Color color;
    IconData icon;

    switch (type) {
      case 'Main':
        emoji = '💳';
        color = AppTheme.primaryGreen;
        icon = Icons.account_balance_wallet_rounded;
        break;
      case 'Goal':
        emoji = '🎯';
        color = AppTheme.accentYellow;
        icon = Icons.savings_rounded;
        break;
      default: // Spending
        emoji = '🛒';
        color = AppTheme.accentBlue;
        icon = Icons.shopping_bag_rounded;
    }

    return Pocket(
      id: json['id'].toString(), // angka -> String
      name: json['pocketName'] ?? '', // pocketName -> name
      emoji: emoji,
      balance: (json['balance'] ?? 0).toDouble(), // pastiin double
      color: color,
      isGoal: type == 'Goal', // "Goal" -> true
      pocketType: type,
      targetAmount: json['targetAmount'] != null
          ? (json['targetAmount']).toDouble()
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])?.toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])?.toLocal()
          : null,
      icon: icon,
    );
  }
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m'; // contoh: 14:30
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

  factory PocketTransaction.fromBackend(Map<String, dynamic> json) {
    final String type = json['type'] ?? 'Expense';
    final bool isExpense = type == 'Expense';
    final double rawAmount = (json['amount'] ?? 0).toDouble();

    return PocketTransaction(
      id: json['id'].toString(),
      pocketId: json['pocketId'].toString(),
      title: (json['note'] != null && json['note'].toString().trim().isNotEmpty)
          ? json['note']
          : (json['incomeSource'] != null &&
                json['incomeSource'].toString().trim().isNotEmpty)
          ? json['incomeSource']
          : (isExpense ? 'Pengeluaran' : 'Pemasukan'),
      amount: isExpense ? -rawAmount : rawAmount,
      time: _formatTime(
        (DateTime.tryParse(json['date'] ?? '')?.toLocal()) ?? DateTime.now(),
      ),
      date:
          (DateTime.tryParse(json['date'] ?? '')?.toLocal()) ?? DateTime.now(),
      icon: isExpense
          ? Icons.arrow_upward_rounded
          : Icons.arrow_downward_rounded,
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Daftar Pocket Utama & Pengeluaran (Spending Pockets)
  List<Pocket> _pockets = [];
  bool _isLoadingPocket = true;

  // List transaksi awal aplikasi
  List<PocketTransaction> _transactions = [];

  String _username = '';

  @override
  void initState() {
    super.initState();

    _transactions = [];

    _loadProfile();
    _loadPockets();
    _loadTransactions();
  }

  double get _totalBalance {
    return _pockets.fold(0.0, (sum, pocket) => sum + pocket.balance);
  }

  // true kalau target nabung bulan ini UDAH tercapai (notif mati)
  bool _hasSavedThisMonth(Pocket goal) {
    final saran = _savingSuggestion(goal);
    if (saran == null) return true; // gak ada target/deadline -> gak usah notif
    final sisa = saran - _savedThisMonth(goal);
    return sisa <= 0; // udah penuhin jatah bulan ini
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.getProfile();
      if (mounted) {
        setState(() {
          _username = data['username'] ?? '';
        });
      }
    } catch (e) {
      // kalau gagal, biarin nama kosong / pakai default
    }
  }

  Future<void> _loadPockets() async {
    try {
      final pockets = await PocketService.getPockets();
      if (mounted) {
        setState(() {
          _pockets = pockets;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat kantong: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final raw = await TransactionService.getTransactions();
      final txs = raw
          .where((e) => (e['status'] ?? 'Active') == 'Active')
          .map((e) => PocketTransaction.fromBackend(e))
          .toList();
      if (mounted) {
        setState(() {
          _transactions = txs;
        });
      }
    } catch (e) {
      // kalau gagal, biarin transaksi kosong
    }
  }

  Map<String, List<PocketTransaction>> _groupByDate(
    List<PocketTransaction> txs,
  ) {
    final Map<String, List<PocketTransaction>> grouped = {};
    for (final tx in txs) {
      final key =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  String _formatDateHeader(DateTime dt) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final kemarin = now.subtract(const Duration(days: 1));
    final isKemarin =
        dt.year == kemarin.year &&
        dt.month == kemarin.month &&
        dt.day == kemarin.day;

    if (isToday) return 'Hari Ini';
    if (isKemarin) return 'Kemarin';
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  Widget _buildTransactionItem(
    PocketTransaction tx,
    Pocket pocket,
    void Function(void Function()) setSheetState,
    List<PocketTransaction> pocketTxs,
  ) {
    final bool isExpense = tx.amount < 0;
    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.accentCoral,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        try {
          await TransactionService.voidTransaction(tx.id);
          if (context.mounted) Navigator.pop(context); // tutup sheet
          await _loadPockets();
          await _loadTransactions();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppTheme.accentCoral,
                content: Text('Transaksi dibatalkan & saldo dikembalikan.'),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCardElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.time,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
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
      ),
    );
  }

  double? _savingSuggestion(Pocket goal) {
    if (goal.targetAmount == null || goal.deadline == null) return null;

    final mulai = goal.createdAt ?? DateTime.now();
    // total bulan dari goal dibuat sampai deadline (minimal 1)
    int totalBulan =
        (goal.deadline!.year - mulai.year) * 12 +
        (goal.deadline!.month - mulai.month);
    if (totalBulan < 1) totalBulan = 1;

    return goal.targetAmount! / totalBulan;
  }

  double _savedThisMonth(Pocket goal) {
    final now = DateTime.now();
    return _transactions
        .where(
          (tx) =>
              tx.pocketId == goal.id &&
              tx.amount > 0 && // masuk (positif)
              tx.date.month == now.month &&
              tx.date.year == now.year,
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
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
    Pocket? selectedPocket = _pockets.first;
    DateTime selectedDateTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Transaksi
                    const Text(
                      'Nama Transaksi',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: txNameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Misal: Makan Siang Bakso, Grab',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Input Nominal Transaksi
                    const Text(
                      'Nominal Pengeluaran',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: txAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '100.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dropdown Pemilihan Pocket
                    const Text(
                      'Pilih Kantong Sumber',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
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
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textSecondary,
                          ),
                          items: _pockets.map((pocket) {
                            return DropdownMenuItem<Pocket>(
                              value: pocket,
                              child: Row(
                                children: [
                                  Text(
                                    pocket.emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    pocket.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatCurrency(pocket.balance),
                                    style: TextStyle(
                                      color: pocket.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                    const SizedBox(height: 18),
                    const Text(
                      'Tanggal & Waktu',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate == null) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (pickedTime == null) return;
                        setSheetState(() {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCardElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} '
                              '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Konfirmasi Simpan Transaksi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = txNameController.text.trim();
                          final int? amount = int.tryParse(
                            txAmountController.text.replaceAll('.', ''),
                          );

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap masukkan nama transaksi'),
                              ),
                            );
                            return;
                          }
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan nominal yang valid'),
                              ),
                            );
                            return;
                          }

                          try {
                            await TransactionService.createExpense(
                              amount: amount,
                              pocketId: selectedPocket!.id,
                              note: name,
                              date: selectedDateTime,
                            );
                            if (context.mounted) Navigator.pop(context);
                            await _loadPockets();
                            await _loadTransactions();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text('Transaksi "$name" disimpan!'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
    DateTime selectedDateTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input Nama Pendapatan
                const Text(
                  'Sumber / Nama Pendapatan',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: incomeNameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Misal: Gaji Bulanan, Bonus, Project Freelance',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCardElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Input Nominal Pendapatan
                const Text(
                  'Nominal Pemasukan',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: incomeAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '1.000.000',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: AppTheme.bgCardElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Konfirmasi Simpan Pendapatan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = incomeNameController.text.trim();
                      final int? amount = int.tryParse(
                        incomeAmountController.text.replaceAll('.', ''),
                      );

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap masukkan nama pendapatan'),
                          ),
                        );
                        return;
                      }
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan nominal yang valid'),
                          ),
                        );
                        return;
                      }

                      try {
                        await TransactionService.createIncome(
                          amount: amount,
                          incomeSource: name,
                          date: selectedDateTime,
                        );
                        if (context.mounted) Navigator.pop(context);
                        await _loadPockets();
                        await _loadTransactions();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryGreen,
                              content: Text(
                                'Pendapatan "$name" dicatat! Saldo Main bertambah.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Pendapatan',
                      style: TextStyle(
                        color: AppTheme.bgDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_username.isEmpty ? '...' : _username[0].toUpperCase() + _username.substring(1)}! 👋',
                style: const TextStyle(
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
              child: Center(
                child: Text(
                  _username.isEmpty ? '?' : _username[0].toUpperCase(),
                  style: const TextStyle(
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
          ),
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
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              _formatCurrency(amount),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
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
        final bool hasSavedThisMonth = isGoal
            ? _hasSavedThisMonth(pocket)
            : true;

        return GestureDetector(
          onTap: () => _showPocketDetailSheet(pocket),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGoal ? pocket.color.withOpacity(0.08) : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isGoal
                    ? pocket.color.withOpacity(0.3)
                    : AppTheme.borderColor,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: pocket.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 12,
                              color: pocket.color,
                            ),
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
            color: isGoal
                ? AppTheme.accentYellow.withOpacity(0.5)
                : AppTheme.borderColor,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: isGoal ? AppTheme.accentYellow : AppTheme.primaryGreen,
              size: 28,
            ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final pocketTxs = _transactions
                .where((tx) => tx.pocketId == pocket.id)
                .toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: pocket.isGoal
                    ? Border.all(color: pocket.color.withOpacity(0.5), width: 2)
                    : null,
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
                          child: Text(
                            pocket.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
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
                              pocket.isGoal
                                  ? 'Kantong Target Nabung'
                                  : 'Kantong Belanja',
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
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                        ),
                      ),
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
                        const Text(
                          'Saldo Saat Ini',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
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
                  // Saran nabung (cuma buat goal yang punya target & deadline)
                  if (pocket.isGoal && _savingSuggestion(pocket) != null) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final saranBulanan = _savingSuggestion(pocket)!;
                        final udahNabung = _savedThisMonth(pocket);
                        final sisaBulanIni = (saranBulanan - udahNabung).clamp(
                          0,
                          double.infinity,
                        );
                        final targetTercapai =
                            pocket.targetAmount != null &&
                            pocket.balance >= pocket.targetAmount!;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pocket.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: pocket.color.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: pocket.color,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: targetTercapai
                                    ? Text(
                                        'Target tercapai! 🎉',
                                        style: TextStyle(
                                          color: pocket.color,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Saran: ${_formatFullCurrency(saranBulanan)}/bulan',
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            sisaBulanIni <= 0
                                                ? 'Target bulan ini sudah tercapai 👍'
                                                : 'Sisa bulan ini: ${_formatFullCurrency(sisaBulanIni.toDouble())}',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            final isAchieved = pocket.isGoal &&
                                pocket.targetAmount != null &&
                                pocket.balance >= pocket.targetAmount!;

                            if (pocket.isGoal) {
                              if (isAchieved) {
                                _showWithdrawGoalSheet(pocket);
                              } else {
                                _showAddMoneyToGoalSheet(pocket);
                              }
                            } else {
                              _showTransferSheet(pocket);
                            }
                          },
                          icon: Icon(
                            pocket.isGoal
                                ? Icons.savings_rounded
                                : Icons.swap_horiz_rounded,
                            size: 18,
                          ),
                          label: Text(
                            pocket.isGoal
                                ? (pocket.targetAmount != null && pocket.balance >= pocket.targetAmount!
                                    ? 'Withdraw'
                                    : 'Nabung')
                                : 'Transfer Dana',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pocket.isGoal
                                ? pocket.color
                                : AppTheme.bgCardElevated,
                            foregroundColor: pocket.isGoal
                                ? AppTheme.bgDark
                                : AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: pocket.isGoal
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: AppTheme.borderColor,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      // JIKA INI KANTONG UTAMA, TAMBAHKAN TOMBOL UNTUK MENCATAT PENDAPATAN
                      if (pocket.pocketType == 'Main') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddIncomeSheet(pocket);
                            },
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                            ),
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
                      if (pocket.pocketType != 'Main') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _confirmDeletePocket(pocket);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Hapus Kantong'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCoral.withOpacity(
                                0.12,
                              ),
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
                                Icon(
                                  Icons.history,
                                  color: AppTheme.textMuted,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Belum ada transaksi di kantong ini.',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final grouped = _groupByDate(pocketTxs);
                              final sortedKeys = grouped.keys.toList()
                                ..sort((a, b) => b.compareTo(a));
                              for (final k in grouped.keys) {
                                grouped[k]!.sort(
                                  (a, b) => b.date.compareTo(a.date),
                                ); // jam terbaru dulu
                              }

                              return ListView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  for (final key in sortedKeys) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _formatDateHeader(
                                          grouped[key]!.first.date,
                                        ),
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    for (final tx in grouped[key]!)
                                      _buildTransactionItem(
                                        tx,
                                        pocket,
                                        setSheetState,
                                        pocketTxs,
                                      ),
                                  ],
                                ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Hapus "${pocket.name}"?'),
          content: Text(
            'Seluruh saldo Anda sebesar ${_formatFullCurrency(pocket.balance)} akan otomatis ditransfer ke "Kantong Utama". Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await PocketService.deletePocket(pocket.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                  await _loadPockets();
                  await _loadTransactions();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.accentCoral,
                        content: Text(
                          'Kantong "${pocket.name}" dihapus & saldo dipindah ke Main.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // tutup dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCoral,
              ),
              child: const Text(
                'Hapus & Transfer Saldo',
                style: TextStyle(color: Colors.white),
              ),
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
            final eligibleTargets = _pockets
                .where((p) => p.id != sourcePocket.id)
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStaticPocketIndicator(
                            'Dari',
                            sourcePocket,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ke Kantong',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCardElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Pocket>(
                                    value: targetPocket,
                                    dropdownColor: AppTheme.bgCardElevated,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppTheme.textSecondary,
                                    ),
                                    items: eligibleTargets.map((p) {
                                      return DropdownMenuItem<Pocket>(
                                        value: p,
                                        child: Text(
                                          '${p.emoji} ${p.name}',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 13,
                                          ),
                                        ),
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
                    const Text(
                      'Jumlah Transfer',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: transferController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp',
                        prefixStyle: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final double? amount = double.tryParse(
                            transferController.text.replaceAll('.', ''),
                          );
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan nominal yang valid'),
                              ),
                            );
                            return;
                          }

                          try {
                            await PocketService.transferPocket(
                              fromPocketId: sourcePocket.id,
                              toPocketId: targetPocket!.id,
                              amount: amount,
                            );
                            if (context.mounted) Navigator.pop(context);
                            await _loadPockets();
                            await _loadTransactions();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text(
                                    'Berhasil transfer ${_formatFullCurrency(amount)}!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kirim Dana',
                          style: TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildStaticPocketIndicator(String label, Pocket pocket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
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
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddMoneyToGoalSheet(Pocket goalPocket) {
    final amountController = TextEditingController();
    final spendingPocketsList = _pockets.where((p) => !p.isGoal).toList();

    if (spendingPocketsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada kantong sumber untuk menabung'),
        ),
      );
      return;
    }

    Pocket sourcePocket = spendingPocketsList.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final spendingPockets = _pockets.where((p) => !p.isGoal).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                    Text(
                      'Nabung: ${goalPocket.emoji} ${goalPocket.name}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Gunakan Saldo Dari Kantong',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
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
                              child: Text(
                                '${p.emoji} ${p.name} (Sisa: ${_formatCurrency(p.balance)})',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setSheetState(() => sourcePocket = val!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jumlah Nabung',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 150.000',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp',
                        prefixStyle: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final double? amount = double.tryParse(
                            amountController.text.replaceAll('.', ''),
                          );
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan nominal yang valid'),
                              ),
                            );
                            return;
                          }

                          try {
                            await PocketService.transferPocket(
                              fromPocketId: sourcePocket.id,
                              toPocketId: goalPocket.id,
                              amount: amount,
                            );
                            if (context.mounted) Navigator.pop(context);
                            await _loadPockets();
                            await _loadTransactions();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text(
                                    'Berhasil nabung ke "${goalPocket.name}"!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goalPocket.color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi Nabung',
                          style: TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.bold,
                          ),
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

  void _showWithdrawGoalSheet(Pocket goalPocket) {
    final amountController = TextEditingController();
    final otherPockets = _pockets.where((p) => !p.isGoal && p.pocketType != 'Main').toList();
    Pocket? selectedCoverPocket;

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
                        Text(
                          'Withdraw: ${goalPocket.name}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      'Saldo: Rp ${goalPocket.balance.toStringAsFixed(0)}  •  Target: Rp ${goalPocket.targetAmount?.toStringAsFixed(0) ?? '-'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    const Text('Nominal yang dipakai', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        final amount = double.tryParse(val.replaceAll('.', '')) ?? 0;
                        final shortage = amount - goalPocket.balance;
                        setSheetState(() => selectedCoverPocket = shortage > 0 ? selectedCoverPocket : null);
                      },
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                      final shortage = amount - goalPocket.balance;
                      if (shortage <= 0 || otherPockets.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kurang Rp ${shortage.toStringAsFixed(0)} — pilih pocket untuk nalangin:',
                            style: const TextStyle(color: AppTheme.accentCoral, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Pocket>(
                            value: selectedCoverPocket,
                            dropdownColor: AppTheme.bgCard,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.bgCardElevated,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            hint: const Text('Pilih pocket', style: TextStyle(color: AppTheme.textMuted)),
                            items: otherPockets.map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.emoji} ${p.name} (Rp ${p.balance.toStringAsFixed(0)})', style: const TextStyle(color: AppTheme.textPrimary)),
                            )).toList(),
                            onChanged: (p) => setSheetState(() => selectedCoverPocket = p),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = int.tryParse(amountController.text.replaceAll('.', ''));
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masukkan nominal yang valid')),
                            );
                            return;
                          }

                          final shortage = amount - goalPocket.balance;
                          final needsCover = shortage > 0;

                          if (needsCover && selectedCoverPocket == null && otherPockets.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih pocket untuk nalangin kekurangannya')),
                            );
                            return;
                          }

                          try {
                            final body = {
                              'usedAmount': amount,
                              if (needsCover && selectedCoverPocket != null)
                                'coverFromPocketId': int.parse(selectedCoverPocket!.id),
                            };

                            final res = await http.post(
                              Uri.parse('${ApiClient.baseUrl}/goals/${goalPocket.id}/settle'),
                              headers: await ApiClient.headers(authorized: true),
                              body: jsonEncode(body),
                            );

                            if (res.statusCode == 200 || res.statusCode == 201) {
                              if (context.mounted) Navigator.pop(context);
                              await _loadPockets();
                              await _loadTransactions();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.primaryGreen,
                                    content: Text('Goal "${goalPocket.name}" berhasil di-withdraw!'),
                                  ),
                                );
                              }
                            } else {
                              final data = jsonDecode(res.body);
                              throw Exception(data['message'] ?? 'Gagal withdraw');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCoral,
                          foregroundColor: AppTheme.bgDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w700)),
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
    final targetController = TextEditingController();
    Color selectedColor = isGoal
        ? AppTheme.accentYellow
        : AppTheme.primaryGreen;
    String selectedEmoji = isGoal ? '🏝️' : '📁';
    DateTime? selectedDeadline;

    final colors = [
      AppTheme.primaryGreen,
      AppTheme.accentBlue,
      AppTheme.primaryPurple,
      AppTheme.accentYellow,
      AppTheme.accentCoral,
    ];
    final emojis = [
      '📁',
      '🍲',
      '🚌',
      '🎮',
      '💡',
      '🏝️',
      '🏠',
      '📈',
      '🎁',
      '🩺',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                        Text(
                          isGoal
                              ? 'Buat Target Nabung Baru'
                              : 'Buat Kantong Belanja Baru',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isGoal ? 'Nama Target' : 'Nama Kantong',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: isGoal
                            ? 'Misal: Beli Motor, Dana Haji'
                            : 'Misal: Makan Siang, Kost',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgCardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (isGoal) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Target Nabung (Rp)',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '1.000.000',
                          hintStyle: const TextStyle(color: AppTheme.textMuted),
                          filled: true,
                          fillColor: AppTheme.bgCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deadline',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDeadline = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                selectedDeadline == null
                                    ? 'Pilih tanggal target'
                                    : '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}',
                                style: TextStyle(
                                  color: selectedDeadline == null
                                      ? AppTheme.textMuted
                                      : AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Emoji',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: emojis.map((emo) {
                          final isSelected = emo == selectedEmoji;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedEmoji = emo),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withOpacity(0.2)
                                    : AppTheme.bgCardElevated,
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : AppTheme.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  emo,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Tema Warna',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final double? targetAmt = isGoal
                              ? (double.tryParse(
                                      targetController.text.replaceAll('.', ''),
                                    ) ??
                                    1000000.0)
                              : null;

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harap isi Nama')),
                            );
                            return;
                          }

                          try {
                            await PocketService.createPocket(
                              name: name,
                              pocketType: isGoal ? 'Goal' : 'Spending',
                              targetAmount: targetAmt,
                              deadline: selectedDeadline?.toIso8601String(),
                            );
                            if (context.mounted) Navigator.pop(context);
                            await _loadPockets(); // refresh daftar dari backend
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text(
                                    isGoal
                                        ? 'Target "$name" dibuat!'
                                        : 'Kantong "$name" ditambahkan!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Simpan ${isGoal ? 'Target' : 'Kantong'}',
                          style: TextStyle(
                            color: selectedColor == AppTheme.accentYellow
                                ? Colors.black87
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
