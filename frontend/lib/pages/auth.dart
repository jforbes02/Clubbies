// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/auth.dart';
import 'home.dart';
final authService = AuthService();
final storageService = StorageService();
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin{
  bool isLogin = true;
  bool isLoading = false;
  bool isTestingConnection = false;
  late AnimationController _controller;
  late Animation<double> _fanimation;

  // Dark theme colors with mint green accents
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _mintGreenDark = Color(0xFF7A9B87);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

  //formdata
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  //initialization of animations (starts automatically)
  @override
  void initState(){
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fanimation = Tween<double>(begin:0.0, end:1.0).animate(_controller);
    _controller.forward();
  }

  //cleanup
  @override
  void dispose(){
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  //toggle between login and signup
  void toggleAuth() {
    setState((){
      isLogin = !isLogin;
      _controller.reset();
      _controller.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: _backgroundDark,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _backgroundDark,
                _surfaceDark,
                _backgroundDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fanimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _mintGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _mintGreen.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.nightlife,
                              size: 64,
                              color: _mintGreen,
                            ),
                          ),
                          SizedBox(height:24),
                          Text('Clubbies', style:TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: 2.0,
                          ),
                          ),
                          SizedBox(height:8),
                          Text(
                            isLogin ? 'Welcome Back' : 'Join the Night',
                            style: TextStyle(
                              fontSize: 18,
                              color: _textSecondary,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                        ),
                    ),
                    SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fanimation,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX:10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _cardDark.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _mintGreen.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildGlassTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                    icon: Icons.person_outline,
                                  ),
                                  SizedBox(height:8),
                                
                                  if(!isLogin) ...[
                                    _buildGlassTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                  _buildGlassTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 8),
                                  if(!isLogin) ...[
                                    _buildGlassTextField(
                                      controller: _ageController,
                                      label: 'Age',
                                      icon: Icons.calendar_today_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                    SizedBox(height: 8),
                                ],
                                SizedBox(height: isLogin ? 16: 0),
                                _buildGlassButton(
                                  onPressed: () async{
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => isLoading = true);
                                      try {
                                        AuthToken token;
                                        if (isLogin){
                                          token = await authService.login(
                                            username: _usernameController.text,
                                            password: _passwordController.text,
                                          );
                                        } else{
                                          token = await authService.register(
                                            username: _usernameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                            age: int.parse(_ageController.text.trim()),
                                          );
                                        }
                                        await storageService.saveTokens(token.accessToken, token.refreshToken, token.tokenType);

                                        if (mounted){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isLogin ? '✅ Login Successful!' : '✅ Registration Successful!'),
                                              backgroundColor: _mintGreenDark,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                          // Navigate to HomePage
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => const HomePage(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('❌ Error: ${e.toString()}'),
                                              backgroundColor: Colors.red.shade900,
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => isLoading = false);
                                      }

                                    } else {
                                      if (mounted){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('❌ Please fill in all fields correctly.'),
                                            backgroundColor: Colors.red.shade900,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  text: isLogin ? 'Login' : 'Create Account',
                                  isLoading: isLoading,
                                ),
                                SizedBox(height: 8),
                                TextButton(
                                  onPressed: toggleAuth,
                                  child: Text(
                                    isLogin
                                       ? "Don't have an account? Sign Up"
                                        :"Already have an account? Login",
                                    style: TextStyle(
                                      color: _mintGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTestConnectionButton(),
                              ],),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          ),
        ),
      );
    }
    Widget _buildGlassTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: _surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _mintGreen.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: _textPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: _textSecondary,
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: _mintGreen.withValues(alpha: 0.7)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your $label';
            }
            // Additional validation for specific fields
            if (label == 'Username' && value.trim().length < 4) {
              return 'Username must be at least 4 characters';
            }
            if (label == 'Password' && value.trim().length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (label == 'Age') {
              final age = int.tryParse(value.trim());
              if (age == null) {
                return 'Please enter a valid age';
              }
              if (age < 16) {
                return 'You must be at least 16 years old';
              }
            }
            if (label == 'Email' && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      );
    }

    Widget _buildGlassButton({
      required Future<void> Function() onPressed,
      required String text,
      bool isLoading = false,
    }) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _mintGreen,
              _mintGreenDark,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: _mintGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_backgroundDark),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: _backgroundDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    }

    Widget _buildTestConnectionButton() {
      return OutlinedButton.icon(
        onPressed: isTestingConnection ? null : () async {
          setState(() => isTestingConnection = true);
          try {
            final result = await authService.testConnection();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success'] ? _mintGreenDark : Colors.red.shade900,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } finally {
            if (mounted) setState(() => isTestingConnection = false);
          }
        },
        icon: isTestingConnection
            ? SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
                ),
              )
            : Icon(Icons.wifi_find, size: 18, color: _mintGreen),
        label: Text(
          'Test API Connection',
          style: TextStyle(
            color: _mintGreen,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mintGreen.withValues(alpha: 0.5), width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
}

