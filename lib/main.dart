import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';

// ---------------------- TEACHER PROFILE MODEL ----------------------
class TeacherProfile {
  static final TeacherProfile _instance = TeacherProfile._internal();
  factory TeacherProfile() => _instance;
  TeacherProfile._internal();

  // Profile Data
  String teacherName = "";
  List<String> gradeLevels = [];
  int classSize = 30;
  List<String> subjects = [];
  List<String> availableResources = [];
  List<String> teachingEnvironment = [];
  List<String> strategiesThatWorked = [];
  List<String> strategiesThatFailed = [];
  String additionalNotes = "";

  bool get isProfileComplete => teacherName.isNotEmpty && gradeLevels.isNotEmpty;
}

// ---------------------- MAIN ENTRY POINT ----------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: This will fail if you haven't added google-services.json to android/app/
  await Firebase.initializeApp();

  runApp(const TeacherAidApp());
}

class TeacherAidApp extends StatelessWidget {
  const TeacherAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classroom Crisis OS',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF5F7FA,
        ), // Soft professional grey
        primaryColor: const Color(0xFF2D3436),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0984E3),
          primary: const Color(0xFF0984E3), // Trustworthy Blue
          secondary: const Color(0xFFFF7675), // Soft Red for Crisis
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AuthGate(),
    );
  }
}

// ---------------------- AUTH GATE (The Security Guard) ----------------------
// This automatically switches between Login and Home based on user status.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainDashboard(); // User is logged in
        }
        return const LoginScreen(); // User needs to login
      },
    );
  }
}

// ---------------------- 1. LOGIN SCREEN (Professional) ----------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      // For MVP Speed: Anonymous Auth (No setup required in console besides enabling it)
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.school_rounded,
                size: 80,
                color: Color(0xFF0984E3),
              ),
              const SizedBox(height: 20),
              Text(
                "Classroom Crisis OS",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Instant AI support for teachers in the moment of need.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 60),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0984E3),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Enter Classroom",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- 2. MAIN DASHBOARD (Tabs) ----------------------
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 1; // Default to Center (Crisis Mode)

  final List<Widget> _pages = [
    const StrategiesPage(),
    const CrisisMicPage(),
    const ActivitiesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0984E3),
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: "Cheat Sheet",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_none_outlined),
              label: "Crisis AI",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_outlined),
              label: "Energizers",
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- 3. THE CRISIS MIC PAGE (Hero Feature) ----------------------
class CrisisMicPage extends StatefulWidget {
  const CrisisMicPage({super.key});

  @override
  State<CrisisMicPage> createState() => _CrisisMicPageState();
}

