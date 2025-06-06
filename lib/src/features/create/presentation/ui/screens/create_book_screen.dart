import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step1_basic_info.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step2_genres_tags.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step3_summary.dart';
import 'package:novelnooks/src/features/create/presentation/ui/widgets/step4_upload.dart';

@RoutePage()
class CreateBookScreen extends ConsumerStatefulWidget {
  const CreateBookScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends ConsumerState<CreateBookScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Reset state when screen is first opened
    Future.microtask(() {
      ref.read(createBookProvider.notifier).resetState();
    });
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
    
    // Mapping step numbers to titles
    final stepTitles = [
      'Book Basics',
      'Categories & Tags',
      'Summary & Status',
      'Upload Content'
    ];
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0,
        title: Text(
          stepTitles[state.currentStep],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: state.currentStep > 0
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                ref.read(createBookProvider.notifier).previousStep();
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
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
          
          const SizedBox(height: 16),
          
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
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
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
                      onPressed: () {
                        ref.read(createBookProvider.notifier).previousStep();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
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
                    ? _buildSubmitButton(state, isDark)
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
    bool isEnabled = false;
    
    // Determine if next button should be enabled based on current step
    switch (state.currentStep) {
      case 0:
        isEnabled = state.book.isStep1Valid();
        break;
      case 1:
        isEnabled = state.book.isStep2Valid();
        break;
      case 2:
        isEnabled = state.book.isStep3Valid();
        break;
    }
    
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
      onPressed: isEnabled
        ? () {
            ref.read(createBookProvider.notifier).nextStep();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        : null,
      child: Text(
        'Continue',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildSubmitButton(CreateBookState state, bool isDark) {
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
        ? () => ref.read(createBookProvider.notifier).submitBook()
        : null,
      child: state.isLoading
        ? _buildProgressIndicator(state, isDark)
        : const Text(
            'Upload Book',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
    
    // Default indeterminate progress indicator
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