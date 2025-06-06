import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/data/models/create_book_model.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step1_basic_info.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step2_genres_tags.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step3_summary.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step4_upload.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../common/widgets/notification_card.dart';

@RoutePage()
class EditBookScreen extends ConsumerStatefulWidget {
  final EbookModel ebookToEdit;
  
  const EditBookScreen({Key? key, required this.ebookToEdit}) : super(key: key);

  @override
  ConsumerState<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends ConsumerState<EditBookScreen> {
  final PageController _pageController = PageController();
  bool _successNavigationScheduled = false;

  @override
  void initState() {
    super.initState();
    // Initialize state with existing book data
    Future.microtask(() {
      ref.read(createBookProvider.notifier).initializeForEditing(
        CreateBookModel(
          title: widget.ebookToEdit.title,
          targetAudience: _determineAudience(widget.ebookToEdit),
          genres: widget.ebookToEdit.tags,
          styleLabels: _extractLabels([], 'style'),
          characterLabels: _extractLabels([], 'character'),
          settingLabels: _extractLabels([], 'setting'),
          summary: widget.ebookToEdit.summary ?? '',
          isCompleted: widget.ebookToEdit.completed,
          isFree: widget.ebookToEdit.free,
          ebookId: widget.ebookToEdit.id, // Important: set the ebookId for updating
        ),
      );
    });
  }

  @override
  void didUpdateWidget(EditBookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final state = ref.read(createBookProvider);
    _handleStateChanges(state);
  }

  void _handleStateChanges(CreateBookState state) {
    // Prevent multiple notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First handle success case
      if (!_successNavigationScheduled && state.isSuccess) {
        _successNavigationScheduled = true;
        
        // Show success notification
        ref.read(notificationServiceProvider).showNotification(
          message: 'Book updated successfully!',
          type: NotificationType.success,
          duration: const Duration(seconds: 4),
        );
        
        // Navigate back to book detail after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            // Pop back to the book detail screen
            context.router.pop();
            
            // Reset the success flag so we can track new successes
            ref.read(createBookProvider.notifier).clearSuccess();
          }
        });
        
        // Immediately clear the success state after showing notification
        // to prevent further notifications
        Future.microtask(() {
          ref.read(createBookProvider.notifier).clearSuccess();
        });
      }
      
      // Handle error case separately
      else if (state.hasError && state.errorMessage != null) {
        ref.read(notificationServiceProvider).showNotification(
          message: state.errorMessage!,
          type: NotificationType.error,
          duration: const Duration(seconds: 5),
        );
        
        // Clear the error state after showing notification
        Future.microtask(() {
          ref.read(createBookProvider.notifier).clearError();
        });
      }
    });
  }

  String _determineAudience(EbookModel ebook) {
    // This is a placeholder - you would need to determine this from your data
    // Maybe you store this in labels or tags?
    if (ebook.tags.contains('Male')) return 'male';
    if (ebook.tags.contains('Female')) return 'female';
    return 'female'; // Default
  }

  List<String> _extractLabels(List<String> allLabels, String category) {
    // This is a placeholder - you would need your own logic to extract different label types
    // For now, just return all labels
    return allLabels;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createBookProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Handle state changes
    _handleStateChanges(state);
    
    // Mapping step numbers to titles
    final stepTitles = [
      'Edit Basics',
      'Edit Categories',
      'Edit Summary',
      'Replace Content'
    ];
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0,
        title: Text(
          "Edit: ${widget.ebookToEdit.title}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(4, (index) {
                bool isActive = state.currentStep >= index;
                bool isCurrent = state.currentStep == index;
                
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive 
                        ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: isCurrent
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                Container(
                                  width: constraints.maxWidth * 0.5,
                                  color: isActive 
                                    ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                                    : Colors.transparent,
                                ),
                                Container(
                                  width: constraints.maxWidth * 0.5,
                                  color: isDark 
                                    ? Colors.grey.shade800 
                                    : Colors.grey.shade300,
                                ),
                              ],
                            );
                          }
                        )
                      : Container(),
                  ),
                );
              }),
            ),
          ),
          
          // Current step indicator text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              stepTitles[state.currentStep],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                ref.read(createBookProvider.notifier).setCurrentStep(page);
              },
              children: const [
                Step1BasicInfo(),
                Step2GenresTags(),
                Step3Summary(),
                Step4Upload(),
              ],
            ),
          ),
          
          // Bottom Navigation
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: !state.isLoading ? () {
                        ref.read(createBookProvider.notifier).previousStep();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } : null,
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                        ),
                      ),
                    ),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: state.currentStep == 3
                    ? _buildUpdateButton(state, isDark)
                    : _buildNextButton(state, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextButton(CreateBookState state, bool isDark) {
    // For editing, we want to always allow continuing to the next step
    // because the data is already populated from the existing book
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: !state.isLoading ? () {
        ref.read(createBookProvider.notifier).nextStep();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } : null,
      child: Text(
        'Continue',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildUpdateButton(CreateBookState state, bool isDark) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        foregroundColor: isDark ? Colors.black : Colors.white,
        disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        disabledForegroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: !state.isLoading
        ? () => ref.read(createBookProvider.notifier).updateBook()
        : null,
      child: state.isLoading 
        ? _buildProgressIndicator(state, isDark)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.refresh),
              const SizedBox(width: 8),
              const Text(
                'Update Book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
    );
  }
  
  Widget _buildProgressIndicator(CreateBookState state, bool isDark) {
  // If upload is complete (100%), show processing state
  if (state.uploadProgress >= 0.99) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Processing...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  } 
  // If upload is in progress (1-99%)
  else if (state.uploadProgress > 0) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? Colors.black : Colors.white,
            value: state.uploadProgress,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Uploading ${(state.uploadProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }
  
  // Default indeterminate progress indicator (0%)
  return SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: isDark ? Colors.black : Colors.white,
    ),
  );
}
}