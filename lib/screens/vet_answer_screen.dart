import 'package:flutter/material.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';

class VetAnswerScreen extends StatefulWidget {
  final Question question;
  const VetAnswerScreen({super.key, required this.question});

  @override
  State<VetAnswerScreen> createState() => _VetAnswerScreenState();
}

class _VetAnswerScreenState extends State<VetAnswerScreen> {
  final _bodyCtrl = TextEditingController();
  bool _suggestVisit = false;
  final List<String> _photos = [];

  static const _bodyMax = 3000;

  static const _vet = Author(
    name: 'Dr. Somchai R.',
    clinic: 'Arak Animal Hospital',
    avatarSeed: 'somchai',
    role: AuthorRole.vet,
    specialty: 'Internal Medicine',
    verified: true,
  );

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _bodyCtrl.text.trim().length >= 30;

  void _submit() {
    if (!_canSubmit) return;
    final answer = Answer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: _vet,
      body: _bodyCtrl.text.trim(),
      upvotes: 0,
      accepted: false,
      postedAt: DateTime.now(),
      suggestsClinicVisit: _suggestVisit,
      photos: _photos,
    );
    Navigator.of(context).pop(answer);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Answer as vet'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.vetBadge.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.vetBadge.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const SeededAvatar(seed: 'somchai', size: 44, role: AuthorRole.vet),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_vet.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: AppColors.vetBadge),
                        ],
                      ),
                      Text('${_vet.clinic} · ${_vet.specialty}',
                          style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Replying to', style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.question.category.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.question.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Your answer',
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${_bodyCtrl.text.length}/$_bodyMax',
                  style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _bodyCtrl,
            maxLength: _bodyMax,
            maxLines: 10,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Be clear, include possible causes, what to monitor, and when to seek in-person care.',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ToolbarRow(
            onAttach: () => setState(() => _photos.add('p${_photos.length}')),
            onTemplate: _showTemplates,
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _photos
                  .asMap()
                  .entries
                  .map((e) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.vetBadge.withValues(alpha: 0.2),
                                AppColors.accent.withValues(alpha: 0.3),
                              ]),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image, color: Colors.white, size: 24),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(e.key)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _suggestVisit ? AppColors.warning.withValues(alpha: 0.08) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _suggestVisit ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.local_hospital,
                    color: _suggestVisit ? AppColors.warning : AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suggest in-clinic visit',
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        'Adds a callout and CTA to book a Telemet or in-person visit.',
                        style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _suggestVisit,
                  onChanged: (v) => setState(() => _suggestVisit = v),
                  activeThumbColor: AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.danger, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Public answer. Avoid prescribing controlled meds. Edits allowed within 24h.',
                    style: text.bodySmall?.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Text('Preview'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit ? AppColors.primary : AppColors.border,
                    foregroundColor: _canSubmit ? Colors.white : AppColors.textSecondary,
                  ),
                  child: const Text('Submit answer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) {
        final templates = [
          ('General triage', 'อาการที่อธิบายมาควรเฝ้าระวัง 12-24 ชม. ดังนี้:\n\n1. \n2. \n3. \n\nหากมีอาการ X, Y, Z ให้พามาคลินิกทันที'),
          ('Vaccination', 'ตารางวัคซีนที่แนะนำสำหรับสัตว์เลี้ยงอายุนี้:\n\n• \n\nควรเว้นระยะอย่างน้อย ... สัปดาห์'),
          ('Diet/nutrition', 'แนะนำอาหารที่:\n• AAFCO certified\n• โปรตีน X-Y%\n• แคลอรี่ ... kcal/day'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insert template',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.md),
                ...templates.map((t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.article_outlined, color: AppColors.primary),
                      title: Text(t.$1),
                      subtitle: Text(t.$2.split('\n').first,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        _bodyCtrl.text = t.$2;
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolbarRow extends StatelessWidget {
  final VoidCallback onAttach;
  final VoidCallback onTemplate;
  const _ToolbarRow({required this.onAttach, required this.onTemplate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _ToolBtn(icon: Icons.format_bold, onTap: () {}),
          _ToolBtn(icon: Icons.format_italic, onTap: () {}),
          _ToolBtn(icon: Icons.format_list_bulleted, onTap: () {}),
          _ToolBtn(icon: Icons.format_list_numbered, onTap: () {}),
          const SizedBox(width: 4),
          Container(width: 1, height: 20, color: AppColors.border),
          const SizedBox(width: 4),
          _ToolBtn(icon: Icons.attach_file, onTap: onAttach),
          _ToolBtn(icon: Icons.image_outlined, onTap: onAttach),
          const Spacer(),
          TextButton.icon(
            onPressed: onTemplate,
            icon: const Icon(Icons.bolt, size: 16),
            label: const Text('Template'),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
