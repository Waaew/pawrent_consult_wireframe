import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import 'post_question_screen.dart';
import 'question_chat_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Pet get pet => widget.pet;

  Future<void> _addLog() async {
    final entry = await showModalBottomSheet<HealthLogEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _AddHealthLogSheet(petSeed: pet.avatarSeed),
    );
    if (entry != null && mounted) {
      setState(() => healthLogs.add(entry));
    }
  }

  @override
  Widget build(BuildContext context) {
    final relatedQuestions = mockQuestions
        .where((q) => q.pet?.avatarSeed == pet.avatarSeed)
        .toList();
    final acceptedCount = relatedQuestions.where((q) => q.hasAcceptedAnswer).length;
    final logs = healthLogsFor(pet.avatarSeed);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            tooltip: 'Share pet profile',
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'More options',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
        children: [
          _PetHero(pet: pet),
          const SizedBox(height: AppSpacing.lg),
          _PetStatsRow(
            total: relatedQuestions.length,
            solved: acceptedCount,
            logs: logs.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoSection(pet: pet),
          const SizedBox(height: AppSpacing.lg),
          _HealthLogHeader(count: logs.length, onAdd: _addLog),
          const SizedBox(height: AppSpacing.sm),
          if (logs.isEmpty)
            const _EmptyCard(
              icon: Icons.monitor_heart_outlined,
              text: 'ยังไม่มีบันทึกสุขภาพ · กด + เพิ่มรายการ',
            )
          else
            ...logs.map((e) => _HealthLogTile(entry: e)),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('Questions about ${pet.name}'),
          const SizedBox(height: AppSpacing.sm),
          if (relatedQuestions.isEmpty)
            const _EmptyCard(
              icon: Icons.help_outline,
              text: 'ยังไม่มีคำถามเกี่ยวกับน้อง',
            )
          else
            ...relatedQuestions.map((q) => _QuestionRow(question: q)),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PostQuestionScreen()),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text('ถามคำถามเกี่ยวกับ${pet.name}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetHero extends StatelessWidget {
  final Pet pet;
  const _PetHero({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Photo of ${pet.name}',
            image: true,
            child: SeededAvatar(seed: pet.avatarSeed, size: 72),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    _speciesLabel(pet.species),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pet.breed,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _speciesLabel(String species) {
  switch (species.toLowerCase()) {
    case 'dog':
      return '🐶 DOG';
    case 'cat':
      return '🐱 CAT';
    case 'rabbit':
      return '🐰 RABBIT';
    default:
      return '🐾 ${species.toUpperCase()}';
  }
}

class _PetStatsRow extends StatelessWidget {
  final int total;
  final int solved;
  final int logs;
  const _PetStatsRow({required this.total, required this.solved, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.forum_outlined,
            value: '$total',
            label: 'Questions',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            value: '$solved',
            label: 'Solved',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_heart_outlined,
            value: '$logs',
            label: 'Logs',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Pet pet;
  const _InfoSection({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet info',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Species', value: pet.species),
          const SizedBox(height: 8),
          _InfoRow(label: 'Breed', value: pet.breed),
          const SizedBox(height: 8),
          _InfoRow(label: 'Age', value: '${pet.ageMonths} months'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final Question question;
  const _QuestionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => QuestionChatScreen(question: question),
          )),
          child: Semantics(
            button: true,
            label: 'Open question: ${question.title}',
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: question.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(question.category.emoji, style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              question.hasAcceptedAnswer ? Icons.check_circle : Icons.schedule,
                              size: 11,
                              color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              question.hasAcceptedAnswer ? 'Solved' : 'Awaiting vet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthLogHeader extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  const _HealthLogHeader({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Health log',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text('Add log'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: const Size(0, 32),
          ),
        ),
      ],
    );
  }
}

class _HealthLogTile extends StatelessWidget {
  final HealthLogEntry entry;
  const _HealthLogTile({required this.entry});

  Color _typeColor(HealthLogType type) {
    switch (type) {
      case HealthLogType.weight:
        return AppColors.primary;
      case HealthLogType.vaccine:
        return AppColors.vetBadge;
      case HealthLogType.grooming:
        return AppColors.accent;
      case HealthLogType.checkup:
        return AppColors.success;
      case HealthLogType.medication:
        return AppColors.warning;
      case HealthLogType.note:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(entry.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(entry.type.emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          entry.type.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMM yyyy').format(entry.loggedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHealthLogSheet extends StatefulWidget {
  final String petSeed;
  const _AddHealthLogSheet({required this.petSeed});

  @override
  State<_AddHealthLogSheet> createState() => _AddHealthLogSheetState();
}

class _AddHealthLogSheetState extends State<_AddHealthLogSheet> {
  HealthLogType _type = HealthLogType.weight;
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _titleHint {
    switch (_type) {
      case HealthLogType.weight:
        return 'เช่น 4.2 kg';
      case HealthLogType.vaccine:
        return 'เช่น วัคซีนรวม 5 โรค';
      case HealthLogType.grooming:
        return 'เช่น ตัดขน + อาบน้ำ';
      case HealthLogType.checkup:
        return 'เช่น ตรวจสุขภาพประจำปี';
      case HealthLogType.medication:
        return 'เช่น ยาถ่ายพยาธิ';
      case HealthLogType.note:
        return 'สรุปเหตุการณ์สั้นๆ';
    }
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  void _save() {
    final entry = HealthLogEntry(
      type: _type,
      petSeed: widget.petSeed,
      title: _titleCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      loggedAt: DateTime.now(),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Add health log',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SheetLabel('Type'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: HealthLogType.values.map((t) {
                  final selected = _type == t;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    onTap: () => setState(() {
                      _type = t;
                      _titleCtrl.clear();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            t.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              const _SheetLabel('Detail'),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: _titleHint),
              ),
              const SizedBox(height: AppSpacing.md),
              const _SheetLabel('Note (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'รายละเอียดเพิ่มเติม…'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSave ? AppColors.primary : AppColors.border,
                        foregroundColor: _canSave ? Colors.white : AppColors.textSecondary,
                      ),
                      child: const Text('Save log'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
