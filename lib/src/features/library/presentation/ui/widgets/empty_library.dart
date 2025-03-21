import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EmptyLibrary extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const EmptyLibrary({Key? key, required this.onExplorePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Book illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark 
                    ? AppColors.neonCyan.withOpacity(0.1)
                    : AppColors.brandDeepGold.withOpacity(0.1),
                ),
                child: Icon(
                  MdiIcons.bookshelf,
                  size: 80,
                  color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Your Library is Empty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Discover amazing books and add them to your Reading List or mark them as favorites to see them here.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // How to add books section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'How to build your library:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStep(
                      context, 
                      1, 
                      'Explore books in the home screen',
                      MdiIcons.compass,
                      isDark
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStep(
                      context, 
                      2, 
                      'Tap the bookmark icon to add to Reading List',
                      MdiIcons.bookmarkOutline,
                      isDark
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStep(
                      context, 
                      3, 
                      'Tap the heart icon to mark as favorite',
                      MdiIcons.heartOutline,
                      isDark
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onExplorePressed,
                  icon: Icon(
                    MdiIcons.compass,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                  label: const Text('Explore Books'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int number, String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
      ],
    );
  }
}