import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'models/consult_models.dart';
import 'screens/consult_board_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const PawrentApp());

class PawrentApp extends StatefulWidget {
  const PawrentApp({super.key});

  @override
  State<PawrentApp> createState() => _PawrentAppState();
}

class _PawrentAppState extends State<PawrentApp> {
  bool _authed = false;

  void _login() => setState(() => _authed = true);
  void _logout() => setState(() => _authed = false);

  void _switchAccount(Author user) {
    setState(() => currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawrent Second Opinion',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _authed
          ? RootShell(
              key: ValueKey(currentUser.avatarSeed),
              onLogout: _logout,
              onSwitchAccount: _switchAccount,
            )
          : LoginScreen(onLogin: _login),
    );
  }
}

class RootShell extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<Author> onSwitchAccount;
  const RootShell({
    super.key,
    required this.onLogout,
    required this.onSwitchAccount,
  });

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _tabs = [
    ('Home', Icons.home_outlined, Icons.home),
    ('Second Opinion', Icons.forum_outlined, Icons.forum),
    ('Profile', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_index) {
      case 0:
        body = HomeScreen(
          onNavigateToProfile: () => setState(() => _index = 2),
        );
        break;
      case 1:
        body = const ConsultBoardScreen();
        break;
      case 2:
        body = ProfileScreen(
          author: currentUser,
          showBackButton: false,
          onLogout: widget.onLogout,
          onSwitchAccount: widget.onSwitchAccount,
        );
        break;
      default:
        body = const SizedBox();
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        height: 64,
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.$2),
                  selectedIcon: Icon(t.$3, color: AppColors.primary),
                  label: t.$1,
                ))
            .toList(),
      ),
    );
  }
}
