import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/category_pill.dart';

class PostQuestionScreen extends StatefulWidget {
  const PostQuestionScreen({super.key});

  @override
  State<PostQuestionScreen> createState() => _PostQuestionScreenState();
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  ConsultCategory? _category;
  Pet? _pet;
  final List<String> _photos = [];
  bool _urgent = false;

  static const _titleMax = 120;
  static const _bodyMax = 2000;
  static const _photoMax = 4;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleCtrl.text.trim().length >= 10 &&
      _bodyCtrl.text.trim().length >= 20 &&
      _category != null;

  void _submit() {
    if (!_canSubmit) return;
    final q = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      category: _category!,
      author: const Author(name: 'You', avatarSeed: 'you', role: AuthorRole.owner),
      pet: _pet,
      photos: _photos,
      upvotes: 0,
      answers: const [],
      postedAt: DateTime.now(),
      isUrgent: _urgent,
    );
    Navigator.of(context).pop(q);
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
        title: const Text('Ask a vet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft saved'), behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('Save draft'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 120),
        children: [
          _SectionLabel('Category', required: true),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ConsultCategory.values
                .map((c) => CategoryPill(
                      category: c,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Title', required: true, hint: '${_titleCtrl.text.length}/$_titleMax'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleCtrl,
            maxLength: _titleMax,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g., โมจิอ้วก 3 ครั้งตั้งแต่เช้า ปกติไหมคะ?',
              counterText: '',
            ),
            style: text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Details', required: true, hint: '${_bodyCtrl.text.length}/$_bodyMax'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _bodyCtrl,
            maxLength: _bodyMax,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText:
                  'Describe symptoms, when they started, what your pet ate, any meds, and what you’ve tried so far.',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Which pet?'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myPets.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                if (i == myPets.length) {
                  return _AddPetTile(onTap: () {});
                }
                final p = myPets[i];
                final selected = _pet == p;
                return GestureDetector(
                  onTap: () => setState(() => _pet = selected ? null : p),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primarySoft : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        SeededAvatar(seed: p.avatarSeed, size: 40),
                        const SizedBox(height: 4),
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Photos', hint: '${_photos.length}/$_photoMax'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ..._photos.asMap().entries.map((e) => _PhotoThumb(
                    onRemove: () => setState(() => _photos.removeAt(e.key)),
                  )),
              if (_photos.length < _photoMax)
                _AddPhotoTile(onTap: () => setState(() => _photos.add('p${_photos.length}'))),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _urgent ? AppColors.danger.withValues(alpha: 0.08) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _urgent ? AppColors.danger.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _urgent ? AppColors.danger : AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mark as urgent',
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        'Prioritized to verified vets. Use only for serious symptoms.',
                        style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _urgent,
                  onChanged: (v) => setState(() => _urgent = v),
                  activeThumbColor: AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Tip: include photos and your pet’s age — vets answer 3× faster.',
                    style: text.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit ? AppColors.primary : AppColors.border,
                    foregroundColor: _canSubmit ? Colors.white : AppColors.textSecondary,
                  ),
                  child: const Text('Post question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool required;
  final String? hint;
  const _SectionLabel(this.text, {this.required = false, this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
        ],
        const Spacer(),
        if (hint != null)
          Text(hint!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            SizedBox(height: 2),
            Text('Add', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final VoidCallback onRemove;
  const _PhotoThumb({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.accent.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.image, color: Colors.white, size: 28),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: GestureDetector(
            onTap: onRemove,
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
    );
  }
}

class _AddPetTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.textSecondary),
            SizedBox(height: 4),
            Text('Add pet', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
