import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/common/widgets/notification_card.dart';
import 'package:novelnooks/src/features/auth/blocs/auth_handler.dart';
import 'package:novelnooks/src/features/auth/blocs/verify_code.dart';
import 'package:novelnooks/src/features/auth/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Notification preferences
  bool _newBooksNotification = true;
  bool _commentsNotification = true;
  bool _updatesNotification = true;
  bool _promotionsNotification = false;
  bool _purchaseNotification = true;

  // Animation controllers
  late AnimationController _animationController;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _coinsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Load notification preferences
    _loadNotificationPreferences();

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _coinsController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _newBooksNotification = prefs.getBool('pref_notif_new_books') ?? true;
      _commentsNotification = prefs.getBool('pref_notif_comments') ?? true;
      _updatesNotification = prefs.getBool('pref_notif_updates') ?? true;
      _promotionsNotification = prefs.getBool('pref_notif_promotions') ?? false;
      _purchaseNotification = prefs.getBool('pref_notif_purchases') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error loading user data: $error')),
        data: (user) {
          return NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                isDark
                                    ? [Colors.black, Colors.blueGrey.shade900]
                                    : [
                                      AppColors.brandDeepGold,
                                      AppColors.brandWarmOrange,
                                    ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    _buildProfileAvatar(isDark, user!.photo),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.username,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            user.email,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildInfoChip(
                                                isDark,
                                                Icons.monetization_on,
                                                '${user.coins} coins',
                                              ),
                                              const SizedBox(width: 8),
                                              _buildInfoChip(
                                                isDark,
                                                user.isPremium
                                                    ? Icons.verified
                                                    : Icons.person,
                                                user.isPremium
                                                    ? 'Premium'
                                                    : 'Free',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorColor:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                      tabs: const [
                        Tab(text: 'Preferences', icon: Icon(Icons.settings)),
                        Tab(text: 'Account', icon: Icon(Icons.person)),
                        Tab(text: 'Credits', icon: Icon(Icons.payments)),
                      ],
                    ),
                  ),
                ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPreferencesTab(isDark),
                _buildAccountTab(isDark, user),
                _buildCreditsTab(isDark, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(bool isDark, String photoUrl) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                    .withOpacity(0.3),
                blurRadius: 10 * _animationController.value,
                spreadRadius: 3 * _animationController.value,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor:
                isDark
                    ? AppColors.neonCyan.withOpacity(0.1)
                    : AppColors.brandDeepGold.withOpacity(0.1),
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child:
                photoUrl.isEmpty
                    ? Icon(
                      Icons.person,
                      size: 40,
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.neonCyan.withOpacity(0.3) : Colors.white30,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.neonCyan : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 72), // Add padding for tabs bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(isDark, 'Appearance'),
            _buildThemeToggle(isDark),

            const SizedBox(height: 24),
            _buildSectionHeader(isDark, 'Notifications'),
            _buildNotificationToggle(
              isDark,
              'New Books',
              'Get notified when new books are added',
              _newBooksNotification,
              (value) {
                setState(() => _newBooksNotification = value);
                _saveNotificationPreference('pref_notif_new_books', value);
              },
              Icons.auto_stories,
            ),
            _buildNotificationToggle(
              isDark,
              'Comments',
              'Get notified about new comments',
              _commentsNotification,
              (value) {
                setState(() => _commentsNotification = value);
                _saveNotificationPreference('pref_notif_comments', value);
              },
              Icons.comment,
            ),
            _buildNotificationToggle(
              isDark,
              'Updates',
              'Get notified about app updates',
              _updatesNotification,
              (value) {
                setState(() => _updatesNotification = value);
                _saveNotificationPreference('pref_notif_updates', value);
              },
              Icons.system_update,
            ),
            _buildNotificationToggle(
              isDark,
              'Promotions',
              'Get notified about special offers',
              _promotionsNotification,
              (value) {
                setState(() => _promotionsNotification = value);
                _saveNotificationPreference('pref_notif_promotions', value);
              },
              Icons.local_offer,
            ),
            _buildNotificationToggle(
              isDark,
              'Purchases',
              'Get notified about your purchases',
              _purchaseNotification,
              (value) {
                setState(() => _purchaseNotification = value);
                _saveNotificationPreference('pref_notif_purchases', value);
              },
              Icons.shopping_cart,
            ),
            // Private Profile toggle removed
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab(bool isDark, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 72), // Padding for tab bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(isDark, 'Account'),
            _buildSettingActionCard(
              isDark,
              MdiIcons.accountEdit,
              'Change Username',
              'Update your display name',
              () => _showChangeUsernameModal(context, isDark, user.username),
            ),
            _buildSettingActionCard(
              isDark,
              MdiIcons.lock,
              'Change Password',
              'Update your password',
              () => _showChangePasswordModal(context, isDark),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(isDark, 'Danger Zone'),
            _buildDangerActionCard(
              isDark,
              'Sign Out',
              'Log out of your account',
              () => _showSignOutConfirmation(context, isDark),
            ),

            // Delete Account option removed
            const SizedBox(height: 24),
            _buildSectionHeader(isDark, 'Support'),
            _buildSupportCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsTab(bool isDark, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      // Add bottom padding to account for tabs bar
      child: Padding(
        padding: const EdgeInsets.only(bottom: 72), // Add padding for tabs bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(isDark, 'Your Balance'),
            _buildBalanceCard(isDark, user.coins, user.isPremium),

            const SizedBox(height: 24),
            _buildSectionHeader(isDark, 'Convert Coins'),
            _buildCoinConverter(isDark, user.coins),

            // Transaction history section removed
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    bool isDark,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          activeTrackColor:
              isDark
                  ? AppColors.neonCyan.withOpacity(0.3)
                  : AppColors.brandDeepGold.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Switch between light and dark theme',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            ref
                .read(currentAppThemeNotifierProvider.notifier)
                .updateCurrentAppTheme(value);
          },
          activeColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          activeTrackColor:
              isDark
                  ? AppColors.neonCyan.withOpacity(0.3)
                  : AppColors.brandDeepGold.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSettingActionCard(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSupportCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.neonCyan
                            : AppColors.brandDeepGold)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    MdiIcons.headset,
                    color:
                        isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Our support team is here for you',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSupportButton(
                  isDark,
                  'FAQ',
                  MdiIcons.frequentlyAskedQuestions,
                  () => _showFaqScreen(context, isDark),
                ),
                const SizedBox(width: 12),
                _buildSupportButton(
                  isDark,
                  'Schedule Call',
                  MdiIcons.phoneInTalkOutline,
                  () => _showScheduleCallModal(context, isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButton(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                  .withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerActionCard(
    bool isDark,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isDestructive
                ? (isDark
                    ? Colors.red.shade900.withOpacity(0.2)
                    : Colors.red.shade50)
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDestructive
                  ? (isDark ? Colors.red.shade800 : Colors.red.shade300)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                        .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDestructive ? Icons.delete_forever : Icons.logout,
            color:
                isDestructive
                    ? Colors.red
                    : (isDark ? AppColors.neonCyan : AppColors.brandDeepGold),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color:
                isDestructive
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark, int coins, bool isPremium) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    MdiIcons.currencyUsd,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Coins',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement buy coins
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          isDark ? Colors.black : AppColors.brandDeepGold,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(MdiIcons.cartPlus),
                    label: const Text('Buy Coins'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement premium upgrade
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    icon: Icon(
                      isPremium ? MdiIcons.crownOutline : MdiIcons.crown,
                    ),
                    label: Text(isPremium ? 'Premium Active' : 'Get Premium'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinConverter(bool isDark, int currentCoins) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.neonCyan
                            : AppColors.brandDeepGold)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    MdiIcons.swapHorizontal,
                    color:
                        isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Convert Coins to Vouchers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Exchange rate: 10 coins = 1 voucher',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _coinsController,
              decoration: InputDecoration(
                labelText: 'Number of coins to convert',
                hintText: 'Enter amount (min. 10)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(MdiIcons.currencyUsd),
                suffixText: 'Coins',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You will receive:',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              MdiIcons.ticket,
                              color:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _coinsController.text.isEmpty
                                  ? '0 Vouchers'
                                  : '${int.parse(_coinsController.text) ~/ 10} Vouchers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    currentCoins >= 10
                        ? () => _showConvertCoinsModal(context, isDark)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Convert Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeUsernameModal(
    BuildContext context,
    bool isDark,
    String currentUsername,
  ) {
    _usernameController.text = currentUsername;

    // Create a scrim color with proper opacity like the comment section
    final scrimColor = Colors.black.withOpacity(0.5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: scrimColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.65,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  color: isDark ? AppColors.darkBg : Colors.white,
                  child: Column(
                    children: [
                      // Header with drag handle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black12 : Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.white10 : Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // Title row
                            Row(
                              children: [
                                Icon(
                                  MdiIcons.accountEdit,
                                  color:
                                      isDark
                                          ? AppColors.neonCyan
                                          : AppColors.brandDeepGold,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Change Username',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Scrollable content with button moved inside
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Username',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your new username',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                autofocus: true,
                              ),

                              const SizedBox(height: 16),
                              Text(
                                'Your username will be visible to other users when you interact with content.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),

                              // Button moved here - directly under the description
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_usernameController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _updateUsername(_usernameController.text);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isDark
                                            ? AppColors.neonCyan
                                            : AppColors.brandDeepGold,
                                    foregroundColor:
                                        isDark ? Colors.black : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Update Username',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Add extra padding at the bottom for better spacing
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordModal(BuildContext context, bool isDark) {
    final scrimColor = Colors.black.withOpacity(0.5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: scrimColor,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: isDark ? AppColors.darkBg : Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title row
                        Row(
                          children: [
                            Icon(
                              MdiIcons.lock,
                              color:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: isDark ? Colors.white70 : Colors.black54,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content with button moved inside
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "To change your password, we'll send a verification code to your email.",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // User's email display
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.black12
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color:
                                      isDark
                                          ? AppColors.neonCyan
                                          : AppColors.brandDeepGold,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isDark
                                                  ? Colors.white60
                                                  : Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ref
                                                .read(userProvider)
                                                .valueOrNull
                                                ?.email ??
                                            '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Button moved here - directly below the email container
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Close the modal
                                Navigator.pop(context);

                                // Get user email
                                final userEmail =
                                    ref.read(userProvider).valueOrNull?.email;
                                if (userEmail != null) {
                                  // Initiate forgot password flow
                                  ref
                                      .read(verifyCodeProvider)
                                      .forgotPassword(userEmail, ref, context);
                                } else {
                                  NotificationService().showNotification(
                                    message:
                                        'Unable to retrieve your email. Please try again.',
                                    type: NotificationType.error,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                                foregroundColor:
                                    isDark ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Add extra padding at the bottom for better spacing
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConvertCoinsModal(BuildContext context, bool isDark) {
    if (_coinsController.text.isEmpty) {
      NotificationService().showNotification(
        message: 'Please enter the amount of coins to convert',
        type: NotificationType.warning,
      );
      return;
    }

    final coinsAmount = int.parse(_coinsController.text);
    if (coinsAmount < 10) {
      NotificationService().showNotification(
        message: 'Minimum conversion is 10 coins',
        type: NotificationType.warning,
      );
      return;
    }

    final vouchersAmount = coinsAmount ~/ 10;
    final scrimColor = Colors.black.withOpacity(0.5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: scrimColor,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: isDark ? AppColors.darkBg : Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title row
                        Row(
                          children: [
                            Icon(
                              MdiIcons.swapHorizontal,
                              color:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Convert Coins',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: isDark ? Colors.white70 : Colors.black54,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.black12
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          MdiIcons.currencyUsd,
                                          color:
                                              isDark
                                                  ? AppColors.neonCyan
                                                  : AppColors.brandDeepGold,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$coinsAmount Coins',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          MdiIcons.ticket,
                                          color:
                                              isDark
                                                  ? AppColors.neonCyan
                                                  : AppColors.brandDeepGold,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$vouchersAmount Vouchers',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Are you sure you want to convert $coinsAmount coins to $vouchersAmount vouchers? This action cannot be undone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom buttons - fixed at bottom
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _convertCoins(coinsAmount);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Convert',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSignOutConfirmation(BuildContext context, bool isDark) {
    final scrimColor = Colors.black.withOpacity(0.5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: scrimColor,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: isDark ? AppColors.darkBg : Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title row
                        Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.powerStandby,
                            size: 64,
                            color:
                                isDark
                                    ? Colors.red.shade300
                                    : Colors.red.shade400,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You will need to sign in again to access your account.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom buttons - fixed at bottom
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _signOut();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark
                                      ? Colors.red.shade600
                                      : Colors.red.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateUsername(String newUsername) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Make the API request
      final response = await DioConfig.dio?.post(
        '/user/changeUserName',
        data: {'newUsername': newUsername},
      );

      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response?.statusCode == 200) {
        // Refresh user data to get updated username
        await ref.read(userProvider.notifier).refreshUser();

        NotificationService().showNotification(
          message: response?.data['message'] ?? 'Username updated successfully',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      // Close loading indicator if it's still showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Error handling based on response
      String errorMessage = 'Failed to update username';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['errorMessage'] ?? errorMessage;
      }

      NotificationService().showNotification(
        message: errorMessage,
        type: NotificationType.error,
      );
    }
  }

  void _convertCoins(int amount) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/premium/coinsToVouchers',
        data: {'coins': amount},
      );

      if (response.statusCode == 200) {
        ref.read(userProvider.notifier).refreshUser();
        NotificationService().showNotification(
          message: response.data['message'] ?? 'Coins converted successfully',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      NotificationService().showNotification(
        message: 'Failed to convert coins',
        type: NotificationType.error,
      );
    }
  }

  void _signOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Use the auth handler to sign out
      await ref.read(signInProvider).signOut(context, ref);

      // Navigate to sign in screen (this is handled in the signOut method)
    } catch (e) {
      // Close loading indicator if it's still showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      NotificationService().showNotification(
        message: 'Failed to sign out',
        type: NotificationType.error,
      );
    }
  }

void _showScheduleCallModal(BuildContext context, bool isDark) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  String selectedService = 'Account Help';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = TimeOfDay.now();

  // Pre-fill with user data if available
  final user = ref.read(userProvider).valueOrNull;
  if (user != null) {
    emailController.text = user.email;
    nameController.text = "${user.firstname} ${user.lastname}";
  }

  // Create a scrim color with proper opacity like the comment section
  final scrimColor = Colors.black.withOpacity(0.5);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: scrimColor,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              color: isDark ? AppColors.darkBg : Colors.white,
              child: Column(
                children: [
                  // Header with drag handle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title row
                        Row(
                          children: [
                            Icon(
                              MdiIcons.phoneInTalkOutline,
                              color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Schedule a Call',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: isDark ? Colors.white70 : Colors.black54,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            'Book a call with our support team to get personalized help with your account or technical issues.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Name field
                          Text(
                            'Your Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Email field
                          Text(
                            'Email Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Your email address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Service Type
                          Text(
                            'Service Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedService,
                                items: [
                                  'Account Help',
                                  'Technical Support',
                                  'Billing Issues',
                                  'Author Support',
                                  'Other',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedService = value!;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Date & Time selection
                          Text(
                            'Preferred Date & Time',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (newDate != null) {
                                setState(() {
                                  selectedDate = newDate;
                                });

                                // Show time picker after date is selected
                                final newTime = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (newTime != null) {
                                  setState(() {
                                    selectedTime = newTime;
                                  });
                                }
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}',
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Message field
                          Text(
                            'Message',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: messageController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your issue briefly',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          // Button moved inside the scrollable area
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _submitScheduleCallRequest(
                                context,
                                nameController.text,
                                emailController.text,
                                messageController.text,
                                selectedDate,
                                selectedTime,
                                "", // Empty budget since removed
                                selectedService,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Schedule Call',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Add extra padding at the bottom for better spacing
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Future<void> _submitScheduleCallRequest(
    BuildContext context,
    String name,
    String email,
    String message,
    DateTime date,
    TimeOfDay time,
    String budget,
    String service,
  ) async {
    // Validate inputs
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      NotificationService().showNotification(
        message: 'Please fill in all required fields',
        type: NotificationType.error,
      );
      return;
    }

    // Format date and time
    final formattedDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/call/scheduleCall',
        data: {
          'name': name,
          'email': email,
          'message': message,
          'date': formattedDate.toIso8601String(),
          'budget': budget.isEmpty ? null : budget,
          'service': service,
        },
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context); // Close loading indicator
        Navigator.pop(context); // Close form modal
      }

      if (response.statusCode == 200) {
        NotificationService().showNotification(
          message:
              'Your call has been scheduled successfully. We will contact you soon.',
          type: NotificationType.success,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      NotificationService().showNotification(
        message: 'Failed to schedule call. Please try again later.',
        type: NotificationType.error,
      );
    }
  }

  void _showFaqScreen(BuildContext context, bool isDark) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Frequently Asked Questions'),
                elevation: 0,
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFaqItem(
                    isDark,
                    'How do I change my username?',
                    'Go to Settings > Account > Change Username to update your username.',
                  ),
                  _buildFaqItem(
                    isDark,
                    'How do coins and vouchers work?',
                    'Coins can be used to purchase chapters or gift to authors. You can convert coins to vouchers at a 10:1 ratio in the Credits tab.',
                  ),
                  _buildFaqItem(
                    isDark,
                    'Can I read offline?',
                    'Yes! Downloaded books are available offline. Just make sure to download them first while you have an internet connection.',
                  ),
                  _buildFaqItem(
                    isDark,
                    'How do I subscribe to Premium?',
                    'Go to the Credits tab and click on "Get Premium" to see available subscription options.',
                  ),
                  _buildFaqItem(
                    isDark,
                    'What payment methods do you accept?',
                    'We accept credit/debit cards, PayPal, and mobile payment options.',
                  ),
                  _buildFaqItem(
                    isDark,
                    'How do I become an author?',
                    'Go to your profile and select "Become an Author" to start publishing your own stories.',
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildFaqItem(bool isDark, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }
}
