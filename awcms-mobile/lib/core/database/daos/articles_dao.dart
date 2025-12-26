/// AWCMS Mobile - Articles DAO
///
/// Data Access Object for local articles operations.
library;

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/articles_table.dart';

part 'articles_dao.g.dart';

/// DAO for articles CRUD operations
@DriftAccessor(tables: [LocalArticles])
class ArticlesDao extends DatabaseAccessor<AppDatabase>
    with _$ArticlesDaoMixin {
  ArticlesDao(super.db);

  /// Get all published articles for a tenant
  Future<List<LocalArticle>> getPublishedArticles({String? tenantId}) {
    final query = select(localArticles)
      ..where((t) => t.status.equals('published'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (tenantId != null) {
      query.where((t) => t.tenantId.equals(tenantId));
    }

    return query.get();
  }

  /// Get article by ID
  Future<LocalArticle?> getArticleById(String id) {
    return (select(
      localArticles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch all published articles (reactive)
  Stream<List<LocalArticle>> watchPublishedArticles({String? tenantId}) {
    final query = select(localArticles)
      ..where((t) => t.status.equals('published'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (tenantId != null) {
      query.where((t) => t.tenantId.equals(tenantId));
    }

    return query.watch();
  }

  /// Watch single article
  Stream<LocalArticle?> watchArticleById(String id) {
    return (select(
      localArticles,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Insert or update article from Supabase
  Future<void> upsertArticle(LocalArticlesCompanion article) {
    return into(localArticles).insertOnConflictUpdate(article);
  }

  /// Batch upsert articles
  Future<void> upsertArticles(List<LocalArticlesCompanion> articles) {
    return batch((batch) {
      for (final article in articles) {
        batch.insert(
          localArticles,
          article,
          onConflict: DoUpdate((_) => article),
        );
      }
    });
  }

  /// Delete article
  Future<int> deleteArticle(String id) {
    return (delete(localArticles)..where((t) => t.id.equals(id))).go();
  }

  /// Get count of cached articles
  Future<int> getArticleCount() async {
    final count = countAll();
    final query = selectOnly(localArticles)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Search articles by title
  Future<List<LocalArticle>> searchArticles(String query, {String? tenantId}) {
    final searchQuery = select(localArticles)
      ..where((t) => t.title.like('%$query%'))
      ..where((t) => t.status.equals('published'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(20);

    if (tenantId != null) {
      searchQuery.where((t) => t.tenantId.equals(tenantId));
    }

    return searchQuery.get();
  }
}
