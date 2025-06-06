import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';

class Step2GenresTags extends ConsumerStatefulWidget {
  const Step2GenresTags({Key? key}) : super(key: key);

  @override
  ConsumerState<Step2GenresTags> createState() => _Step2GenresTagsState();
}

class _Step2GenresTagsState extends ConsumerState<Step2GenresTags> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createBookProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            indicatorWeight: 3,
            labelColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(text: 'Genres'),
              Tab(text: 'Style'),
              Tab(text: 'Character'),
              Tab(text: 'Setting'),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Genres Tab
              _buildGenresTab(state, isDark),
              
              // Style Tags Tab
              _buildLabelsTab(
                ref,
                styleLabels,
                state.book.styleLabels,
                isDark,
                (label) => ref.read(createBookProvider.notifier).toggleStyleLabel(label),
              ),
              
              // Character Tags Tab
              _buildLabelsTab(
                ref,
                characterLabels,
                state.book.characterLabels,
                isDark,
                (label) => ref.read(createBookProvider.notifier).toggleCharacterLabel(label),
              ),
              
              // Setting Tags Tab
              _buildLabelsTab(
                ref, 
                settingLabels,
                state.book.settingLabels,
                isDark,
                (label) => ref.read(createBookProvider.notifier).toggleSettingLabel(label),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGenresTab(CreateBookState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select genre(s) for your book',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please select at least one genre',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: genreOptions.map((genre) {
              final isSelected = state.book.genres.contains(genre);
              return _buildSelectionChip(
                label: genre,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  ref.read(createBookProvider.notifier).toggleGenre(genre);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLabelsTab(
    WidgetRef ref,
    List<String> labels,
    List<String> selectedLabels,
    bool isDark,
    Function(String) toggleFunction,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select relevant tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'These help readers find your book',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: labels.map((label) {
              final isSelected = selectedLabels.contains(label);
              return _buildSelectionChip(
                label: label,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => toggleFunction(label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.1))
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}