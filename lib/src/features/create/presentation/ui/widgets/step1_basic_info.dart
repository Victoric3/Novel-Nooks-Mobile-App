import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';

class Step1BasicInfo extends ConsumerWidget {
  const Step1BasicInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createBookProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Picker
          Center(
            child: Column(
              children: [
                Text(
                  'Book Cover',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 1200,
                    );
                    
                    if (pickedFile != null) {
                      ref.read(createBookProvider.notifier).setCoverImage(File(pickedFile.path));
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                      image: state.book.coverImage != null
                          ? DecorationImage(
                              image: FileImage(state.book.coverImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: state.book.coverImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MdiIcons.imagePlus,
                                size: 48,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to Select',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black45,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Book Title
          Text(
            'Book Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.book.title,
            onChanged: (value) {
              ref.read(createBookProvider.notifier).setTitle(value);
            },
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Enter book title',
              hintStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Target Audience
          Text(
            'Target Audience',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAudienceCard(
                  context, 
                  ref,
                  'Male', 
                  MdiIcons.genderMale,
                  state.book.targetAudience == 'Male',
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAudienceCard(
                  context, 
                  ref,
                  'Female', 
                  MdiIcons.genderFemale,
                  state.book.targetAudience == 'Female',
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAudienceCard(
                  context, 
                  ref,
                  'Both', 
                  MdiIcons.human,
                  state.book.targetAudience == 'Both',
                  isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAudienceCard(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(createBookProvider.notifier).setTargetAudience(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.1))
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                  : (isDark ? Colors.white60 : Colors.black45),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}