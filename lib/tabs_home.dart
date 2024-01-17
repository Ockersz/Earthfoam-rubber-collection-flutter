import 'package:flutter/material.dart';
import 'package:rubber_collection/add_suppliers.dart';
import 'package:rubber_collection/home.dart';

void main() {
  runApp(const HomeTabs());
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({Key? key});

  @override
  _HomeTabsState createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentIndex == 0 ? 'Rubber Collection' : 'Settings',
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.file_copy)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            HomeScreen(),
            AddSuppliers(),
          ],
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
    );
  }
}
