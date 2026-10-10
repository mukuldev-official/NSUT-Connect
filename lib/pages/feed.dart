import 'package:flutter/material.dart';
import 'timetable.dart';
import 'profile_view.dart';

class MainDashboard extends StatefulWidget {
  final String rollNumber;
  final String stream;

  const MainDashboard({
    super.key,
    required this.rollNumber,
    required this.stream,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedContentTab(),
      const TimetablePage(),
      ProfileViewPage(rollNumber: widget.rollNumber, stream: widget.stream),
    ];
  }

  // >>> STEP 3: ADD THE NOTIFICATION SHEET METHOD HERE INSIDE THE STATE CLASS <<<
  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Notifications",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Icon(Icons.notifications_outlined, color: Colors.deepPurple),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              // Dummy Notification Items
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Icon(Icons.campaign, color: Colors.white),
                ),
                title: const Text("Mid-Sem Timetable Released", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Check your portal for room allocations.", style: TextStyle(fontSize: 12)),
                trailing: const Text("10m ago", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.schedule, color: Colors.white),
                ),
                title: Text("Class Rescheduled", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Digital Electronics shifted to 11:00 AM.", style: TextStyle(fontSize: 12)),
                trailing: Text("1h ago", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? "NSUT Announcements"
              : _currentIndex == 1
              ? "My Timetable"
              : "My Profile",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.withOpacity(0.85),
        elevation: 0,
        actions: [
          // Notification Bell Icon Button triggering Step 3
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
            onPressed: () {
              _showNotificationSheet(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background.jpg",
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          _screens[_currentIndex],
        ],
      ),

      // Modern Floating Pill Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(icon: Icons.feed_outlined, activeIcon: Icons.feed, label: "Announcements", index: 0),
              _buildNavBarItem(icon: Icons.schedule_outlined, activeIcon: Icons.schedule, label: "Timetable", index: 1),
              _buildNavBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "Profile", index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({required IconData icon, required IconData activeIcon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Announcements Tab Content
class FeedContentTab extends StatelessWidget {
  const FeedContentTab({super.key});

  final List<Map<String, String>> dummyPosts = const [
    {
      "title": "Welcome Freshers!",
      "desc": "Orientation day for B.Tech batches is scheduled in the main auditorium."
    },
    {
      "title": "Library Notice",
      "desc": "Central Library will remain open 24/7 during mid-sem examinations."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dummyPosts.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shadowColor: Colors.black26,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dummyPosts[index]["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                ),
                const SizedBox(height: 8),
                Text(
                  dummyPosts[index]["desc"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}