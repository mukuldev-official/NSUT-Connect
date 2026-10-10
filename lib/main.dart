import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NSUTConnectApp());
}

// ==========================================
// THEME & STYLING
// ==========================================
class AppTheme {
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF151C2C);
  static const Color surfaceVariant = Color(0xFF1E2738);
  static const Color primary = Color(0xFF10B981); // Emerald
  static const Color adminAccent = Color(0xFFF59E0B); // Amber / Gold for Admin
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color error = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF283548), width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

// ==========================================
// ENTRY & AUTH GATEWAY
// ==========================================
class NSUTConnectApp extends StatelessWidget {
  const NSUTConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSUT Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return RoleRouter(uid: snapshot.data!.uid);
        }
        return const RoleSelectionScreen();
      },
    );
  }
}

class RoleRouter extends StatelessWidget {
  final String uid;
  const RoleRouter({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('User profile not found in database.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Back to Login'),
                  )
                ],
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'user';

        if (role == 'admin') {
          return AdminDashboard(userData: userData);
        }
        return UserDashboard(userData: userData);
      },
    );
  }
}

// ==========================================
// 1. ROLE SELECTION & LOGIN SCREENS
// ==========================================
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school_rounded, size: 84, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text('NSUT Connect', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Crosslink Connects Hearts 💚', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.person, color: Colors.black),
                label: const Text('Continue as Student'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAuthScreen())),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.adminAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.admin_panel_settings, color: AppTheme.adminAccent),
                label: const Text('Staff & Admin Console', style: TextStyle(color: AppTheme.adminAccent, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentAuthScreen extends StatefulWidget {
  const StudentAuthScreen({super.key});
  @override
  State<StudentAuthScreen> createState() => _StudentAuthScreenState();
}

class _StudentAuthScreenState extends State<StudentAuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _rollCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final roll = _rollCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (!email.endsWith('@nsut.ac.in')) {
      setState(() => _error = 'Institutional email must end with @nsut.ac.in');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isRegistering) {
        if (roll.isEmpty || name.isEmpty) {
          throw Exception('Roll Number and Display Name are required');
        }
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'role': 'user',
          'rollNo': roll.toUpperCase(),
          'displayName': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Student Registration' : 'Student Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
              ),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'NSUT Email', hintText: 'name@nsut.ac.in')),
            const SizedBox(height: 12),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            if (_isRegistering) ...[
              TextField(controller: _rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number', hintText: 'e.g. 2026UEC2669')),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display Name', hintText: 'How you appear in chat')),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Text(_isRegistering ? 'Register' : 'Login'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _isRegistering = !_isRegistering;
                _error = null;
              }),
              child: Text(_isRegistering ? 'Already registered? Sign In' : 'New student? Register with Roll No'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'mukulgautam0011@gmail.com');
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _adminLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists || (doc.data() as Map<String, dynamic>)['role'] != 'admin') {
        // Fallback for default primary admin seed
        if (_emailCtrl.text.trim() == 'mukulgautam0011@gmail.com') {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'uid': cred.user!.uid,
            'email': _emailCtrl.text.trim(),
            'role': 'admin',
            'displayName': 'Chief Admin',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await FirebaseAuth.instance.signOut();
          throw Exception('Account does not have administrative privileges.');
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Authentication', style: TextStyle(color: AppTheme.adminAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 64, color: AppTheme.adminAccent),
            const SizedBox(height: 16),
            const Text('NSUT Admin Console', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Authorized administrative access only', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
              ),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Admin Email')),
            const SizedBox(height: 12),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Admin Password')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.adminAccent),
              onPressed: _isLoading ? null : _adminLogin,
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Authorize & Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. COMMUNITY CHAT (WHATSAPP STYLE)
// ==========================================
class CommunityChatScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CommunityChatScreen({super.key, required this.userData});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('community_chat').add({
      'text': text,
      'senderId': user.uid,
      'senderName': widget.userData['displayName'] ?? 'Student',
      'senderRole': widget.userData['role'] ?? 'user',
      'rollNo': widget.userData['rollNo'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _scrollCtrl.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.forum, color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text('Campus Community'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('community_chat').orderBy('timestamp', descending: true).limit(100).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hello to the campus!', style: TextStyle(color: AppTheme.textSecondary)));
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUserId;
                    final isAdmin = data['senderRole'] == 'admin';
                    final timestamp = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now();
                    final formattedTime = DateFormat('hh:mm a').format(timestamp);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? (isAdmin ? AppTheme.adminAccent.withOpacity(0.25) : AppTheme.primary.withOpacity(0.2))
                              : (isAdmin ? const Color(0xFF2B2111) : AppTheme.surfaceVariant),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
                            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
                          ),
                          border: Border.all(
                            color: isAdmin ? AppTheme.adminAccent : (isMe ? AppTheme.primary : const Color(0xFF283548)),
                            width: isAdmin ? 1.5 : 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data['senderName'] ?? 'Anonymous',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isAdmin ? AppTheme.adminAccent : (isMe ? AppTheme.primary : AppTheme.textSecondary),
                                  ),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: AppTheme.adminAccent, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('ADMIN', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                  )
                                ]
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(data['text'] ?? '', style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(formattedTime, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: AppTheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Message campus community...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                  icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. ANNOUNCEMENTS & FEED SCREEN
// ==========================================
class AnnouncementsFeedScreen extends StatelessWidget {
  const AnnouncementsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Official Notices & Feed')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements posted yet.', style: TextStyle(color: AppTheme.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final item = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final isUrgent = item['isUrgent'] ?? false;
              final timestamp = item['timestamp'] != null ? (item['timestamp'] as Timestamp).toDate() : DateTime.now();
              final dateStr = DateFormat('MMM d, yyyy • hh:mm a').format(timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.campaign, color: isUrgent ? AppTheme.error : AppTheme.adminAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(item['authorName'] ?? 'Admin Office', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.adminAccent)),
                            ],
                          ),
                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: const Text('URGENT', style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(item['body'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, height: 1.4)),
                      const SizedBox(height: 12),
                      Text(dateStr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. DYNAMIC TIMETABLE SCREEN (BRANCH SELECTOR)
// ==========================================
// ==========================================
// 4. DYNAMIC TIMETABLE SCREEN (BRANCH SELECTOR)
// ==========================================
class DynamicTimetableScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DynamicTimetableScreen({super.key, this.userData});

  @override
  State<DynamicTimetableScreen> createState() => _DynamicTimetableScreenState();
}

class _DynamicTimetableScreenState extends State<DynamicTimetableScreen> {
  String _selectedBranch = 'ECE';
  final List<String> _branches = ['ECE', 'CSE', 'IT', 'MAC', 'EE', 'MECH'];

  // Form Controllers for the Modal
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  bool _isLab = false;
  bool _isLoading = false;

  bool get isAdmin => widget.userData?['role'] == 'admin';

  // Unified Modal for both Adding (docId == null) and Editing (docId != null)
  void _showTimetableModal({String? docId, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      _subjectController.text = existingData['subject'] ?? '';
      _timeController.text = existingData['time'] ?? '';
      _roomController.text = existingData['room'] ?? '';
      _isLab = existingData['isLab'] ?? false;
    } else {
      _subjectController.clear();
      _timeController.clear();
      _roomController.clear();
      _isLab = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        docId == null ? "Add Schedule Slot" : "Update Schedule Slot",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                          docId == null ? "Adding to $_selectedBranch" : "Updating in $_selectedBranch",
                          style: const TextStyle(color: AppTheme.primary)
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _subjectController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Subject Name"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _timeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Time (e.g. 10:00 AM - 11:00 AM)"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _roomController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Room Number"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 15),

                      SwitchListTile(
                        title: const Text('Is this a Lab Session?', style: TextStyle(color: Colors.white)),
                        value: _isLab,
                        activeColor: AppTheme.primary,
                        onChanged: (val) => setModalState(() => _isLab = val),
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              setModalState(() => _isLoading = true);
                              try {
                                final collectionRef = FirebaseFirestore.instance
                                    .collection('timetable')
                                    .doc(_selectedBranch)
                                    .collection('slots');

                                final data = {
                                  'subject': _subjectController.text.trim(),
                                  'time': _timeController.text.trim(),
                                  'room': _roomController.text.trim(),
                                  'isLab': _isLab,
                                  'timestamp': FieldValue.serverTimestamp(),
                                };

                                if (docId == null) {
                                  await collectionRef.add(data);
                                } else {
                                  await collectionRef.doc(docId).update(data);
                                }

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(docId == null ? 'Slot added!' : 'Slot updated!'),
                                      backgroundColor: AppTheme.primary
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                                );
                              } finally {
                                if (mounted) setModalState(() => _isLoading = false);
                              }
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Text(
                              docId == null ? "Save Slot" : "Update Slot",
                              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSlot(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Slot', style: TextStyle(color: AppTheme.error)),
        content: const Text('Are you sure you want to permanently delete this timetable slot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('timetable')
                    .doc(_selectedBranch)
                    .collection('slots')
                    .doc(docId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Slot deleted'), backgroundColor: AppTheme.error),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                );
              }
            },
            child: const Text('Delete'),
          )
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Schedules')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Selected Branch:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedBranch,
                  dropdownColor: AppTheme.surface,
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBranch = val);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('timetable').doc(_selectedBranch).collection('slots').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No timetable entries found for $_selectedBranch.', style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final slot = doc.data() as Map<String, dynamic>;
                    final isLab = slot['isLab'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: SizedBox(
                          width: 80,
                          child: Center(
                            child: Text(
                              slot['time'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        title: Text(slot['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Room: ${slot['room'] ?? 'TBA'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLab)
                              const Chip(label: Text('LAB', style: TextStyle(fontSize: 10)), backgroundColor: AppTheme.surfaceVariant),
                            if (isAdmin) ...[
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.adminAccent, size: 20),
                                onPressed: () => _showTimetableModal(docId: doc.id, existingData: slot),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppTheme.error, size: 20),
                                onPressed: () => _confirmDeleteSlot(doc.id),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showTimetableModal(),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}
// ==========================================
// 5. PROFILE & EDIT DISPLAY NAME
// ==========================================
class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserProfileScreen({super.key, required this.userData});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _editDisplayName() {
    final nameCtrl = TextEditingController(text: widget.userData['displayName'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Update Display Name'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(widget.userData['uid']).update({
                  'displayName': newName,
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            child: Text(
              (widget.userData['displayName'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.userData['displayName'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(widget.userData['email'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge, color: AppTheme.primary),
                  title: const Text('Roll Number'),
                  trailing: Text(widget.userData['rollNo'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.textSecondary),
                  title: const Text('Edit Display Name'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _editDisplayName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 6. STUDENT DASHBOARD SHELL & ALERTS
// ==========================================
class UserDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserDashboard({super.key, required this.userData});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  String? _lastAnnouncementId;

  @override
  void initState() {
    super.initState();
    _listenForLiveAnnouncements();
  }

  // Simulates in-app push preview notification banner
  void _listenForLiveAnnouncements() {
    FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) {
      if (snap.docs.isNotEmpty) {
        final latest = snap.docs.first;
        if (_lastAnnouncementId != null && _lastAnnouncementId != latest.id) {
          final data = latest.data();
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              backgroundColor: AppTheme.surfaceVariant,
              leading: const Icon(Icons.notifications_active, color: AppTheme.adminAccent),
              content: Text(
                'New Announcement: ${data['title']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    setState(() => _currentIndex = 0); // Jump to feed
                  },
                  child: const Text('VIEW', style: TextStyle(color: AppTheme.adminAccent)),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                  child: const Text('DISMISS', style: TextStyle(color: AppTheme.textSecondary)),
                )
              ],
            ),
          );
        }
        _lastAnnouncementId = latest.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const AnnouncementsFeedScreen(),
      CommunityChatScreen(userData: widget.userData),
      // Pass userData to TimetableScreen here
      DynamicTimetableScreen(userData: widget.userData),
      UserProfileScreen(userData: widget.userData),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign, color: AppTheme.primary), label: 'Notices'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum, color: AppTheme.primary), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: AppTheme.primary), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppTheme.primary), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// 7. ADMIN DASHBOARD & CMS
// ==========================================
class AdminDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;
  const AdminDashboard({super.key, required this.userData});

  void _postAnnouncementDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Post Campus Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Notice Details')),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Urgent Notification'),
                  value: isUrgent,
                  activeColor: AppTheme.error,
                  onChanged: (val) => setDialogState(() => isUrgent = val),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.adminAccent, foregroundColor: Colors.black),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                await FirebaseFirestore.instance.collection('announcements').add({
                  'title': titleCtrl.text.trim(),
                  'body': bodyCtrl.text.trim(),
                  'authorName': userData['displayName'] ?? 'Admin Office',
                  'isUrgent': isUrgent,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
              },
              child: const Text('Broadcast'),
            )
          ],
        ),
      ),
    );
  }

  void _manageTimetableDialog(BuildContext context) {
    String selectedBranch = 'ECE';
    final subjectCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    bool isLab = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Add Branch Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBranch,
                  dropdownColor: AppTheme.surfaceVariant,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: ['ECE', 'CSE', 'IT', 'MAC', 'EE', 'MECH'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setDialogState(() => selectedBranch = val!),
                ),
                const SizedBox(height: 10),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
                const SizedBox(height: 10),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g. 10:00 AM - 11:00 AM)')),
                const SizedBox(height: 10),
                TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room Number (e.g. LH-102)')),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Is this a Lab?'),
                  value: isLab,
                  activeColor: AppTheme.adminAccent,
                  onChanged: (val) => setDialogState(() => isLab = val),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator. pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.adminAccent, foregroundColor: Colors.black),
              onPressed: () async {
                if (subjectCtrl.text.trim().isEmpty || timeCtrl.text.trim().isEmpty) return;
                await FirebaseFirestore.instance.collection('timetable').doc(selectedBranch).collection('slots').add({
                  'subject': subjectCtrl.text.trim(),
                  'time': timeCtrl.text.trim(),
                  'room': roomCtrl.text.trim().isEmpty ? 'LH-101' : roomCtrl.text.trim(),
                  'isLab': isLab,
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add Slot'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Management', style: TextStyle(color: AppTheme.adminAccent)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color: const Color(0xFF1E2738),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppTheme.adminAccent, size: 36),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['displayName'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(userData['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Actions & Privileges', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.notification_add, color: AppTheme.adminAccent),
            title: const Text('Publish Global Notice'),
            subtitle: const Text('Pushes notice to all students'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _postAnnouncementDialog(context),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.calendar_month, color: AppTheme.adminAccent),
            title: const Text('Update Branch Timetables'),
            subtitle: const Text('Add or update schedules for ECE, CSE, etc.'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _manageTimetableDialog(context),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.forum, color: AppTheme.adminAccent),
            title: const Text('Enter Community Chat as Admin'),
            subtitle: const Text('Chat with verified badge styling'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CommunityChatScreen(userData: userData)),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.remove_red_eye, color: AppTheme.primary),
            title: const Text('Preview Student View'),
            subtitle: const Text('Inspect app exactly as students see it'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserDashboard(userData: userData)),
            ),
          ),
        ],
      ),
    );
  }
}