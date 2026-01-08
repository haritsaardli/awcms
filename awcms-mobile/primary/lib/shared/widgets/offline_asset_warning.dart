/// AWCMS Mobile - Offline Asset Warning Widget
///
/// Widget dan utility untuk menampilkan warning saat offline
/// untuk fitur yang membutuhkan akses file/asset online.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/connectivity_service.dart';

/// Feature types that require online access
enum OnlineFeature {
  imageUpload,
  fileDownload,
  pdfView,
  mediaGallery,
  storageAccess,
}

/// Extension to get feature display names
extension OnlineFeatureExtension on OnlineFeature {
  String get displayName {
    switch (this) {
      case OnlineFeature.imageUpload:
        return 'Upload Gambar';
      case OnlineFeature.fileDownload:
        return 'Download File';
      case OnlineFeature.pdfView:
        return 'Lihat PDF';
      case OnlineFeature.mediaGallery:
        return 'Galeri Media';
      case OnlineFeature.storageAccess:
        return 'Akses Storage';
    }
  }

  IconData get icon {
    switch (this) {
      case OnlineFeature.imageUpload:
        return Icons.cloud_upload;
      case OnlineFeature.fileDownload:
        return Icons.cloud_download;
      case OnlineFeature.pdfView:
        return Icons.picture_as_pdf;
      case OnlineFeature.mediaGallery:
        return Icons.photo_library;
      case OnlineFeature.storageAccess:
        return Icons.storage;
    }
  }
}

/// Widget that wraps content requiring online access
/// Shows warning when offline
class OnlineRequiredWrapper extends ConsumerWidget {
  final Widget child;
  final OnlineFeature feature;
  final bool showWarningBanner;

  const OnlineRequiredWrapper({
    super.key,
    required this.child,
    required this.feature,
    this.showWarningBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return child;
    }

    return Column(
      children: [
        if (showWarningBanner) _OfflineAssetWarningBanner(feature: feature),
        Expanded(
          child: Opacity(opacity: 0.5, child: AbsorbPointer(child: child)),
        ),
      ],
    );
  }
}

/// Warning banner for offline asset features
class _OfflineAssetWarningBanner extends StatelessWidget {
  final OnlineFeature feature;

  const _OfflineAssetWarningBanner({required this.feature});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 20, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${feature.displayName} tidak tersedia saat offline',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            feature.icon,
            size: 20,
            color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

/// Show offline warning dialog
Future<void> showOfflineAssetWarning(
  BuildContext context, {
  required OnlineFeature feature,
  String? customMessage,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.cloud_off, size: 48),
      title: const Text('Mode Offline'),
      content: Text(
        customMessage ??
            '${feature.displayName} tidak tersedia saat offline. '
                'Hubungkan ke internet untuk mengakses fitur ini.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );
}

/// Show offline warning snackbar
void showOfflineAssetSnackbar(
  BuildContext context, {
  required OnlineFeature feature,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text('${feature.displayName} tidak tersedia offline'),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Extension on WidgetRef to easily check online status
extension OfflineAssetChecks on WidgetRef {
  /// Check if online, show warning if not
  bool checkOnlineForFeature(
    BuildContext context,
    OnlineFeature feature, {
    bool showDialog = false,
  }) {
    final isOnline = read(isOnlineProvider);

    if (!isOnline) {
      if (showDialog) {
        showOfflineAssetWarning(context, feature: feature);
      } else {
        showOfflineAssetSnackbar(context, feature: feature);
      }
    }

    return isOnline;
  }
}
