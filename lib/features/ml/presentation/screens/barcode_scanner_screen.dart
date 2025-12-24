import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/di/injection.dart';
import '../../bloc/ml_bloc.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MLBloc>(),
      child: const BarcodeScannerContent(),
    );
  }
}

class BarcodeScannerContent extends StatelessWidget {
  const BarcodeScannerContent({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      context.read<MLBloc>().add(MLScanBarcode(File(image.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Barcode Scanner'),
      ),
      body: BlocBuilder<MLBloc, MLState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumCard(
                  gradient: AppTheme.warmGradient,
                  hasBorder: false,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.scan_barcode, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barcode & QR Scanner',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scan any barcode or QR code',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                if (state is MLBarcodeScanned) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Image.file(state.image, width: double.infinity, height: 200, fit: BoxFit.cover),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  PremiumCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.scan_barcode, size: 20, color: AppTheme.successColor),
                            const SizedBox(width: 8),
                            Text('${state.barcodes.length} Barcode(s) Found', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (state.barcodes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...state.barcodes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final barcode = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          barcode.format.name.toUpperCase(),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Iconsax.copy, size: 18),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: barcode.rawValue ?? ''));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Copied!'),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    barcode.rawValue ?? 'No data',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (barcode.type.name != 'unknown') ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Type: ${barcode.type.name}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          const SizedBox(height: 16),
                          Text('No barcodes found in this image', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextSecondary)),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                ],

                if (state is MLInitial)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.scan_barcode, size: 48, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        const SizedBox(height: 16),
                        Text('Select an image to scan barcodes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                if (state is MLLoading)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Camera',
                        icon: Iconsax.camera,
                        gradient: AppTheme.warmGradient,
                        onPressed: () => _pickImage(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(context, ImageSource.gallery),
                        icon: const Icon(Iconsax.gallery, size: 20),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppTheme.warningColor,
                          side: const BorderSide(color: AppTheme.warningColor, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }
}