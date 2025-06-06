import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/router/app_router.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/create/presentation/providers/create_book_provider.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';
import 'package:novelnooks/src/common/widgets/notification_card.dart';

class Step4Upload extends ConsumerWidget {
  const Step4Upload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createBookProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final hasPdf = state.book.pdfFile != null || state.book.pdfBytes != null;
    
    // Handle notifications and navigation based on state changes
    _handleStateChanges(context, ref, state);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Book Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Upload a PDF file containing your book content',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PDF Upload Card
          GestureDetector(
            onTap: state.isLoading ? null : () => _pickPdfFile(ref),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasPdf
                      ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  width: hasPdf ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    hasPdf ? MdiIcons.fileDocument : MdiIcons.fileUpload,
                    size: 64,
                    color: hasPdf
                        ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                        : (isDark ? Colors.white60 : Colors.black45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasPdf ? 'PDF Selected' : 'Tap to Upload PDF',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasPdf
                          ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasPdf && state.book.pdfFile != null)
                    Text(
                      _getFileName(state.book.pdfFile!.path),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  if (!hasPdf)
                    Text(
                      'Supported format: PDF',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (hasPdf && !state.isLoading) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ref.read(createBookProvider.notifier).clearPdf();
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                ),
                label: Text(
                  'Remove PDF',
                  style: TextStyle(
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ],
          
          // Upload progress indicator
          if (state.isLoading) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.6) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uploading Book...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Use a Consumer to ensure the progress bar updates more frequently
                  Consumer(
                    builder: (context, ref, _) {
                      final progress = ref.watch(
                        createBookProvider.select((state) => state.uploadProgress)
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% Uploaded',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Note about PDF processing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PDF Processing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your PDF will be processed to extract chapters and content. Make sure your PDF has proper chapter divisions for best results.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Extra space at the bottom for better scrolling
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _handleStateChanges(BuildContext context, WidgetRef ref, CreateBookState state) {
    // Use a microtask to avoid build-phase notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = ref.read(notificationServiceProvider);
      
      // Show error notification
      if (state.hasError && state.errorMessage != null) {
        notificationService.showNotification(
          message: state.errorMessage!,
          type: NotificationType.error,
          duration: const Duration(seconds: 5),
        );
        
        // Clear the error state after showing notification
        ref.read(createBookProvider.notifier).clearError();
      }
      
      // Show success notification and navigate after 5 seconds
      if (state.isSuccess) {
        notificationService.showNotification(
          message: 'Your book has been uploaded successfully!',
          type: NotificationType.success,
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to home after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          // Navigate to the HomeRoute
          if (context.mounted) {
            // Navigate to home tab
            context.router.navigate(const TabsRoute(children: [HomeRoute()]));
          }
          
          // Clear the success state after navigation
          ref.read(createBookProvider.notifier).clearSuccess();
        });
      }
    });
  }

  void _pickPdfFile(WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null) {
        final path = result.files.single.path;
        final bytes = result.files.single.bytes;
        
        if (path != null) {
          // For mobile/desktop file system access
          final file = File(path);
          ref.read(createBookProvider.notifier).setPdfFile(file);
        } else if (bytes != null) {
          // For web
          ref.read(createBookProvider.notifier).setPdfBytes(bytes);
        }
      }
    } catch (e) {
      // Show error using notification service
      ref.read(notificationServiceProvider).showNotification(
        message: 'Error selecting PDF: ${e.toString()}',
        type: NotificationType.error,
      );
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }
}