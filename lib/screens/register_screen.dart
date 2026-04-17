import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hidePw = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _passwordMismatch() {
    final pw = _passwordCtrl.text;
    final cf = _confirmCtrl.text;
    if (cf.isEmpty) return null;
    if (pw != cf) return 'รหัสผ่านไม่ตรงกัน';
    return null;
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().contains('@') &&
      _passwordCtrl.text.trim().length >= 6 &&
      _passwordCtrl.text == _confirmCtrl.text &&
      _agreed;

  void _submit() {
    if (!_canSubmit) return;
    currentUser = currentUser.copyWith(name: _nameCtrl.text.trim());
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
          children: [
            const Text(
              'ลงทะเบียน Pawrent',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'เพียงขั้นตอนเดียว เริ่มดูแลน้องๆ ได้ทันที',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _Label('Display name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'ชื่อที่จะแสดงในชุมชน'),
            ),
            const SizedBox(height: AppSpacing.md),
            const _Label('Email'),
            const SizedBox(height: 6),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),
            const SizedBox(height: AppSpacing.md),
            const _Label('Password'),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordCtrl,
              obscureText: _hidePw,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'อย่างน้อย 6 ตัวอักษร',
                suffixIcon: IconButton(
                  tooltip: _hidePw ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _hidePw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _hidePw = !_hidePw),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _Label('Confirm password'),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmCtrl,
              obscureText: _hidePw,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'พิมพ์รหัสผ่านอีกครั้ง',
                errorText: _passwordMismatch(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'ยอมรับ เงื่อนไขการใช้งาน และ นโยบายความเป็นส่วนตัว ของ Pawrent',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit ? AppColors.primary : AppColors.border,
                  foregroundColor: _canSubmit ? Colors.white : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ลงทะเบียน',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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
