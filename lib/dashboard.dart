import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'backend_service.dart';
import 'pages/chat_page.dart';
import 'pages/login_page.dart';
import 'pages/settings_page.dart';
import 'pages/tasks_page.dart';

class FrankApp extends StatefulWidget {
  const FrankApp({super.key});

  @override
  State<FrankApp> createState() => _FrankAppState();
}

class _FrankAppState extends State<FrankApp> {
  final _service = BackendService('http://localhost:8000/api');
  bool _ready = false;
  bool _darkMode = false;
  double _temperature = 0.7;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _service.init().then((_) => setState(() => _ready = true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(useMaterial3: true, brightness: _darkMode ? Brightness.dark : Brightness.light);
    return MaterialApp(
      theme: theme,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: _ready ? _buildHome() : const SizedBox.shrink(),
    );
  }

  Widget _buildHome() {
    if (!_service.isLoggedIn) {
      return LoginPage(
        service: _service,
        onLoggedIn: () => setState(() {}),
      );
    }

    final pages = [
      TasksPage(service: _service),
      ChatPage(service: _service),
      SettingsPage(
        service: _service,
        darkMode: _darkMode,
        temperature: _temperature,
        onThemeChanged: (v) => setState(() => _darkMode = v),
      ),
    ];

    final items = const [
      BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 801;
        final content = IndexedStack(index: _index, children: pages);
        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.list), label: Text('Tasks')),
                    NavigationRailDestination(icon: Icon(Icons.chat), label: Text('Chat')),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),
                Expanded(child: content),
              ],
            ),
          );
        }
        return Scaffold(
          body: content,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            items: items,
            onTap: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}
