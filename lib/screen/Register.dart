// lib/screens/RegisterPage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for formatting birth date
import 'dart:convert';
import 'package:crypto/crypto.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _domicileCtrl = TextEditingController();
  bool _loading = false;

  String _hashPassword(String pwd) {
    final bytes = utf8.encode(pwd);
    return sha256.convert(bytes).toString();
  }

  Future<void> _pickBirthDate() async {
    final today = DateTime.now();
    final initial = today.subtract(const Duration(days: 365 * 20));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null) {
      _birthCtrl.text = DateFormat('dd:MM:yyyy').format(picked);
    }
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _passCtrl.text.trim();
    final birthStr = _birthCtrl.text.trim();
    final domicile = _domicileCtrl.text.trim();

    if ([name, email, pwd, birthStr, domicile].any((s) => s.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // parse birth date and compute age
    DateTime birthDate;
    try {
      birthDate = DateFormat('dd:MM:yyyy').parseStrict(birthStr);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid birth date format')),
      );
      return;
    }
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    setState(() => _loading = true);

    try {
      // 1) Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pwd,
      );
      final uid = cred.user!.uid;

      // 2) Hash the password
      final hashed = _hashPassword(pwd);

      // 3) Write to Firestore with nested profile
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'password': hashed,
        'accountCreated': DateTime.now().toIso8601String(),
        'profile': {
          'fullname': name,
          'birth': birthStr,
          'age': age,
          'domicile': domicile,
        },
      });

      // 4) Navigate into the app
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _birthCtrl.dispose();
    _domicileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // reuse your existing gradient background if you like
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Header
              const Text(
                'Welcome to Healthmate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A8DEE),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your health assistant',
                style: TextStyle(fontSize: 16, color: Color(0xFF699AF9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Full Name
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Birth Date
                    TextField(
                      controller: _birthCtrl,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      decoration: InputDecoration(
                        labelText: 'Birth Date',
                        prefixIcon: const Icon(Icons.cake),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Domicile
                    TextField(
                      controller: _domicileCtrl,
                      decoration: InputDecoration(
                        labelText: 'Domicile',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
