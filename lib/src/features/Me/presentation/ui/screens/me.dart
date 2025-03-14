import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';

@RoutePage()
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Profile menu items
              _buildMenuItem(context, Icons.book, 'My Books'),
              _buildMenuItem(context, Icons.favorite, 'Favorites'),
              _buildMenuItem(context, Icons.history, 'Reading History'),
              _buildMenuItem(context, Icons.settings, 'Settings'),
              _buildMenuItem(context, Icons.help_outline, 'Help & Support'),
              _buildMenuItem(context, Icons.logout, 'Sign Out'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}