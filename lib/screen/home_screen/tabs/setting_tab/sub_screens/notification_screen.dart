import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Thunderstorm Alert',
        'body':
            'Severe thunderstorms expected in your area today. Please avoid fishing.',
        'time': '10 mins ago',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.redAccent,
        'isRead': true,
      },
      {
        'title': 'High Wind Warning',
        'body': 'Winds exceeding 25 mph near the coastline. Exercise caution.',
        'time': '30 mins ago',
        'icon': Icons.air,
        'color': Colors.orangeAccent,
        'isRead': false,
      },
      {
        'title': 'Weather Update',
        'body': 'Clear skies expected tomorrow. Great day for fishing!',
        'time': '2 hours ago',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.green,
        'isRead': false,
      },
      {
        'title': 'Tide Alert',
        'body': 'High tides expected from 5 PM - 7 PM today.',
        'time': '3 hours ago',
        'icon': Icons.waves,
        'color': Colors.blueAccent,
        'isRead': true,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: CustomText(
          text: "Notification Screen",
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return CustomButtonTextField(
                isHeight: true,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: notif['color'],
                    child: Icon(notif['icon'], color: Colors.white),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: notif['title'],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (notif['isRead'] == true)
                        CircleAvatar(radius: 5, backgroundColor: Colors.blue),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      CustomText(
                        text: notif['body'],
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: notif['time'],
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Optional: mark as read or show detail
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
