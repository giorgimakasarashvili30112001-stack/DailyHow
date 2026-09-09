import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/api.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sign_in_prompt.dart';
import '../widgets/streak_calendar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileState? _profile;
  bool _loading = true;
  bool _remindersOn = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!SupabaseService.isSignedIn) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final profile = await Api.getProfile();
    final remindersOn = await NotificationService.isEnabled();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _nameController.text = profile.displayName ?? '';
      _remindersOn = remindersOn;
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await Api.updateDisplayName(name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: !SupabaseService.isSignedIn
          ? const SignInPrompt(message: 'Sign in to track your streak, coins, and stats.')
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _stat('${_profile?.streakCount ?? 0}', 'Day streak', textTheme),
                        _stat('${_profile?.longestStreak ?? 0}', 'Best streak', textTheme),
                        _stat('${_profile?.coins ?? 0}', 'Coins', textTheme),
                        _stat('${_profile?.savedCount ?? 0}', 'Saved', textTheme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display name', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(hintText: 'Your name'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: _saveName, child: const Text('Save')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Daily reminders'),
                    subtitle: const Text('11:00 and 19:00 nudges if you haven\'t read today\'s fact'),
                    value: _remindersOn,
                    onChanged: (v) async {
                      await NotificationService.setEnabled(v);
                      setState(() => _remindersOn = v);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const StreakCalendar(),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _signOut,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.destructive),
                  child: const Text('Sign out'),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _stat(String value, String label, TextTheme textTheme) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
