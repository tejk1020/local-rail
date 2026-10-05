import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SAVE REMEMBER ME PREFERENCE
  // ==========================================================

  Future<void> _saveRememberMePreference() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'remember_me',
      _rememberMe,
    );
  }

  // ==========================================================
  // REGISTER USER
  // ==========================================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ------------------------------------------------------
      // 1. CREATE FIREBASE AUTH ACCOUNT
      // ------------------------------------------------------

      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        throw Exception(
          'User account could not be created.',
        );
      }

      // ------------------------------------------------------
      // 2. CREATE USER PROFILE IN FIRESTORE
      // ------------------------------------------------------

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'passenger',
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      // ------------------------------------------------------
      // 3. SAVE REMEMBER ME
      // ------------------------------------------------------

      await _saveRememberMePreference();

      // ------------------------------------------------------
      // 4. SUCCESS
      // ------------------------------------------------------

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (context) =>
          const HomeScreen(),
        ),

            (route) => false,
      );
    }

    // --------------------------------------------------------
    // FIREBASE AUTHENTICATION ERRORS
    // --------------------------------------------------------

    on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
          'This email is already registered.';
          break;

        case 'invalid-email':
          message =
          'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
          'Password is too weak.';
          break;

        case 'operation-not-allowed':
          message =
          'Email/password authentication is not enabled.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your internet connection.';
          break;

        default:
          message =
              e.message ??
                  'Registration failed.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }

    // --------------------------------------------------------
    // FIRESTORE ERRORS
    // --------------------------------------------------------

    on FirebaseException catch (e) {
      String message;

      switch (e.code) {
        case 'permission-denied':
          message =
          'Firestore permission denied. Check your Firestore rules.';
          break;

        case 'unavailable':
          message =
          'Firestore is temporarily unavailable. Try again.';
          break;

        default:
          message =
              e.message ??
                  'Could not save user information.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }

    // --------------------------------------------------------
    // OTHER ERRORS
    // --------------------------------------------------------

    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    // --------------------------------------------------------
    // STOP LOADING
    // --------------------------------------------------------

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // USER INTERFACE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 450,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [
                    // ------------------------------------------------
                    // ICON
                    // ------------------------------------------------

                    const Icon(
                      Icons.person_add_alt_1,
                      size: 65,
                      color: Colors.indigo,
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    const Text(
                      'Create Account',
                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Register to use Smart Local Train',
                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ------------------------------------------------
                    // NAME
                    // ------------------------------------------------

                    TextFormField(
                      controller:
                      _nameController,

                      textCapitalization:
                      TextCapitalization.words,

                      decoration:
                      InputDecoration(
                        labelText:
                        'Full Name',
                        hintText:
                        'Enter your full name',

                        prefixIcon:
                        const Icon(
                          Icons.person_outline,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        if (value.trim().length <
                            2) {
                          return 'Name is too short';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // EMAIL
                    // ------------------------------------------------

                    TextFormField(
                      controller:
                      _emailController,

                      keyboardType:
                      TextInputType.emailAddress,

                      decoration:
                      InputDecoration(
                        labelText: 'Email',
                        hintText:
                        'Enter your email',

                        prefixIcon:
                        const Icon(
                          Icons.email_outlined,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        final String email =
                        value.trim();

                        final bool
                        isValidEmail =
                        RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email);

                        if (!isValidEmail) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // PHONE
                    // ------------------------------------------------

                    TextFormField(
                      controller:
                      _phoneController,

                      keyboardType:
                      TextInputType.phone,

                      maxLength: 10,

                      decoration:
                      InputDecoration(
                        labelText:
                        'Phone Number',
                        hintText:
                        'Enter 10-digit number',

                        prefixIcon:
                        const Icon(
                          Icons.phone_outlined,
                        ),

                        counterText: '',

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }

                        if (!RegExp(
                          r'^[0-9]{10}$',
                        ).hasMatch(
                          value.trim(),
                        )) {
                          return 'Enter a valid 10-digit number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // PASSWORD
                    // ------------------------------------------------

                    TextFormField(
                      controller:
                      _passwordController,

                      obscureText:
                      _obscurePassword,

                      decoration:
                      InputDecoration(
                        labelText:
                        'Password',
                        hintText:
                        'Enter password',

                        prefixIcon:
                        const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                .visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // ------------------------------------------------
                    // REMEMBER ME
                    // ------------------------------------------------

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,

                          onChanged: _isLoading
                              ? null
                              : (value) {
                            setState(() {
                              _rememberMe =
                                  value ?? false;
                            });
                          },
                        ),

                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // REGISTER BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      height: 52,

                      child: FilledButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _register,

                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,

                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            Colors.white,
                          ),
                        )
                            : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // INFORMATION
                    // ------------------------------------------------

                    const Text(
                      'By creating an account, you can book '
                          'tickets, manage your tickets and transfer '
                          'individual tickets to other registered users.',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}