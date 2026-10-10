import 'package:flutter/material.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  final Map<String, List<String>> weeklySchedule = const {
    "Monday": ["9:00 AM - Digital Electronics", "11:00 AM - Mathematics-I", "2:00 PM - C++ Lab"],
    "Tuesday": ["10:00 AM - Physics", "12:00 PM - Basic Electrical", "3:00 PM - Workshop"],
    "Wednesday": ["9:00 AM - Data Structures", "11:00 AM - Signals & Systems"],
    "Thursday": ["10:00 AM - Applied Physics", "2:00 PM - Python Programming"],
    "Friday": ["9:00 AM - Mathematics-II", "11:00 AM - Electronic Devices", "4:00 PM - Sports/Club Hour"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Clean light background contrast
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header banner inside the view
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Schedule",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "NSUT B.Tech ECE Batch",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Render Day Cards
          ...weeklySchedule.entries.map((entry) {
            bool hasClasses = entry.value.isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.today_rounded, color: Colors.deepPurple, size: 20),
                  ),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  subtitle: Text(
                    hasClasses ? "${entry.value.length} classes scheduled" : "No classes",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  children: [
                    const Divider(height: 1, thickness: 1, color: Colors.black12),
                    ...entry.value.map((classItem) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              classItem,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}