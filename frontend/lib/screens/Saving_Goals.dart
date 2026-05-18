import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/app_theme.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  State<SavingGoalsPage> createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<_SavingGoal> _goals = [
    _SavingGoal(
      name: 'Beli Laptop',
      emoji: '💻',
      targetAmount: 15000000,
      savedAmount: 4500000,
      deadline: DateTime(2025, 12, 31),
      color: AppTheme.accentBlue,
    ),
    _SavingGoal(
      name: 'Dana Darurat',
      emoji: '🛡️',
      targetAmount: 30000000,
      savedAmount: 12000000,
      deadline: DateTime(2026, 6, 30),
      color: AppTheme.primaryGreen,
    ),
    _SavingGoal(
      name: 'Liburan Bali',
      emoji: '🏖️',
      targetAmount: 5000000,
      savedAmount: 3200000,
      deadline: DateTime(2025, 8, 15),
      color: AppTheme.accentYellow,
    ),
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

  void _showAddGoalSheet({_SavingGoal? goal, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _GoalFormSheet(
        existingGoal: goal,
        onSave: (newGoal) {
          setState(() {
            if (index != null) {
              _goals[index] = newGoal;
            } else {
              _goals.add(newGoal);
            }
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAddFundsSheet(_SavingGoal goal, int index) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Tambah Dana ke "${goal.name}"',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                labelText: 'Jumlah Dana',
                prefixText: 'Rp  ',
                prefixStyle: TextStyle(color: AppTheme.primaryGreen, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(controller.text) ?? 0;
                  if (amount > 0) {
                    setState(() {
                      _goals[index] = _SavingGoal(
                        name: goal.name,
                        emoji: goal.emoji,
                        targetAmount: goal.targetAmount,
                        savedAmount: (goal.savedAmount + amount).clamp(0, goal.targetAmount),
                        deadline: goal.deadline,
                        color: goal.color,
                      );
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Tambah Dana'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                      _buildSummaryRow(),
                      const SizedBox(height: 28),
                      _buildGoalsList(),
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
        onPressed: () => _showAddGoalSheet(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.bgDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Target Baru', style: TextStyle(fontWeight: FontWeight.w700)),
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
                Text('Target Tabungan', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                Text('Rencanakan masa depanmu 🚀', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final totalTarget = _goals.fold(0.0, (s, g) => s + g.targetAmount);
    final totalSaved = _goals.fold(0.0, (s, g) => s + g.savedAmount);
    final achieved = _goals.where((g) => g.savedAmount >= g.targetAmount).length;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Target', _formatCurrency(totalTarget), AppTheme.primaryPurple, Icons.flag_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Total Tersimpan', _formatCurrency(totalSaved), AppTheme.primaryGreen, Icons.savings_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Tercapai', '$achieved/${_goals.length}', AppTheme.accentYellow, Icons.emoji_events_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Belum Ada Target', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Yuk buat target tabunganmu!', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target Aktif', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 14),
        ..._goals.asMap().entries.map((entry) {
          return _buildGoalCard(entry.value, entry.key);
        }).toList(),
      ],
    );
  }

  Widget _buildGoalCard(_SavingGoal goal, int index) {
    final progress = (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final recommendation = _calcRecommendation(goal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? goal.color.withOpacity(0.5) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: goal.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(goal.emoji, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(goal.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(width: 8),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: goal.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Selesai! 🎉', style: TextStyle(color: goal.color, fontSize: 10, fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            daysLeft > 0 ? '$daysLeft hari lagi' : 'Sudah lewat deadline',
                            style: TextStyle(
                              color: daysLeft < 30 ? AppTheme.accentCoral : AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: AppTheme.bgCardElevated,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 18),
                      onSelected: (val) {
                        if (val == 'edit') _showAddGoalSheet(goal: goal, index: index);
                        if (val == 'delete') setState(() => _goals.removeAt(index));
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 16), SizedBox(width: 8), Text('Edit', style: TextStyle(color: AppTheme.textPrimary))])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppTheme.accentCoral, size: 16), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppTheme.accentCoral))])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(goal.savedAmount),
                      style: TextStyle(color: goal.color, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    Text(
                      _formatCurrency(goal.targetAmount),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.bgCardElevated,
                    valueColor: AlwaysStoppedAnimation(goal.color),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}% tercapai',
                    style: TextStyle(color: goal.color, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // System Recommendation Banner
          if (!isCompleted && recommendation != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgCardElevated,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: goal.color, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          const TextSpan(text: 'Rekomendasi: tabung ', style: TextStyle(color: AppTheme.textSecondary)),
                          TextSpan(
                            text: _formatCurrency(recommendation),
                            style: TextStyle(color: goal.color, fontWeight: FontWeight.w800),
                          ),
                          const TextSpan(text: '/bulan', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Add funds button
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFundsSheet(goal, index),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: goal.color,
                    side: BorderSide(color: goal.color.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Dana', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double? _calcRecommendation(_SavingGoal goal) {
    final remaining = goal.targetAmount - goal.savedAmount;
    if (remaining <= 0) return null;
    final monthsLeft = goal.deadline.difference(DateTime.now()).inDays / 30;
    if (monthsLeft <= 0) return null;
    return (remaining / monthsLeft).ceilToDouble();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    return 'Rp${amount.toStringAsFixed(0)}';
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _SavingGoal {
  final String name;
  final String emoji;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final Color color;

  const _SavingGoal({
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.color,
  });
}

// ─── Goal Form Sheet ──────────────────────────────────────────────────────────

class _GoalFormSheet extends StatefulWidget {
  final _SavingGoal? existingGoal;
  final Function(_SavingGoal) onSave;

  const _GoalFormSheet({this.existingGoal, required this.onSave});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _savedController;
  late DateTime _deadline;
  String _selectedEmoji = '🎯';
  Color _selectedColor = AppTheme.primaryGreen;

  final _emojis = ['🎯', '💻', '🏠', '🚗', '✈️', '🛡️', '🏖️', '💍', '📱', '🎓'];
  final _colors = [AppTheme.primaryGreen, AppTheme.accentBlue, AppTheme.accentYellow, AppTheme.primaryPurple, AppTheme.accentCoral];

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _nameController = TextEditingController(text: g?.name ?? '');
    _targetController = TextEditingController(text: g != null ? g.targetAmount.toStringAsFixed(0) : '');
    _savedController = TextEditingController(text: g != null ? g.savedAmount.toStringAsFixed(0) : '0');
    _deadline = g?.deadline ?? DateTime.now().add(const Duration(days: 180));
    _selectedEmoji = g?.emoji ?? '🎯';
    _selectedColor = g?.color ?? AppTheme.primaryGreen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryGreen, surface: AppTheme.bgCardElevated),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(
              widget.existingGoal == null ? '🎯 Target Baru' : 'Edit Target',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Emoji Picker
            const Text('Ikon', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _emojis.map((e) => GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _selectedEmoji == e ? _selectedColor.withOpacity(0.15) : AppTheme.bgCardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedEmoji == e ? _selectedColor : AppTheme.borderColor),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Nama Target', prefixIcon: Icon(Icons.label_outline_rounded)),
              validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Nominal Target (Rp)', prefixIcon: Icon(Icons.flag_outlined)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                if ((double.tryParse(v) ?? 0) <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _savedController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Dana Awal (Rp)', prefixIcon: Icon(Icons.savings_outlined)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
                    const SizedBox(width: 12),
                    Text('Deadline: ${_deadline.day}/${_deadline.month}/${_deadline.year}',
                        style: const TextStyle(color: AppTheme.textPrimary)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Warna', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 32, height: 32, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(color: _selectedColor == c ? AppTheme.textPrimary : Colors.transparent, width: 2.5),
                  ),
                  child: _selectedColor == c ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(_SavingGoal(
                      name: _nameController.text,
                      emoji: _selectedEmoji,
                      targetAmount: double.parse(_targetController.text),
                      savedAmount: double.tryParse(_savedController.text) ?? 0,
                      deadline: _deadline,
                      color: _selectedColor,
                    ));
                  }
                },
                child: Text(widget.existingGoal == null ? 'Buat Target' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}