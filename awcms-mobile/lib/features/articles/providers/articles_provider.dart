/// AWCMS Mobile - Articles Provider
///
/// Riverpod providers untuk data artikel dengan offline-first support.
/// Membaca dari local database (Drift), auto-sync dari Supabase.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/tenant_utils.dart';

/// Provider untuk daftar artikel (dari local DB)
final articlesProvider = StreamProvider<List<LocalArticle>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final tenantId = ref.watch(tenantIdProvider);

  // Trigger sync in background
  Future.microtask(() {
    ref.read(syncServiceProvider.notifier).fullSync();
  });

  return db.articlesDao.watchPublishedArticles(tenantId: tenantId);
});

/// Provider untuk detail artikel by ID (dari local DB)
final articleDetailProvider = StreamProvider.family<LocalArticle?, String>((
  ref,
  articleId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.articlesDao.watchArticleById(articleId);
});

/// Provider untuk search artikel (dari local DB)
final articleSearchProvider = FutureProvider.family<List<LocalArticle>, String>(
  (ref, query) async {
    if (query.length < 3) return [];

    final db = ref.watch(appDatabaseProvider);
    final tenantId = ref.watch(tenantIdProvider);

    return db.articlesDao.searchArticles(query, tenantId: tenantId);
  },
);

/// Provider untuk jumlah artikel cached
final articlesCountProvider = FutureProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.articlesDao.getArticleCount();
});
