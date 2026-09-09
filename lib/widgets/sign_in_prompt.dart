import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';

class SignInPrompt extends StatelessWidget {
  final String message;
  const SignInPrompt({super.key, this.message = 'Sign in to see this.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
