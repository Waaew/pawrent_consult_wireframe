import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import 'profile_screen.dart';

class FollowersListScreen extends StatefulWidget {
  final Author profile;
  final int totalCount;

  const FollowersListScreen({
    super.key,
    required this.profile,
    required this.totalCount,
  });

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Author> get _followers {
    final all = allAuthors.where((a) => a.avatarSeed != widget.profile.avatarSeed).toList();
    if (_query.trim().isEmpty) return all;
    final q = _query.trim().toLowerCase();
    return all
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            (a.specialty?.toLowerCase().contains(q) ?? false) ||
            (a.clinic?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _followers;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Followers · ${widget.totalCount}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: Semantics(
              label: 'Search followers',
              textField: true,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'ค้นหา followers…',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? _EmptyState(query: _query)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _FollowerRow(follower: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FollowerRow extends StatelessWidget {
  final Author follower;
  const _FollowerRow({required this.follower});

  @override
  Widget build(BuildContext context) {
    final isVet = follower.role == AuthorRole.vet;
    final isBrand = follower.role == AuthorRole.brand;
    final subtitle = isVet
        ? '${follower.specialty ?? ""} · ${follower.clinic ?? ""}'
        : isBrand
            ? 'Brand partner'
            : 'Pawrent';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => openProfile(context, follower),
        child: Semantics(
          button: true,
          label: 'Open ${follower.name} profile',
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SeededAvatar(seed: follower.avatarSeed, size: 40, role: follower.role),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              follower.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (follower.verified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 13,
                              color: isVet
                                  ? AppColors.vetBadge
                                  : isBrand
                                      ? AppColors.brandBadge
                                      : AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Following', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              query.isEmpty
                  ? 'ยังไม่มี followers'
                  : 'ไม่พบผู้ใช้ที่ตรงกับ "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
