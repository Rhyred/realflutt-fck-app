import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  LoginSignupScreenState createState() => LoginSignupScreenState();
}

class LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLogin = true;
  bool _isLoading = false; // Menambahkan status loading
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return; // Tambahkan pemeriksaan mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      // Navigasi ke dashboard saat berhasil
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan (misalnya, tampilkan snackbar)
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      _showErrorSnackbar('Gagal masuk: ${e.message}');
    } finally {
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });
    if (_passwordController.text != _confirmPasswordController.text) {
      // Kata sandi tidak cocok (misalnya, tampilkan snackbar)
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      _showErrorSnackbar('Kata sandi tidak cocok');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      // Navigasi ke dashboard saat berhasil
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan (misalnya, tampilkan snackbar)
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      _showErrorSnackbar('Gagal mendaftar: ${e.message}');
    } finally {
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Pengguna membatalkan proses masuk
        if (!mounted) return; // Tambahkan pemeriksaan mounted
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      // Navigasi ke dashboard saat berhasil
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan (misalnya, tampilkan snackbar)
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      _showErrorSnackbar('Gagal masuk dengan Google: ${e.message}');
    } finally {
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      // Navigasi ke dashboard saat berhasil
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan (misalnya, tampilkan snackbar)
      if (!mounted) return; // Tambahkan pemeriksaan mounted
      _showErrorSnackbar('Gagal masuk secara anonim: ${e.message}');
    } finally {
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                // Menambahkan Stack untuk indikator loading
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        _isLogin ? 'Welcome Back!' : 'Create Account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withAlpha(25),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withAlpha(25),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16.0),
                      if (!_isLogin)
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withAlpha(25),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                        ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isLogin
                                ? _signInWithEmailPassword
                                : _signUpWithEmailPassword),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextButton(
                        onPressed: _isLoading ? null : _toggleForm,
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Sign Up'
                              : 'Already have an account? Login',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                        ),
                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 24.0,
                          color: Colors.indigo,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signInAnonymously,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading) // Tampilkan indikator loading saat isLoading bernilai true
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
