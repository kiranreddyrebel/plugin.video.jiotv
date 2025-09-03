import 'package:flutter/material.dart';
import 'package:jiotv_flutter/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? error;

      if (_isOtpMode) {
        error = await authProvider.verifyOtp(
          _mobileController.text,
          _otpController.text,
        );
      } else {
        error = await authProvider.login(
          _mobileController.text,
          _passwordController.text,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _sendOtp() async {
    if (_mobileController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final error = await Provider.of<AuthProvider>(context, listen: false)
          .sendOtp(_mobileController.text);

      setState(() {
        _isLoading = false;
      });

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JioTV Login'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isOtpMode = !_isOtpMode;
              });
            },
            child: Text(
              _isOtpMode ? 'Use Password' : 'Use OTP',
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_isOtpMode) ...[
                      TextFormField(
                        controller: _otpController,
                        decoration: const InputDecoration(labelText: 'OTP'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _sendOtp,
                        child: const Text('Send OTP'),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text(_isOtpMode ? 'Login with OTP' : 'Login'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
