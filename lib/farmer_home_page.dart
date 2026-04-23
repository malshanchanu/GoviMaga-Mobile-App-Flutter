import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/crop_service.dart';

import 'screens/weather/widgets/weather_screen.dart';
import 'screens/diagnose/diagnose_home.dart';
import 'screens/market/market_home.dart';
import 'screens/crops/crops_home.dart';
import 'screens/forum/forum_home.dart';
import 'screens/profile/profile_home.dart';


class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'EN';
  String currentCrop = "Paddy";

  final CropService _cropService = CropService();
  List<Map<String, dynamic>> _upcomingTasks = [];
  bool _isAuthenticated = false;
  StreamSubscription<User?>? _authSubscription;

  final Map<String, Map<String, String>> localizedText = {
    'EN': {
      'app_title': 'GoviMaga',
      'welcome': 'Welcome, Farmer!',
      'alerts': 'Care Reminders',
      'features': 'Key Services',
      'home': 'Home',
      'diagnose': 'Diagnose',
      'market': 'Market',
      'crops': 'Crops',
      'weather': 'Weather',
      'forum': 'Forum',
      'profile': 'Profile',
      'fertilizer': 'Fertilizer Application',
      'pesticide': 'Pest Control',
      'current_crop': 'Current Crop: ',
      'ask_ai': 'Ask AI',
      'no_tasks': 'No pending tasks',
      'view_all': 'View All',
    },
    'SI': {
      'app_title': 'ගොවිමඟ',
      'welcome': 'ආයුබෝවන්, ගොවි මහතාණෙනි!',
      'alerts': 'සැලකිලිමත් වන්න',
      'features': 'මූලික සේවාවන්',
      'home': 'ප්‍රධාන',
      'diagnose': 'රෝග',
      'market': 'මිල ගණන්',
      'crops': 'වගාවන්',
      'weather': 'කාලගුණය',
      'forum': 'සමූහය',
      'profile': 'ගිණුම',
      'fertilizer': 'පොහොර යෙදීම',
      'pesticide': 'පළිබෝධ පාලනය',
      'current_crop': 'දැනට වගාව: ',
      'ask_ai': 'AI ගෙන් අසන්න',
      'no_tasks': 'විවෘත කාර්යයන් නැත',
      'view_all': 'සියල්ල බලන්න',
    },
    'TA': {
      'app_title': 'கோவிமகா',
      'welcome': 'வணக்கம், விவசாயியே!',
      'alerts': 'கவனிப்பு நினைவூட்டல்கள்',
      'features': 'முக்கிய சேவைகள்',
      'home': 'முகப்பு',
      'diagnose': 'கண்டறிதல்',
      'market': 'சந்தை',
      'crops': 'பயிர்கள்',
      'weather': 'வானிலை',
      'forum': 'மன்றம்',
      'profile': 'சுயவிவரம்',
      'fertilizer': 'உரம் இடுதல்',
      'pesticide': 'பூச்சி கட்டுப்பாடு',
      'current_crop': 'தற்போதைய பயிர்: ',
      'ask_ai': 'AI யிடம் கேளுங்கள்',
      'no_tasks': 'நிலுவையில் உள்ள பணிகள் இல்லை',
      'view_all': 'அனைத்தையும் காண்க',
    },
  };

  String t(String key) => localizedText[_selectedLanguage]![key]!;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final isAuth = user != null;
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuth;
        });
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isAuthenticated) {
      if (mounted) {
        setState(() {
          _upcomingTasks = [];
          currentCrop = "Paddy";
        });
      }
      return;
    }
    await _cropService.loadCrops();
    if (mounted) {
      setState(() {
        if (_cropService.crops.isNotEmpty) {
          currentCrop = _cropService.crops.first['name'] as String;
        }
      });
      _updateTasks();
    }
  }

  Future<void> _updateTasks() async {
    final tasks = await _cropService.getAllUpcomingTasks(days: 7);
    if (mounted) {
      setState(() {
        _upcomingTasks = tasks;
      });
    }
  }

  List<Map<String, dynamic>> getDynamicNotices() {
    List<Map<String, dynamic>> notices = [];

    for (var task in _upcomingTasks.take(3)) {
      String cropName = task['cropName'] ?? 'Unknown';

      notices.add({
        'title': task['title'],
        'msg': '$cropName - Upcoming task',
        'icon': _getIconForTaskType('GENERAL'), // fallback since taskType is removed from new model
        'color': _getColorForPriority('MEDIUM'),
        'taskId': task['id'],
        'cropId': task['cropId'],
        'dueDate': task['dueDate'],
      });
    }

    return notices;
  }

  IconData _getIconForTaskType(String type) {
    switch (type) {
      case 'WATERING':
        return Icons.water_drop;
      case 'FERTILIZER':
        return Icons.science;
      case 'PEST_CONTROL':
        return Icons.bug_report;
      case 'HARVESTING':
        return Icons.agriculture;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForPriority(String priority) {
    switch (priority) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _completeTask(String cropId, String taskId) async {
    await _cropService.toggleTaskCompletion(cropId, taskId, true);
    _updateTasks();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task completed!')));
    }
  }

  String _getDaysUntilText(DateTime dueDate) {
    final daysUntil = dueDate.difference(DateTime.now()).inDays;
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return '$daysUntil days left';
  }

  void _changeLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notices = getDynamicNotices();

    final List<Widget> pages = [
      HomeContent(
        onFeatureTap: _onItemTapped,
        language: _selectedLanguage,
        t: t,
        notices: notices,
        currentCropName: currentCrop == "Paddy" || currentCrop == "වී" || currentCrop == "நெல்"
            ? (_selectedLanguage == 'EN'
                  ? "Paddy"
                  : (_selectedLanguage == 'SI' ? "වී" : "நெல்"))
            : currentCrop, // Default to the actual crop name if not Paddy
        onTaskComplete: _completeTask,
        getDaysUntilText: _getDaysUntilText,
      ),
      DiagnoseHome(language: _selectedLanguage),
      MarketHome(language: _selectedLanguage),
      CropsHome(language: _selectedLanguage),
      WeatherScreen(language: _selectedLanguage),
      ForumHome(language: _selectedLanguage),
      ProfileHome(language: _selectedLanguage),  
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/app_logo.jpeg',
                height: 35,
                width: 35,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.eco, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              t('app_title'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langButton('EN', 'EN'),
              Text(" | ", style: const TextStyle(color: Colors.white54)),
              _langButton('SI', 'සිං'),
              Text(" | ", style: const TextStyle(color: Colors.white54)),
              _langButton('TA', 'தமி'),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                debugPrint("Navigating to AI Chat...");
              },
              backgroundColor: const Color(0xFF1B5E20),
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(
                t('ask_ai'),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: t('diagnose'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront),
            label: t('market'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grass),
            label: t('crops'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud),
            label: t('weather'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: t('forum'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t('profile'),
          ),
        ],
      ),
    );
  }

  Widget _langButton(String code, String text) {
    bool isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onFeatureTap;
  final String language;
  final String Function(String) t;
  final List<Map<String, dynamic>> notices;
  final String currentCropName;
  final Function(String, String)? onTaskComplete;
  final Function(DateTime)? getDaysUntilText;

  const HomeContent({
    super.key,
    required this.onFeatureTap,
    required this.language,
    required this.t,
    required this.notices,
    required this.currentCropName,
    this.onTaskComplete,
    this.getDaysUntilText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('alerts'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onFeatureTap(3),
                child: Text(t('view_all')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notices.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('no_tasks'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notices.map(
              (n) => _buildNoticeTile(
                n['title'],
                n['msg'],
                n['icon'],
                n['color'],
                n['taskId'],
                n['cropId'],
                n['dueDate'],
              ),
            ),
          const SizedBox(height: 25),
          Text(
            t('features'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildFeatureGrid(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('welcome'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${t('current_crop')}$currentCropName",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeTile(
    String title,
    String msg,
    IconData icon,
    Color color,
    String taskId,
    String cropId,
    DateTime dueDate,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              getDaysUntilText != null ? getDaysUntilText!(dueDate) : '',
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          onPressed: () => onTaskComplete?.call(cropId, taskId),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _featureItem(t('diagnose'), Icons.camera_alt, Colors.blue, 1),
        _featureItem(t('market'), Icons.storefront, Colors.orange, 2),
        _featureItem(t('crops'), Icons.grass, Colors.green, 3),
        _featureItem(t('weather'), Icons.cloud, Colors.lightBlue, 4),
        _featureItem(t('ask_ai'), Icons.auto_awesome, Colors.purple, 100),
      ],
    );
  }

  Widget _featureItem(String title, IconData icon, Color color, int index) {
    return InkWell(
      onTap: () {
        if (index == 100) {
          debugPrint("Ask AI tapped from Grid!");
        } else {
          onFeatureTap(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
