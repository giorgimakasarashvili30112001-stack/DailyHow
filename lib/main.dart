import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  await NotificationService.init();
  runApp(const DailyHowApp());
}
