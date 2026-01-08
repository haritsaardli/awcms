/// AWCMS Mobile - Permission Widgets
///
/// Widget untuk permission-based UI rendering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/permission_service.dart';

/// Widget yang hanya ditampilkan jika user punya permission
class PermissionGuard extends ConsumerWidget {
  final String module;
  final PermissionAction action;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.module,
    required this.action,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionProvider);
    final permissionService = ref.read(permissionProvider.notifier);

    if (permissionState.isLoading) {
      return fallback ?? const SizedBox.shrink();
    }

    // Use mobile-aware permission check
    if (permissionService.canAccessMobile(module, action)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget untuk role-based rendering
class RoleGuard extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);

    if (allowedRoles.contains(role)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget hanya untuk admin
class AdminOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    if (isAdmin) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Button dengan mobile restriction warning
class MobileRestrictedButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final PermissionAction action;
  final VoidCallback? onPressed;

  const MobileRestrictedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.action,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.read(permissionProvider.notifier);
    final isRestricted = permissionService.isMobileRestricted(action);

    return FilledButton.icon(
      onPressed: isRestricted
          ? () => _showRestrictionDialog(context)
          : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: isRestricted
          ? FilledButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }

  void _showRestrictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.computer, size: 48),
        title: const Text('Akses Terbatas'),
        content: const Text(
          'Fitur ini hanya tersedia di web dashboard untuk keamanan dan governance. '
          'Silakan gunakan web admin untuk melakukan aksi ini.',
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
}

/// Badge untuk menunjukkan role
class RoleBadge extends ConsumerWidget {
  const RoleBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role, colorScheme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getRoleLabel(role),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role, ColorScheme colorScheme) {
    switch (role) {
      case UserRole.owner:
      case UserRole.superAdmin:
        return colorScheme.error;
      case UserRole.admin:
        return colorScheme.primary;
      case UserRole.editor:
        return colorScheme.tertiary;
      case UserRole.author:
        return colorScheme.secondary;
      default:
        return colorScheme.outline;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'OWNER';
      case UserRole.superAdmin:
        return 'SUPER ADMIN';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.editor:
        return 'EDITOR';
      case UserRole.author:
        return 'AUTHOR';
      case UserRole.member:
        return 'MEMBER';
      case UserRole.subscriber:
        return 'SUBSCRIBER';
      default:
        return 'PUBLIC';
    }
  }
}
