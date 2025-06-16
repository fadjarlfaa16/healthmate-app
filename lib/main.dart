// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'utils/Splash.dart';
// import 'screen/Login.dart';
// import 'screen/Register.dart';
// import 'screen/app.dart';
// import 'screen/mainhome/Chatbot.dart';
// import 'screen/mainhome/BMI.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
//   await Supabase.initialize(
//     url: 'https://xkhygcapifxuxqczoxco.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhraHlnY2FwaWZ4dXhxY3pveGNvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDAyODYyNSwiZXhwIjoyMDU5NjA0NjI1fQ.OVbGL8rbj5uQxlP7v-r2Dc4Q3cl6bpnhTld1J6eIv5E',
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // The MaterialApp uses the Splash page as the initial route.
//   // We also include an onGenerateRoute middleware to guard protected routes.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'HealthMate',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/splash',
//       onGenerateRoute: (RouteSettings settings) {
//         // For protected routes, check if a user is logged in.
//         if (settings.name == '/main' || settings.name == '/chat') {
//           if (FirebaseAuth.instance.currentUser == null) {
//             return MaterialPageRoute(builder: (_) => const LoginPage());
//           }
//           if (settings.name == '/main') {
//             return MaterialPageRoute(builder: (_) => const MainPage());
//           } else if (settings.name == '/chat') {
//             return MaterialPageRoute(builder: (_) => const ChatPage());
//           }
//         }
//         // For all other routes, let the defined routes handle them.
//         return null;
//       },
//       routes: {
//         '/splash': (context) => const SplashPage(),
//         '/login': (context) => const LoginPage(),
//         '/register': (context) => const RegisterPage(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- User dari sini
import 'package:supabase_flutter/supabase_flutter.dart'
    hide User; // <-- sembunyikan User

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
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
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
      home: const AuthGate(),
      routes: {
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
