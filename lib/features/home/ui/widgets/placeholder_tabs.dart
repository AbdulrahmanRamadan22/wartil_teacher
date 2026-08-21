import 'package:flutter/material.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('شاشة السجل'));
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('شاشة الجدول'));
}

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('شاشة التقييمات'));
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('شاشة التنبيهات'));
}
