import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import 'root_shell.dart';

/// The original app lets you read today's fact and grade the quiz while
/// signed out (progress just isn't persisted) — so this app never force-
/// gates on sign-in. RootShell is always shown; Saved and Profile prompt
/// for sign-in themselves when there's no session (see SignInPrompt).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.resync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService.resync();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds RootShell's subtree whenever auth state flips, so
    // Saved/Profile immediately reflect sign-in/out without a manual pull.
    return StreamBuilder<AuthState>(
      stream: SupabaseService.auth.onAuthStateChange,
      builder: (context, snapshot) {
        return RootShell(key: ValueKey(SupabaseService.currentUser?.id ?? 'anon'));
      },
    );
  }
}
