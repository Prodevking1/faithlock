import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

/// Loads Bible verses from the asset database (bible_bsb.db)
/// into the app's internal database
class BibleDatabaseLoader {
  static const String _assetDbPath = 'assets/databases/bible_bsb.db';
  static const String _bibleDbName = 'bible_bsb.db';

  /// Load the 100 categorized curriculum verses from asset database
  static Future<List<BibleVerse>> loadCurriculumVerses() async {
    // Copy asset database to temporary location
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _bibleDbName);

    // Always check if database structure is up-to-date
    bool needsUpdate = false;

    if (!await File(path).exists()) {
      needsUpdate = true;
    } else {
      // Verify database has curriculum_week column
      try {
        final testDb = await openDatabase(path, readOnly: true);
        final result = await testDb.rawQuery("PRAGMA table_info(BSB_verses)");
        final hasColumn = result.any((col) => col['name'] == 'curriculum_week');
        await testDb.close();

        if (!hasColumn) {
          needsUpdate = true;
          print('⚠️ Bible database missing curriculum_week column - updating...');
        }
      } catch (e) {
        needsUpdate = true;
        print('⚠️ Error checking Bible database structure: $e');
      }
    }

    // Copy/update database if needed
    if (needsUpdate) {
      print('📚 Updating Bible database from assets...');
      final ByteData data = await rootBundle.load(_assetDbPath);
      final List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
      print('✅ Bible database updated successfully');
    }

    // Open the Bible database
    final db = await openDatabase(path, readOnly: true);

    try {
      // Query only categorized verses (the 100 curriculum verses)
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT
          b.name as book_name,
          v.chapter,
          v.verse,
          v.text,
          v.category,
          v.curriculum_week,
          v.difficulty,
          v.keyword
        FROM BSB_verses v
        JOIN BSB_books b ON v.book_id = b.id
        WHERE v.category IS NOT NULL
        ORDER BY v.category, v.curriculum_week, v.chapter, v.verse
      ''');

      // Convert to BibleVerse objects
      final List<BibleVerse> verses = [];
      for (var i = 0; i < results.length; i++) {
        final row = results[i];
        final reference = '${row['book_name']} ${row['chapter']}:${row['verse']}';

        verses.add(BibleVerse(
          id: 'verse_${i + 1}', // Generate unique ID
          text: row['text'] as String,
          reference: reference,
          book: row['book_name'] as String,
          chapter: row['chapter'] as int,
          verse: row['verse'] as int,
          category: VerseCategoryExtension.fromString(row['category'] as String),
          translation: 'BSB', // Berean Standard Bible
          curriculumWeek: row['curriculum_week'] as int?,
          difficulty: row['difficulty'] as int?,
          keyword: row['keyword'] as String?,
        ));
      }

      return verses;
    } finally {
      await db.close();
    }
  }

  /// Get a specific verse from the Bible database
  static Future<BibleVerse?> getVerse({
    required String bookName,
    required int chapter,
    required int verse,
  }) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _bibleDbName);

    if (!await File(path).exists()) {
      // Copy database if it doesn't exist
      final ByteData data = await rootBundle.load(_assetDbPath);
      final List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path, readOnly: true);

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT
          b.name as book_name,
          v.chapter,
          v.verse,
          v.text,
          v.category,
          v.curriculum_week,
          v.difficulty,
          v.keyword
        FROM BSB_verses v
        JOIN BSB_books b ON v.book_id = b.id
        WHERE b.name = ? AND v.chapter = ? AND v.verse = ?
        LIMIT 1
      ''', [bookName, chapter, verse]);

      if (results.isEmpty) return null;

      final row = results.first;
      final reference = '$bookName $chapter:$verse';

      return BibleVerse(
        id: 'verse_${row['book_name']}_${row['chapter']}_${row['verse']}',
        text: row['text'] as String,
        reference: reference,
        book: row['book_name'] as String,
        chapter: row['chapter'] as int,
        verse: row['verse'] as int,
        category: row['category'] != null
            ? VerseCategoryExtension.fromString(row['category'] as String)
            : VerseCategory.temptation, // Default fallback
        translation: 'BSB',
        curriculumWeek: row['curriculum_week'] as int?,
        difficulty: row['difficulty'] as int?,
        keyword: row['keyword'] as String?,
      );
    } finally {
      await db.close();
    }
  }
}
