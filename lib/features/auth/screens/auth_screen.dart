import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/gradient_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _signInForm = GlobalKey<FormState>();
  final _signUpForm = GlobalKey<FormState>();

  // Sign-in fields
  final _siEmail = TextEditingController();
  final _siPass  = TextEditingController();

  // Sign-up fields
  final _suName  = TextEditingController();
  final _suEmail = TextEditingController();
  final _suPass  = TextEditingController();
  final _suPass2 = TextEditingController();

  bool _loading = false;
  bool _obscureSi = true;
  bool _obscureSu = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _siEmail.dispose(); _siPass.dispose();
    _suName.dispose(); _suEmail.dispose();
    _suPass.dispose(); _suPass2.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_signInForm.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.signIn(email: _siEmail.text.trim(), password: _siPass.text);
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_signUpForm.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.signUp(
        email: _suEmail.text.trim(),
        password: _suPass.text,
        displayName: _suName.text.trim(),
      );
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _siEmail.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email first, then tap Forgot Password.');
      return;
    }
    try {
      await AuthService.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Good Habits — Sign In'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Sign In'),
            Tab(text: 'Create Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildSignIn(),
          _buildSignUp(),
        ],
      ),
    );
  }

  // ── Sign In tab ──────────────────────────────────────────────────────────
  Widget _buildSignIn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _signInForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Center(child: Text('👤', style: TextStyle(fontSize: 56))),
            const SizedBox(height: 12),
            Text('Welcome back!', style: AppTextStyles.h3,
                textAlign: TextAlign.center),
            Text('Sign in to access your group leaderboard.',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 32),

            _field(
              controller: _siEmail,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _siPass,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscureSi,
              onToggleObscure: () => setState(() => _obscureSi = !_obscureSi),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Sign In',
              onPressed: _signIn,
              loading: _loading,
              icon: Icons.login_rounded,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _tabs.animateTo(1),
              child: const Text("Don't have an account? Create one →"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sign Up tab ──────────────────────────────────────────────────────────
  Widget _buildSignUp() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _signUpForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Center(child: Text('🌟', style: TextStyle(fontSize: 56))),
            const SizedBox(height: 12),
            Text('Create Account', style: AppTextStyles.h3,
                textAlign: TextAlign.center),
            Text('One account per family is enough.',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 32),

            _field(
              controller: _suName,
              label: 'Your Name (parent)',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _suEmail,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _suPass,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscureSu,
              onToggleObscure: () => setState(() => _obscureSu = !_obscureSu),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _suPass2,
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscureSu,
              validator: (v) => v != _suPass.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Create Account',
              onPressed: _signUp,
              loading: _loading,
              icon: Icons.person_add_rounded,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _tabs.animateTo(0),
              child: const Text('Already have an account? Sign in →'),
            ),
          ],
        ),
      ),
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email';
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}
