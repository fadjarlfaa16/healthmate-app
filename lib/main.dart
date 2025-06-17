import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- User dari sini
import 'package:supabase_flutter/supabase_flutter.dart'
    hide User; // <-- sembunyikan User
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'utils/Splash.dart';
import 'screen/Login.dart';
import 'screen/Register.dart';
import 'screen/app.dart';
import 'screen/mainhome/Chatbot.dart';
import 'screen/mainhome/BMI.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  await Supabase.initialize(
    url: 'https://xkhygcapifxuxqczoxco.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhraHlnY2FwaWZ4dXhxY3pveGNvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDAyODYyNSwiZXhwIjoyMDU5NjA0NjI1fQ.OVbGL8rbj5uQxlP7v-r2Dc4Q3cl6bpnhTld1J6eIv5E',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/main': (_) => const MainPage(),
        '/chat': (_) => const ChatPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }
        return snapshot.hasData ? const MainPage() : const LoginPage();
      },
    );
  }
}
