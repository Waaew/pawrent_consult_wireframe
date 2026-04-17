import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/consult_models.dart';

const String _u = 'https://images.unsplash.com/';
const String _q = '?auto=format&fit=crop&w=200&q=80';

const Map<String, String> _avatarUrls = {
  'waew': '${_u}photo-1494790108377-be9c29b29330$_q',
  'nick': '${_u}photo-1507003211169-0a1dd7228f2d$_q',
  'mint': '${_u}photo-1544005313-94ddf0286df2$_q',
  'you': '${_u}photo-1494790108377-be9c29b29330$_q',
  'somchai': '${_u}photo-1537368910025-700350fe46c7$_q',
  'ploy': '${_u}photo-1559839734-2b71ea197ec2$_q',
  'mana': '${_u}photo-1622253692010-333f2da6031d$_q',
  'moji': '${_u}photo-1568572933382-74d440642117$_q',
  'luna': '${_u}photo-1574158622682-e40e69881006$_q',
  'coco': '${_u}photo-1535241749838-299277b6305f$_q',
};

class SeededAvatar extends StatelessWidget {
  final String seed;
  final double size;
  final AuthorRole? role;

  const SeededAvatar({
    super.key,
    required this.seed,
    this.size = 40,
    this.role,
  });

  Color get _bg {
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    final palette = [
      const Color(0xFFFCD5CE),
      const Color(0xFFD0E8FF),
      const Color(0xFFD8F3DC),
      const Color(0xFFFFE5B4),
      const Color(0xFFE6D5FF),
      const Color(0xFFFFD6E0),
      const Color(0xFFC8F5EE),
    ];
    return palette[hash % palette.length];
  }

  String get _initials {
    final parts = seed.replaceAll(RegExp(r'[^a-zA-Z ]'), '').split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return seed.isNotEmpty
        ? seed.substring(0, seed.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  Widget _initialsWidget() {
    return Text(
      _initials,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: size * 0.36,
        color: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _avatarUrls[seed];
    final inner = url != null
        ? ClipOval(
            child: Image.network(
              url,
              width: size - 4,
              height: size - 4,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _initialsWidget(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _initialsWidget();
              },
            ),
          )
        : _initialsWidget();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: inner,
    );
  }
}
