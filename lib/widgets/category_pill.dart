import 'package:flutter/material.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';

class CategoryPill extends StatelessWidget {
  final ConsultCategory category;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  const CategoryPill({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? category.color.withValues(alpha: 0.14) : AppColors.surface;
    final fg = selected ? category.color : AppColors.textSecondary;
    final border = selected ? category.color.withValues(alpha: 0.5) : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
