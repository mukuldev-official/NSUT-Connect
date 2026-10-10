import 'package:flutter/material.dart';
import 'feed.dart';

class AppColors {
  static const Color primaryColor = Colors.deepPurpleAccent;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController rollController = TextEditingController();

  // Selected stream state variable
  String selectedStream = "Electronics & Communication (ECE)";

  final List<String> streams = [
    "Electronics & Communication (ECE)",
    "Computer Science (CSE)",
    "Information Technology (IT)",
    "Mechanical Engineering (ME)",
    "Electrical Engineering (EE)",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                color: Colors.white.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 36,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "NSUT Connect",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Crosslink Connects Hearts ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text("❤️", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Email Field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "NSUT Email",
                          hintText: "your_name@nsut.ac.in",
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Roll Number Field
                      TextField(
                        controller: rollController,
                        decoration: InputDecoration(
                          labelText: "NSUT Roll Number",
                          hintText: "e.g., 2026UEC2669",
                          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stream Dropdown Selection Field
                      // Stream Dropdown Selection Field
                      DropdownButtonFormField<String>(
                        value: selectedStream,
                        isExpanded: true, // Crucial: forces the dropdown to fill the max available width safely
                        decoration: InputDecoration(
                          labelText: "Select Stream / Branch",
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        items: streams.map((String stream) {
                          return DropdownMenuItem<String>(
                            value: stream,
                            child: Text(
                              stream,
                              overflow: TextOverflow.ellipsis, // Prevents text overflow if it gets too long
                              style: const TextStyle(fontSize: 13), // Slightly adjusted font size to fit cleanly
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStream = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 28),

                      // Login Action Button (Passes Roll Number and Stream to Dashboard)
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          onPressed: () {
                            String email = emailController.text.trim();
                            if (email.endsWith("@nsut.ac.in")) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainDashboard(
                                    rollNumber: rollController.text.isEmpty ? "2026UEC2669" : rollController.text,
                                    stream: selectedStream,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please use your official @nsut.ac.in email")),
                              );
                            }
                          },
                          child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}