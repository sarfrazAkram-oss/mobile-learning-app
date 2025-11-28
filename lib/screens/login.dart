import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'home.dart';

class SignInPage extends StatefulWidget {
  final String language; // 'en', 'ur', 'ar'

  const SignInPage({super.key, required this.language});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isSignUp = false;
  String? _emailError;
  String? _passwordError;

  bool _validateInputs() {
    bool isValid = true;

    // Simple validation - just check if not empty
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    // Simple password validation - just check if not empty
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    return isValid;
  }

  Future<void> _signInWithEmail() async {
    if (!_validateInputs()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);
    // capture navigator early so we can navigate after awaits
    final navigator = Navigator.of(context);

    try {
      if (_isSignUp) {
        // Try to create account first if in signup mode
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Try to sign in if in login mode
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // If successful, save login state and go to Home
      await AuthService.saveLoginState(email);
      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password. Please try again.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Your login session has expired. Please enter your password again.';
          // Clear saved credentials as they're no longer valid
          await AuthService.logout();
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Fallback: proceed to Home anyway (guest/local) per user request
        await AuthService.saveLoginState(email);
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Proceeding to Home.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        // Fallback: save local state and navigate to Home
        await AuthService.saveLoginState(email);
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    // Capture navigation context
    final navigator = Navigator.of(context);

    try {
      if (kIsWeb) {
        // Web uses popup
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // user cancelled - reset loading and return
          if (mounted) setState(() => _loading = false);
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = FirebaseAuth.instance.currentUser;
      await AuthService.saveLoginState(user?.email ?? '');
      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = const Color(0xFF263238);
    final subtitleColor = Colors.grey[600];

    final t = {
      'en': {
        'title': 'Begin Your Sacred Journey',
        'subtitle': 'Learn the Quran, Beautifully.',
        'continueWithGoogle': 'Continue with Google',
        'continueWithApple': 'Continue with Apple',
        'or': 'or',
        'email': 'Email Address',
        'password': 'Password',
        'forgot': 'Forgot Password?',
        'continue': 'Continue',
        'terms_prefix': 'By continuing, you agree to our ',
        'terms': 'Terms of Service',
        'and': ' and ',
        'privacy': 'Privacy Policy',
      },
      'ur': {
        'title': 'اپنا مقدس سفر شروع کریں',
        'subtitle': 'خوبصورتی سے قرآن سیکھیں۔',
        'continueWithGoogle': 'گوگل کے ساتھ جاری رکھیں',
        'continueWithApple': 'ایپل کے ساتھ جاری رکھیں',
        'or': 'یا',
        'email': 'ای میل ایڈریس',
        'password': 'پاس ورڈ',
        'forgot': 'پاس ورڈ بھول گئے؟',
        'continue': 'جاری رکھیں',
        'terms_prefix': 'جاری رکھ کر، آپ ہماری ',
        'terms': 'شرائطِ خدمت',
        'and': ' اور ',
        'privacy': 'پرائیویسی پالیسی',
      },
      'ar': {
        'title': 'ابدأ رحلتك المقدسة',
        'subtitle': 'تعلم القرآن، بجمال.',
        'continueWithGoogle': 'المتابعة عبر Google',
        'continueWithApple': 'المتابعة عبر Apple',
        'or': 'أو',
        'email': 'عنوان البريد الإلكتروني',
        'password': 'كلمة المرور',
        'forgot': 'نسيت كلمة المرور؟',
        'continue': 'متابعة',
        'terms_prefix': 'بالمتابعة، فإنك توافق على ',
        'terms': 'شروط الخدمة',
        'and': ' و ',
        'privacy': 'سياسة الخصوصية',
      },
    }[widget.language]!;

    final isRtl = (widget.language == 'ar' || widget.language == 'ur');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F6F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book,
                      color: Color(0xFF17807F),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t['subtitle']!,
                  style: TextStyle(color: subtitleColor, fontSize: 16),
                ),
                const SizedBox(height: 24),

                _SocialButton(
                  icon: _GoogleIcon(),
                  label: t['continueWithGoogle']!,
                  onTap: _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  icon: const Icon(Icons.apple, color: Colors.black),
                  label: t['continueWithApple']!,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apple sign-in not implemented'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        t['or']!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1, height: 1)),
                  ],
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) async {
                    if (_emailError != null) _validateInputs();

                    // If the email was previously used, switch to login mode
                    final email = value.trim();
                    if (email.contains('@')) {
                      try {
                        final previousEmail =
                            await AuthService.getLastLoginEmail();
                        if (previousEmail == email) {
                          setState(() => _isSignUp = false);
                          // Show a helpful message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Welcome back! Please enter your password to login.',
                                ),
                                backgroundColor: Color(0xFF1E8B88),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Ignore errors during email check
                      }
                    }
                  },
                  decoration: InputDecoration(
                    hintText: t['email']!,
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _emailError,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  onChanged: (value) {
                    if (_passwordError != null) _validateInputs();
                  },
                  decoration: InputDecoration(
                    hintText: t['password']!,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _passwordError,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
                    ),
                    child: Text(
                      t['forgot']!,
                      style: const TextStyle(color: Color(0xFF4A90E2)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8B88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            t['continue']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: t['terms_prefix'],
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: t['terms'],
                          style: const TextStyle(color: Color(0xFF4A90E2)),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(text: t['and']),
                        TextSpan(
                          text: t['privacy'],
                          style: const TextStyle(color: Color(0xFF4A90E2)),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            SizedBox(width: 28, child: Center(child: icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple colored 'G' approximation using Text; replace with asset if available
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('This page is replaced by Home navigation.')),
    );
  }
}
