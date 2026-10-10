import 'package:flutter/material.dart';

class ProfileViewPage extends StatelessWidget {
  final String rollNumber;
  final String stream;

  const ProfileViewPage({
    super.key,
    required this.rollNumber,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Solid crisp white background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Avatar using an Asset Image
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50, // Fallback background color if image takes a second to load
                  backgroundImage: AssetImage("assets/profile.png"), // Uses your asset image
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Student Profile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text(
              "NSUT Verified Account",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Details Card
            Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.grey.shade50, // Clean light card fill against white background
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: Colors.deepPurple),
                      title: const Text("Roll Number", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(rollNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.school_outlined, color: Colors.deepPurple),
                      title: const Text("Stream / Branch", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(stream, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.verified_user_outlined, color: Colors.green),
                      title: Text("Institutional Status", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text("Active Student (@nsut.ac.in)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}