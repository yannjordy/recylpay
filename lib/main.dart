import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/map_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/market_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/market_screen.dart';
import 'screens/map_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/eco_impact_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_posts_screen.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/help_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_bottom_nav.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('fr_FR');
  } catch (_) {}
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('=== FLUTTER ERROR ===\n${details.exception}\n${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== PLATFORM ERROR ===\n$error\n$stack');
    return true;
  };
  runApp(const RecycPayApp());
}

class RecycPayApp extends StatelessWidget {
  const RecycPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
      ],
      child: MaterialApp(
        title: 'RecycPay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const MainShell(),
          '/settings': (_) => const SettingsScreen(),
          '/eco-impact': (_) => const EcoImpactScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/messages': (_) => const ChatListScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/my-posts': (_) => const MyPostsScreen(),
          '/how-it-works': (_) => const HowItWorksScreen(),
          '/privacy': (_) => const PrivacyScreen(),
          '/help': (_) => const HelpScreen(),
          '/about': (_) => const AboutScreen(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _screens = const [
    MarketScreen(),
    MapScreen(),
    CreatePostScreen(),
    FeedScreen(),
    WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initProviders();
  }

  void _initProviders() {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      auth.checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
