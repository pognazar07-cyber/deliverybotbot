import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/api_service.dart';
import 'order/order_tab.dart';
import 'history/history_screen.dart';
import 'support/support_screen.dart';
import 'profile/profile_screen.dart';

/// Bottom-nav shell tying together the four main sections of the app.
class HomeScreen extends StatefulWidget {
  final String lang;
  final int telegramId;

  const HomeScreen({super.key, required this.lang, required this.telegramId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    DmdNotifications.requestPermission();
    _registerPushToken();
  }

  Future<void> _registerPushToken() async {
    DmdPushNotifications.onTokenRefresh((token) {
      _api.registerPushToken(clientId: widget.telegramId, token: token);
    });
    final token = await DmdPushNotifications.getToken();
    if (token != null) {
      await _api.registerPushToken(clientId: widget.telegramId, token: token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final tabs = [
      OrderTab(lang: widget.lang, clientId: widget.telegramId),
      HistoryScreen(lang: widget.lang, clientId: widget.telegramId),
      SupportScreen(lang: widget.lang, clientId: widget.telegramId),
      ProfileScreen(lang: widget.lang, telegramId: widget.telegramId),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.local_shipping_outlined), label: s.tabOrder),
          NavigationDestination(icon: const Icon(Icons.history), label: s.tabHistory),
          NavigationDestination(icon: const Icon(Icons.support_agent), label: s.tabSupport),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: s.tabProfile),
        ],
      ),
    );
  }
}