class _CrisisMicPageState extends State<CrisisMicPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isThinking = false; // Loading state
  bool _hasResult = false;

  String _statusText = "Tap to Report Crisis";
  String _transcript = "";
  String _action = "";
  String _strategy = "";
  StreamSubscription? _accelSubscription;
  DateTime _lastShakeTime = DateTime.now();

  // Quick Situation Filters with mapped solutions
  final List<Map<String, dynamic>> _quickFilters = [
    {
      "label": "Too Loud",
      "icon": Icons.volume_up,
      "color": Colors.redAccent,
      "solutions": [
        {"type": "tactic", "title": "The Stare", "desc": "Non-verbal correction using sustained eye contact.", "steps": ["1. Stop speaking mid-sentence.", "2. Turn fully to disruptor.", "3. Lock eyes for 5 seconds.", "4. Be neutral (no frown).", "5. Nod once and resume."]},
        {"type": "tactic", "title": "3-2-1 Reset", "desc": "Ritualized countdown to regain absolute silence.", "steps": ["1. Stand in Front Center.", "2. Say 'Class in 3..2..1'.", "3. If not silent, say 'Not ready'.", "4. Start over.", "5. Wait for pin-drop silence."]},
        {"type": "tactic", "title": "Proximity", "desc": "Walk towards the noisy area without stopping.", "steps": ["1. Identify noise 'Hot Spot'.", "2. Continue teaching.", "3. Walk into their space.", "4. Stand there 30 seconds.", "5. Move away when calm."]},
      ]
    },
    {
      "label": "One Disruptor",
      "icon": Icons.person_off,
      "color": Colors.orangeAccent,
      "solutions": [
        {"type": "tactic", "title": "Whisper", "desc": "Private correction to avoid power struggles.", "steps": ["1. Crouch to eye level.", "2. Whisper 'Focus please'.", "3. Give specific task.", "4. Walk away immediately.", "5. Don't wait for reply."]},
        {"type": "tactic", "title": "Proximity", "desc": "Walk towards the noisy area without stopping.", "steps": ["1. Identify noise 'Hot Spot'.", "2. Continue teaching.", "3. Walk into their space.", "4. Stand there 30 seconds.", "5. Move away when calm."]},
        {"type": "tactic", "title": "The Stare", "desc": "Non-verbal correction using sustained eye contact.", "steps": ["1. Stop speaking mid-sentence.", "2. Turn fully to disruptor.", "3. Lock eyes for 5 seconds.", "4. Be neutral (no frown).", "5. Nod once and resume."]},
      ]
    },
    {
      "label": "Low Energy",
      "icon": Icons.battery_1_bar,
      "color": Colors.blueAccent,
      "solutions": [
        {"type": "energizer", "title": "Stand Up / Sit Down", "desc": "A high-energy True/False game to wake up the room.", "steps": ["1. Tell everyone to stand up.", "2. Read a statement about the lesson.", "3. 'If True, stay standing. If False, sit down.'", "4. Read the answer. Those who got it wrong are out.", "5. Continue until one winner remains."]},
        {"type": "energizer", "title": "One Word Whip", "desc": "Fast-paced summarization activity.", "steps": ["1. Form a circle or go row-by-row.", "2. Ask: 'Summarize today's lesson in exactly one word.'", "3. Go fast! No repeating words allowed.", "4. If a student hesitates for 3 seconds, skip them.", "5. Do two rounds to see if they can connect ideas."]},
        {"type": "energizer", "title": "Think-Pair-Share", "desc": "Get students talking to each other, not over you.", "steps": ["1. Ask a specific open-ended question.", "2. THINK: '30 seconds of silence. No talking.'", "3. PAIR: 'Turn to your neighbor and discuss for 1 minute.'", "4. SHARE: Call on 3 pairs to share what their PARTNER said.", "5. This reduces anxiety because they aren't sharing their own answer."]},
      ]
    },
    {
      "label": "Transition Chaos",
      "icon": Icons.sync_problem,
      "color": Colors.purpleAccent,
      "solutions": [
        {"type": "tactic", "title": "3-2-1 Reset", "desc": "Ritualized countdown to regain absolute silence.", "steps": ["1. Stand in Front Center.", "2. Say 'Class in 3..2..1'.", "3. If not silent, say 'Not ready'.", "4. Start over.", "5. Wait for pin-drop silence."]},
        {"type": "tactic", "title": "The Stare", "desc": "Non-verbal correction using sustained eye contact.", "steps": ["1. Stop speaking mid-sentence.", "2. Turn fully to disruptor.", "3. Lock eyes for 5 seconds.", "4. Be neutral (no frown).", "5. Nod once and resume."]},
        {"type": "energizer", "title": "Exit Ticket", "desc": "Students must write one thing they learned to leave class.", "steps": ["1. Stop class 5 minutes early.", "2. Write a prompt on the board (e.g., 'Define Mitosis').", "3. Students write the answer on a scrap of paper.", "4. Stand at the door as the 'Gatekeeper'.", "5. They must hand you the ticket to leave the room."]},
      ]
    },
    {
      "label": "Finished Early",
      "icon": Icons.check_circle_outline,
      "color": Colors.teal,
      "solutions": [
        {"type": "energizer", "title": "Two Truths & A Lie", "desc": "Quick engaging game to build relationships and test knowledge.", "steps": ["1. Model it yourself first (Give 2 facts, 1 lie).", "2. Ask students to write down their own 3 statements.", "3. Give them 2 minutes of silent writing time.", "4. Pick 3 random students to share.", "5. The class votes on which one is the lie."]},
        {"type": "energizer", "title": "Think-Pair-Share", "desc": "Get students talking to each other, not over you.", "steps": ["1. Ask a specific open-ended question.", "2. THINK: '30 seconds of silence. No talking.'", "3. PAIR: 'Turn to your neighbor and discuss for 1 minute.'", "4. SHARE: Call on 3 pairs to share what their PARTNER said.", "5. This reduces anxiety because they aren't sharing their own answer."]},
        {"type": "energizer", "title": "One Word Whip", "desc": "Fast-paced summarization activity.", "steps": ["1. Form a circle or go row-by-row.", "2. Ask: 'Summarize today's lesson in exactly one word.'", "3. Go fast! No repeating words allowed.", "4. If a student hesitates for 3 seconds, skip them.", "5. Do two rounds to see if they can connect ideas."]},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
    _initSensors();
  }

  void _initSensors() {
    _accelSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      final now = DateTime.now();
      // Ignore rapid shakes (debounce 2 seconds)
      if (now.difference(_lastShakeTime).inSeconds < 2) return;

      // If phone moves violently (x, y, or z > 15)
      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        _lastShakeTime = now;
        if (!_isListening && !_isThinking) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shake Detected! Panic Mode ON.")),
          );
          _handleMicPress(); // Trigger the mic!
        }
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel(); // Stop sensor when leaving page
    super.dispose();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slower, calmer voice
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _handleMicPress() async {
    if (_isListening) {
      // Stop Listening
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      // Start Listening
      bool available = await _speech.initialize(
        onError: (val) =>
            setState(() => _statusText = "Error: ${val.errorMsg}"),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _hasResult = false;
          _statusText = "Listening...";
          _transcript = "";
        });

        _speech.listen(
          onResult: (val) {
            setState(() => _transcript = val.recognizedWords);
            if (val.finalResult) {
              setState(() => _isListening = false);
              _processCrisis(val.recognizedWords);
            }
          },
        );
      } else {
        setState(() => _statusText = "Mic not available");
      }
    }
  }

  Future<void> _processCrisis(String input) async {
    setState(() {
      _isThinking = true;
      _statusText = "Consulting AI...";
    });

    try {
      // IMPORTANT: Use 10.0.2.2 for Android Emulator.
      // If using a real phone, use your laptop's IP (e.g., 192.168.1.5)
      final url = Uri.parse('http://10.0.2.2:8000/solve_crisis');

      // Get teacher profile for personalized response
      final profile = TeacherProfile();
      
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'transcript': input,
              'profile': profile.isProfileComplete ? {
                'teacher_name': profile.teacherName,
                'grade_levels': profile.gradeLevels,
                'class_size': profile.classSize,
                'subjects': profile.subjects,
                'available_resources': profile.availableResources,
                'teaching_environment': profile.teachingEnvironment,
                'strategies_that_worked': profile.strategiesThatWorked,
                'strategies_that_failed': profile.strategiesThatFailed,
                'additional_notes': profile.additionalNotes,
              } : null,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _deliverSolution(data['action'], data['strategy']);
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      print("AI Failed: $e. Using Offline Backup.");
      // FALLBACK (Offline Mode)
      await Future.delayed(const Duration(seconds: 1));
      _deliverSolution(
        "Stand still. Wait for silence.",
        "Use a 'Think-Pair-Share' to reset focus.",
      );
    }
  }

  void _deliverSolution(String act, String strat) async {
    setState(() {
      _isThinking = false;
      _hasResult = true;
      _statusText = "Solution Found";
      _action = act;
      _strategy = strat;
    });

    await _flutterTts.speak("Action. $act. Strategy. $strat");
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
  }

  void _showQuickSolutions(Map<String, dynamic> filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(filter['icon'], color: filter['color'], size: 28),
                const SizedBox(width: 10),
                Text(
                  filter['label'],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: filter['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Top 3 solutions for this situation:",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: filter['solutions'].length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final solution = filter['solutions'][index];
                  final isTactic = solution['type'] == 'tactic';
                  return GestureDetector(
                    onTap: () => _showSolutionDetail(solution, filter['color']),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isTactic 
                                  ? Colors.redAccent.withOpacity(0.1) 
                                  : Colors.orangeAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTactic ? Icons.psychology : Icons.flash_on,
                              color: isTactic ? Colors.redAccent : Colors.orangeAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isTactic ? Colors.redAccent : Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTactic ? "TACTIC" : "ENERGIZER",
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  solution['title'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  solution['desc'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSolutionDetail(Map<String, dynamic> solution, Color accentColor) {
    Navigator.pop(context); // Close the quick solutions sheet first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  solution['type'] == 'tactic' ? Icons.psychology : Icons.flash_on,
                  color: accentColor,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    solution['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              solution['desc'],
              style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 25),
            Text(
              "STEP-BY-STEP:",
              style: GoogleFonts.oswald(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: solution['steps'].length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: accentColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          solution['steps'][index],
                          style: GoogleFonts.inter(fontSize: 15, height: 1.4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _flutterTts.speak(solution['title'] + ". " + solution['desc']);
                },
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: const Text("Read Aloud"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "CRISIS MODE",
          style: GoogleFonts.oswald(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TeacherProfilePage()),
            );
          },
          icon: const Icon(Icons.person_outline, color: Colors.grey),
          tooltip: 'My Classroom Profile',
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
      body: Column(
        children: [
          // QUICK SITUATION FILTERS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QUICK SITUATION",
                  style: GoogleFonts.oswald(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickFilters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => _showQuickSolutions(filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: filter['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: filter['color'].withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(filter['icon'], size: 18, color: filter['color']),
                                const SizedBox(width: 6),
                                Text(
                                  filter['label'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: filter['color'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // STATUS TEXT
          FadeInDown(
            child: Text(
              _statusText,
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: _isListening
                    ? const Color(0xFF0984E3)
                    : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_transcript.isNotEmpty && _isListening)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '"$_transcript"',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 40),

          // HERO BUTTON (CENTERED & GLOWING)
          Center(
            child: AvatarGlow(
              animate: _isListening || _isThinking,
              glowColor: _isThinking ? Colors.amber : const Color(0xFFFF7675),
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: GestureDetector(
                onTap: _handleMicPress,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _isThinking
                        ? Colors.amber[700]
                        : (_isListening
                              ? const Color(0xFFFF7675)
                              : Colors.white),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isThinking
                        ? Icons.psychology
                        : (_isListening ? Icons.mic : Icons.mic_none),
                    size: 80,
                    color: _isListening || _isThinking
                        ? Colors.white
                        : const Color(0xFFFF7675),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // SOLUTION CARD (Appears from bottom)
          if (_hasResult)
            FadeInUp(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          color: Color(0xFFFF7675),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "IMMEDIATE ACTION",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF7675),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _action,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFF2D3436),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFF0984E3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "TEACHING STRATEGY",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0984E3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _strategy,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                    // --- PASTE THIS FEEDBACK SECTION ---
                    const SizedBox(height: 20),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumbs_up_down,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Was this helpful?",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _feedbackBtn(Icons.thumb_up, Colors.green, "Worked"),
                        _feedbackBtn(Icons.thumb_down, Colors.red, "Failed"),
                      ],
                    ),
                    // -----------------------------------
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _sendFeedback(String feedback) async {
    try {
      final profile = TeacherProfile();
      final url = Uri.parse('http://10.0.2.2:8000/record_feedback');
      
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'crisis_transcript': _transcript,
          'action_given': _action,
          'strategy_given': _strategy,
          'feedback': feedback,
          'profile': profile.isProfileComplete ? {
            'teacher_name': profile.teacherName,
            'grade_levels': profile.gradeLevels,
            'class_size': profile.classSize,
            'subjects': profile.subjects,
            'available_resources': profile.availableResources,
            'teaching_environment': profile.teachingEnvironment,
            'strategies_that_worked': profile.strategiesThatWorked,
            'strategies_that_failed': profile.strategiesThatFailed,
            'additional_notes': profile.additionalNotes,
          } : null,
        }),
      );
      
      // Update local profile with feedback
      if (feedback == "Worked" && _strategy.isNotEmpty) {
        if (!profile.strategiesThatWorked.contains(_strategy)) {
          profile.strategiesThatWorked.add(_strategy);
        }
      } else if (feedback == "Failed" && _strategy.isNotEmpty) {
        if (!profile.strategiesThatFailed.contains(_strategy)) {
          profile.strategiesThatFailed.add(_strategy);
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedback == "Worked" 
            ? "✓ Great! We'll remember this works for you." 
            : "✗ Noted. We'll avoid suggesting this next time."),
          backgroundColor: feedback == "Worked" ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback Recorded: $feedback")),
      );
    }
  }

  Widget _feedbackBtn(IconData icon, Color color, String text) {
    return ElevatedButton.icon(
      onPressed: () => _sendFeedback(text),
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}

// ---------------------- 4. UPGRADED STRATEGIES PAGE ----------------------
// ---------------------- 4. UPGRADED STRATEGIES PAGE (GRID) ----------------------
class StrategiesPage extends StatelessWidget {
  const StrategiesPage({super.key});

  final List<Map<String, dynamic>> data = const [
    {
      "title": "The Stare", 
      "color": Colors.redAccent, 
      "icon": Icons.remove_red_eye,
      "desc": "Non-verbal correction using sustained eye contact.",
      "steps": ["1. Stop speaking mid-sentence.", "2. Turn fully to disruptor.", "3. Lock eyes for 5 seconds.", "4. Be neutral (no frown).", "5. Nod once and resume."]
    },
    {
      "title": "Proximity", 
      "color": Colors.orangeAccent, 
      "icon": Icons.directions_walk,
      "desc": "Walk towards the noisy area without stopping.",
      "steps": ["1. Identify noise 'Hot Spot'.", "2. Continue teaching.", "3. Walk into their space.", "4. Stand there 30 seconds.", "5. Move away when calm."]
    },
    {
      "title": "3-2-1 Reset", 
      "color": Colors.purpleAccent, 
      "icon": Icons.timer,
      "desc": "Ritualized countdown to regain absolute silence.",
      "steps": ["1. Stand in Front Center.", "2. Say 'Class in 3..2..1'.", "3. If not silent, say 'Not ready'.", "4. Start over.", "5. Wait for pin-drop silence."]
    },
    {
      "title": "Whisper", 
      "color": Colors.blueAccent, 
      "icon": Icons.volume_off,
      "desc": "Private correction to avoid power struggles.",
      "steps": ["1. Crouch to eye level.", "2. Whisper 'Focus please'.", "3. Give specific task.", "4. Walk away immediately.", "5. Don't wait for reply."]
    },
    {
      "title": "The Pause", 
      "color": Colors.teal, 
      "icon": Icons.pause_circle_outline,
      "desc": "Strategic silence that forces attention back to you.",
      "steps": ["1. Stop talking mid-lesson.", "2. Stand completely still.", "3. Wait in silence (30-60 seconds).", "4. Make eye contact with attentive students.", "5. Resume only when everyone is watching."]
    },
    {
      "title": "Hand Signals", 
      "color": Colors.deepOrange, 
      "icon": Icons.back_hand,
      "desc": "Silent communication system for common requests.",
      "steps": ["1. Teach signals on Day 1 (bathroom, water, help, agree).", "2. Students raise signal, you nod or shake head.", "3. No verbal interruptions needed.", "4. Practice daily until automatic.", "5. Add new signals as needed."]
    },
    {
      "title": "Choice Consequence", 
      "color": Colors.amber, 
      "icon": Icons.compare_arrows,
      "desc": "Give students ownership of their behavior.",
      "steps": ["1. Name the behavior calmly.", "2. Offer 2 choices: 'Focus now OR move seats'.", "3. Say 'You choose' and walk away.", "4. Wait 10 seconds.", "5. Follow through immediately if they don't comply."]
    },
    {
      "title": "Positive Narration", 
      "color": Colors.green, 
      "icon": Icons.mic_external_on,
      "desc": "Describe desired behavior instead of correcting bad behavior.",
      "steps": ["1. Find a student doing it right.", "2. Say loudly: 'I see Maria is ready with her pencil out'.", "3. Others will mirror the behavior.", "4. Ignore the off-task students.", "5. Thank those who fixed their behavior."]
    },
    {
      "title": "The Redirect", 
      "color": Colors.cyan, 
      "icon": Icons.redo,
      "desc": "Refocus students without calling them out.",
      "steps": ["1. Approach the student calmly.", "2. Tap their desk or paper.", "3. Point to the correct task.", "4. Say nothing or whisper 'Start here'.", "5. Walk away before they can argue."]
    },
    {
      "title": "Timer Pressure", 
      "color": Colors.pinkAccent, 
      "icon": Icons.hourglass_bottom,
      "desc": "Use urgency to eliminate procrastination.",
      "steps": ["1. Set a visible timer (3-5 minutes).", "2. Say 'Beat the clock!'.", "3. No talking during timer.", "4. Celebrate if they finish in time.", "5. Add 30 seconds if they don't make it."]
    },
    {
      "title": "The Broken Record", 
      "color": Colors.indigo, 
      "icon": Icons.repeat,
      "desc": "Repeat the same instruction without emotion.",
      "steps": ["1. Student argues or negotiates.", "2. Repeat exact same phrase: 'Please sit down'.", "3. Don't explain or justify.", "4. Use calm, flat tone.", "5. Repeat up to 3 times, then consequence."]
    },
    {
      "title": "Strategic Praise", 
      "color": Colors.lime, 
      "icon": Icons.emoji_events,
      "desc": "Publicly praise good behavior to encourage others.",
      "steps": ["1. Catch someone doing something right.", "2. Be specific: 'Thank you for raising your hand, Alex'.", "3. Say it loud enough for others to hear.", "4. Ignore attention-seekers.", "5. Rotate who you praise (don't pick favorites)."]
    },
  ];

  void _showDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(children: [
              Icon(item['icon'], color: item['color'], size: 30),
              const SizedBox(width: 10),
              Text(item['title'], style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: item['color'])),
            ]),
            const SizedBox(height: 10),
            Text(item['desc'], style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 30),
            Text("EXECUTION PLAN:", style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: item['steps'].length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: item['color'], size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item['steps'][index], style: GoogleFonts.inter(fontSize: 16, height: 1.4))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CHEAT SHEET"), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.0,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showDetail(context, data[index]),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: data[index]['color'].withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: data[index]['color'].withOpacity(0.1),
                    child: Icon(data[index]['icon'], color: data[index]['color'], size: 30),
                  ),
                  const SizedBox(height: 15),
                  Text(data[index]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text("Tap to View", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// ---------------------- 5. UPGRADED ENERGIZERS PAGE ----------------------
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  final List<Map<String, dynamic>> data = const [
    {
      "title": "Two Truths & A Lie",
      "desc": "Quick engaging game to build relationships and test knowledge.",
      "steps": [
        "1. Model it yourself first (Give 2 facts, 1 lie).",
        "2. Ask students to write down their own 3 statements.",
        "3. Give them 2 minutes of silent writing time.",
        "4. Pick 3 random students to share.",
        "5. The class votes on which one is the lie."
      ]
    },
    {
      "title": "Think-Pair-Share",
      "desc": "Get students talking to each other, not over you.",
      "steps": [
        "1. Ask a specific open-ended question.",
        "2. THINK: '30 seconds of silence. No talking.'",
        "3. PAIR: 'Turn to your neighbor and discuss for 1 minute.'",
        "4. SHARE: Call on 3 pairs to share what their PARTNER said.",
        "5. This reduces anxiety because they aren't sharing their own answer."
      ]
    },
    {
      "title": "Exit Ticket",
      "desc": "Students must write one thing they learned to leave class.",
      "steps": [
        "1. Stop class 5 minutes early.",
        "2. Write a prompt on the board (e.g., 'Define Mitosis').",
        "3. Students write the answer on a scrap of paper.",
        "4. Stand at the door as the 'Gatekeeper'.",
        "5. They must hand you the ticket to leave the room."
      ]
    },
    {
      "title": "Stand Up / Sit Down",
      "desc": "A high-energy True/False game to wake up the room.",
      "steps": [
        "1. Tell everyone to stand up.",
        "2. Read a statement about the lesson.",
        "3. 'If True, stay standing. If False, sit down.'",
        "4. Read the answer. Those who got it wrong are out.",
        "5. Continue until one winner remains."
      ]
    },
    {
      "title": "One Word Whip",
      "desc": "Fast-paced summarization activity.",
      "steps": [
        "1. Form a circle or go row-by-row.",
        "2. Ask: 'Summarize today's lesson in exactly one word.'",
        "3. Go fast! No repeating words allowed.",
        "4. If a student hesitates for 3 seconds, skip them.",
        "5. Do two rounds to see if they can connect ideas."
      ]
    },
    {
      "title": "4 Corners",
      "desc": "Movement-based multiple choice game.",
      "steps": [
        "1. Label corners A, B, C, D.",
        "2. Ask a multiple choice question.",
        "3. Students run to the corner with their answer.",
        "4. Reveal the correct answer.",
        "5. Those in the wrong corner sit down."
      ]
    },
    {
      "title": "Popcorn Reading",
      "desc": "Keeps everyone alert during reading time.",
      "steps": [
        "1. Start reading a passage aloud.",
        "2. After 2-3 sentences, say 'Popcorn to... Sarah'.",
        "3. Sarah continues reading.",
        "4. She can 'popcorn' to anyone after her turn.",
        "5. No one knows when they'll be called - keeps focus high."
      ]
    },
    {
      "title": "Brain Break - Stretch",
      "desc": "1-minute physical reset to refocus energy.",
      "steps": [
        "1. Everyone stands behind their chair.",
        "2. Touch toes (10 seconds).",
        "3. Reach for the sky (10 seconds).",
        "4. Twist left and right (10 seconds each).",
        "5. Take 3 deep breaths and sit down."
      ]
    },
    {
      "title": "Silent Ball",
      "desc": "Reward game that requires absolute silence.",
      "steps": [
        "1. Students stand on chairs (if safe).",
        "2. Toss a soft ball to each other.",
        "3. If you talk, drop the ball, or throw badly - you're out.",
        "4. Last person standing wins.",
        "5. Takes 3-5 minutes and resets the room energy."
      ]
    },
    {
      "title": "Quiz-Quiz-Trade",
      "desc": "Partner activity for reviewing flashcards or facts.",
      "steps": [
        "1. Give each student a flashcard.",
        "2. Find a partner.",
        "3. Quiz each other (1 question each).",
        "4. Trade cards.",
        "5. Find a new partner and repeat for 3 minutes."
      ]
    },
    {
      "title": "Whiteboard Race",
      "desc": "Competitive team challenge for quick review.",
      "steps": [
        "1. Divide class into 3-4 teams.",
        "2. Give each team a whiteboard and marker.",
        "3. Ask a question.",
        "4. First team to hold up the correct answer gets a point.",
        "5. Play 5 rounds. Winning team gets a small reward."
      ]
    },
    {
      "title": "Snowball Fight",
      "desc": "Fun way to share answers or ideas.",
      "steps": [
        "1. Students write an answer to a question on paper.",
        "2. Crumple it into a 'snowball'.",
        "3. On your signal, throw snowballs across the room.",
        "4. Everyone picks up a snowball and reads it aloud.",
        "5. Discuss the most interesting answers."
      ]
    },
  ];

  void _showDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, color: Colors.grey[300])),
            const SizedBox(height: 20),
            Text(item['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            const SizedBox(height: 10),
            Text(item['desc'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            const Text("GAME RULES:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: item['steps'].length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item['steps'][index], style: const TextStyle(fontSize: 16))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Energizers"), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _showDetail(context, data[index]),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(width: 4, height: 50, color: Colors.orangeAccent),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data[index]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(data[index]['desc'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      const Text("Tap for Rules >", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildCard(Map<String, String> item, Color color) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']!,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['desc']!,
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ---------------------- 6. TEACHER PROFILE PAGE ----------------------
class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  final _profile = TeacherProfile();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _classSizeController = TextEditingController();

  // Options for multi-select
  final List<String> _gradeOptions = ['Pre-K', 'K', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th', '11th', '12th'];
  final List<String> _subjectOptions = ['Math', 'Science', 'English', 'History', 'Art', 'Music', 'PE', 'Languages', 'Computer Science', 'Special Ed', 'Multiple/All'];
  final List<String> _resourceOptions = ['Projector/Screen', 'Whiteboard', 'Computers/Tablets', 'Outdoor Space', 'Art Supplies', 'Music Instruments', 'Sports Equipment', 'Library Access', 'Internet Access', 'Limited Resources'];
  final List<String> _environmentOptions = ['Multi-grade Classroom', 'Large Class (30+)', 'Small Class (<15)', 'Language Diversity', 'Rural/Village School', 'Urban School', 'Special Needs Students', 'Mixed Ability Levels', 'Remote/Hybrid'];

  @override
  void initState() {
    super.initState();
    _nameController.text = _profile.teacherName;
    _classSizeController.text = _profile.classSize.toString();
    _notesController.text = _profile.additionalNotes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _classSizeController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    _profile.teacherName = _nameController.text;
    _profile.classSize = int.tryParse(_classSizeController.text) ?? 30;
    _profile.additionalNotes = _notesController.text;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✓ Profile Saved! AI will personalize recommendations."),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildSection(String title, String subtitle, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required List<String> selected,
    required Function(List<String>) onChanged,
    Color? color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selected.remove(option);
              } else {
                selected.add(option);
              }
              onChanged(selected);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? (color ?? const Color(0xFF0984E3)) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? (color ?? const Color(0xFF0984E3)) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          "MY CLASSROOM",
          style: GoogleFonts.oswald(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              "SAVE",
              style: GoogleFonts.inter(
                color: const Color(0xFF0984E3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0984E3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0984E3).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF0984E3), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This helps the AI give you personalized strategies that actually work in YOUR classroom.",
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0984E3)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Teacher Name
            _buildSection(
              "Your Name",
              "How should we address you?",
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "e.g., Ms. Johnson",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),

            // Grade Levels
            _buildSection(
              "Grade Levels",
              "Select all grades you teach",
              _buildChipSelector(
                options: _gradeOptions,
                selected: _profile.gradeLevels,
                onChanged: (val) => _profile.gradeLevels = val,
                color: Colors.purpleAccent,
              ),
            ),

            // Class Size
            _buildSection(
              "Typical Class Size",
              "Average number of students",
              TextField(
                controller: _classSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "e.g., 30",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.groups, color: Colors.grey),
                ),
              ),
            ),

            // Subjects
            _buildSection(
              "Subjects Taught",
              "Select all that apply",
              _buildChipSelector(
                options: _subjectOptions,
                selected: _profile.subjects,
                onChanged: (val) => _profile.subjects = val,
                color: Colors.teal,
              ),
            ),

            // Available Resources
            _buildSection(
              "Available Resources",
              "What tools do you have access to?",
              _buildChipSelector(
                options: _resourceOptions,
                selected: _profile.availableResources,
                onChanged: (val) => _profile.availableResources = val,
                color: Colors.orangeAccent,
              ),
            ),

            // Teaching Environment
            _buildSection(
              "Teaching Environment",
              "Describe your classroom context",
              _buildChipSelector(
                options: _environmentOptions,
                selected: _profile.teachingEnvironment,
                onChanged: (val) => _profile.teachingEnvironment = val,
                color: Colors.blueAccent,
              ),
            ),

            // Strategies That Worked
            _buildSection(
              "What Works For You? ✓",
              "Tap to add strategies that have worked in your classroom",
              Column(
                children: [
                  _buildChipSelector(
                    options: ['Silent Signals', 'Proximity Control', 'Countdown', 'Whisper Correction', 'Brain Breaks', 'Group Rewards', 'Music Cues', 'Movement Activities'],
                    selected: _profile.strategiesThatWorked,
                    onChanged: (val) => _profile.strategiesThatWorked = val,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            // Strategies That Failed
            _buildSection(
              "What Doesn't Work? ✗",
              "We'll avoid recommending these",
              Column(
                children: [
                  _buildChipSelector(
                    options: ['Yelling', 'Public Shaming', 'Removing Recess', 'Calling Parents', 'Isolation', 'Competition', 'Long Lectures'],
                    selected: _profile.strategiesThatFailed,
                    onChanged: (val) => _profile.strategiesThatFailed = val,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),

            // Additional Notes
            _buildSection(
              "Additional Notes",
              "Anything else the AI should know?",
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g., 'My students respond well to humor' or 'I have 3 students with ADHD'",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0984E3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save My Classroom Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
