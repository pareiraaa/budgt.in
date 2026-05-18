import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/app_theme.dart';

class BudgetAllocationPage extends StatefulWidget {
  const BudgetAllocationPage({super.key});

  @override
  State<BudgetAllocationPage> createState() => _BudgetAllocationPageState();
}

class _BudgetAllocationPageState extends State<BudgetAllocationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Mock total income — replace with state/provider
  final double _totalIncome = 5000000;

  final List<_AllocationItem> _allocations = [
    _AllocationItem(name: 'Kebutuhan Pribadi', type: 'Pribadi', amount: 2000000, color: AppTheme.primaryGreen, icon: Icons.person_outline_rounded),
    _AllocationItem(name: 'Biaya Keluarga', type: 'Keluarga', amount: 1500000, color: AppTheme.accentYellow, icon: Icons.people_outline_rounded),
    _AllocationItem(name: 'Tabungan', type: 'Saving', amount: 1000000, color: AppTheme.accentBlue, icon: Icons.savings_outlined),
    _AllocationItem(name: 'Hiburan', type: 'Pribadi', amount: 500000, color: AppTheme.primaryPurple, icon: Icons.movie_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double get _totalAllocated => _allocations.fold(0, (sum, a) => sum + a.amount);
  double get _remaining => _totalIncome - _totalAllocated;

  void _showAddEditSheet({_AllocationItem? item, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AllocationFormSheet(
        existingItem: item,
        onSave: (newItem) {
          setState(() {
            if (index != null) {
              _allocations[index] = newItem;
            } else {
              _allocations.add(newItem);
            }
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _deleteAllocation(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Alokasi?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Alokasi "${_allocations[index].name}" akan dihapus.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _allocations.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.accentCoral)),
          ),
        ],
      ),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildDonutChart(),
                      const SizedBox(height: 28),
                      _buildAllocationList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.bgDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Alokasi', style: TextStyle(fontWeight: FontWeight.w700)),
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
                Text('Alokasi Budget', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                Text('Atur pembagian dana otomatis', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isOver = _remaining < 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOver
              ? [AppTheme.accentCoral.withOpacity(0.2), AppTheme.accentCoral.withOpacity(0.05)]
              : [AppTheme.primaryGreen.withOpacity(0.15), AppTheme.accentBlue.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver ? AppTheme.accentCoral.withOpacity(0.4) : AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Gaji', _totalIncome, AppTheme.textPrimary),
              _buildSummaryItem('Dialokasikan', _totalAllocated, AppTheme.accentYellow),
              _buildSummaryItem('Sisa', _remaining, isOver ? AppTheme.accentCoral : AppTheme.primaryGreen),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_totalAllocated / _totalIncome).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.bgCard,
              valueColor: AlwaysStoppedAnimation(
                isOver ? AppTheme.accentCoral : AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOver
                ? '⚠️ Alokasi melebihi total gaji!'
                : '${((_totalAllocated / _totalIncome) * 100).toStringAsFixed(0)}% dari gaji telah dialokasikan',
            style: TextStyle(
              color: isOver ? AppTheme.accentCoral : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: -0.3),
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    if (_allocations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distribusi Alokasi', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _DonutChartPainter(_allocations, _totalAllocated),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_allocations.length}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                        const Text('Pos', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _allocations.map((a) => _buildLegendItem(a)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(_AllocationItem item) {
    final percent = _totalAllocated > 0 ? (item.amount / _totalAllocated * 100).toStringAsFixed(0) : '0';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(child: Text(item.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
          Text('$percent%', style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildAllocationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Daftar Alokasi', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
            const Spacer(),
            Text('${_allocations.length} pos', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 14),
        ..._allocations.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return _buildAllocationCard(item, idx);
        }).toList(),
        if (_allocations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, color: AppTheme.textMuted, size: 48),
                  const SizedBox(height: 12),
                  const Text('Belum ada alokasi', style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAllocationCard(_AllocationItem item, int index) {
    final percent = _totalIncome > 0 ? (item.amount / _totalIncome * 100) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.type, style: TextStyle(color: item.color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(item.amount),
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: AppTheme.bgCardElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 18),
                onSelected: (val) {
                  if (val == 'edit') _showAddEditSheet(item: item, index: index);
                  if (val == 'delete') _deleteAllocation(index);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 16), SizedBox(width: 8), Text('Edit', style: TextStyle(color: AppTheme.textPrimary))])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppTheme.accentCoral, size: 16), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppTheme.accentCoral))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 5,
                    backgroundColor: AppTheme.bgCardElevated,
                    valueColor: AlwaysStoppedAnimation(item.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${percent.toStringAsFixed(0)}%', style: TextStyle(color: item.color, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
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

// ─── Data Model ────────────────────────────────────────────────────────────────

class _AllocationItem {
  String name;
  String type;
  double amount;
  Color color;
  IconData icon;

  _AllocationItem({
    required this.name,
    required this.type,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

// ─── Donut Chart Painter ───────────────────────────────────────────────────────

class _DonutChartPainter extends CustomPainter {
  final List<_AllocationItem> items;
  final double total;

  _DonutChartPainter(this.items, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.38;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -1.5708;
    for (final item in items) {
      final sweep = total > 0 ? (item.amount / total) * 2 * 3.14159 : 0.0;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep - 0.04, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => true;
}

// ─── Bottom Sheet Form ─────────────────────────────────────────────────────────

class _AllocationFormSheet extends StatefulWidget {
  final _AllocationItem? existingItem;
  final Function(_AllocationItem) onSave;

  const _AllocationFormSheet({this.existingItem, required this.onSave});

  @override
  State<_AllocationFormSheet> createState() => _AllocationFormSheetState();
}

class _AllocationFormSheetState extends State<_AllocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String _selectedType = 'Pribadi';
  Color _selectedColor = AppTheme.primaryGreen;

  final _types = ['Pribadi', 'Keluarga', 'Saving', 'Investasi'];
  final _colors = [
    AppTheme.primaryGreen, AppTheme.accentYellow, AppTheme.accentBlue,
    AppTheme.primaryPurple, AppTheme.accentCoral,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingItem != null ? widget.existingItem!.amount.toStringAsFixed(0) : '',
    );
    _selectedType = widget.existingItem?.type ?? 'Pribadi';
    _selectedColor = widget.existingItem?.color ?? AppTheme.primaryGreen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.existingItem == null ? 'Tambah Alokasi' : 'Edit Alokasi',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Nama Alokasi', prefixIcon: Icon(Icons.label_outline_rounded)),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixIcon: Icon(Icons.attach_money_rounded)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                  if ((double.tryParse(v) ?? 0) <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text('Tipe', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types.map((t) => ChoiceChip(
                  label: Text(t),
                  selected: _selectedType == t,
                  onSelected: (_) => setState(() => _selectedType = t),
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: _selectedType == t ? AppTheme.primaryGreen : AppTheme.textSecondary,
                    fontWeight: _selectedType == t ? FontWeight.w700 : FontWeight.w400,
                  ),
                  side: BorderSide(color: _selectedType == t ? AppTheme.primaryGreen : AppTheme.borderColor),
                )).toList(),
              ),
              const SizedBox(height: 14),
              const Text('Warna', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: _colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == c ? AppTheme.textPrimary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: _selectedColor == c
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(_AllocationItem(
                        name: _nameController.text,
                        type: _selectedType,
                        amount: double.parse(_amountController.text),
                        color: _selectedColor,
                        icon: Icons.label_rounded,
                      ));
                    }
                  },
                  child: Text(widget.existingItem == null ? 'Tambah' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}