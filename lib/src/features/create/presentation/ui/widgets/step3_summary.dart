import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';

class Step3Summary extends ConsumerWidget {
  const Step3Summary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createBookProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Summary
          Text(
            'Book Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Write a compelling summary to attract readers',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            initialValue: state.book.summary,
            onChanged: (value) {
              ref.read(createBookProvider.notifier).setSummary(value);
            },
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter book summary (minimum 100 characters recommended)',
              hintStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Book Status
          Text(
            'Book Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Completed/Ongoing Toggle
          _buildToggleCard(
            context,
            ref,
            'Is your book completed?',
            state.book.isCompleted,
            isDark,
            (value) => ref.read(createBookProvider.notifier).setIsCompleted(value),
          ),
          
          const SizedBox(height: 16),
          
          // Free/Paid Toggle
          _buildToggleCard(
            context,
            ref,
            'Make this book free to read?',
            state.book.isFree,
            isDark,
            (value) => ref.read(createBookProvider.notifier).setIsFree(value),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool value,
    bool isDark,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            activeTrackColor: isDark
                ? AppColors.neonCyan.withOpacity(0.3)
                : AppColors.brandDeepGold.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}