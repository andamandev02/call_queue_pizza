import 'package:call_queue_pizza/Tabs/setting-order.dart';
import 'package:call_queue_pizza/Tabs/setting-queue.dart';
import 'package:call_queue_pizza/Tabs/setting-sound.dart';
import 'package:call_queue_pizza/Tabs/setting-usb.dart';
import 'package:flutter/material.dart';

class SettingMainScreen extends StatefulWidget {
  const SettingMainScreen({super.key});

  @override
  State<SettingMainScreen> createState() => _SettingMainScreenState();
}

class _SettingMainScreenState extends State<SettingMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting (การตั้งค่า)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Setting Queue (ตั้งค่าตัวเลขคิว)'),
            Tab(text: 'Setting Order Number (ตั้งค่ากรอบ OrderNumber)'),
            Tab(text: 'Setting USB (ตั้งค่า USB)'),
            Tab(text: 'Setting Sound (ตั้งค่า เสียง)'),
            // Tab(text: 'Setting USB (ตั้งค่า USB)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TabQueueScreen(),
          TabOrderScreen(),
          TabUSBScreen(),
          TabSoundScreen(),
          // Tab3Screen(),
        ],
      ),
    );
  }
}
