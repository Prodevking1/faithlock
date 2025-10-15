import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FaithLockDatabaseService {
  static final FaithLockDatabaseService _instance = FaithLockDatabaseService._internal();
  factory FaithLockDatabaseService() => _instance;
  FaithLockDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'faithlock.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Verses table
    await db.execute('''
      CREATE TABLE verses (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        reference TEXT NOT NULL,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        category TEXT NOT NULL,
        translation TEXT DEFAULT 'KJV'
      )
    ''');

    // Lock schedules table
    await db.execute('''
      CREATE TABLE lock_schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        days TEXT NOT NULL,
        is_enabled INTEGER DEFAULT 1,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // User stats table
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        verses_read INTEGER DEFAULT 0,
        successful_unlocks INTEGER DEFAULT 0,
        failed_attempts INTEGER DEFAULT 0,
        screen_time_minutes INTEGER DEFAULT 0
      )
    ''');

    // Unlock history table
    await db.execute('''
      CREATE TABLE unlock_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        was_successful INTEGER NOT NULL,
        attempt_count INTEGER DEFAULT 1,
        time_to_unlock INTEGER,
        FOREIGN KEY (verse_id) REFERENCES verses(id)
      )
    ''');

    // Favorite verses table
    await db.execute('''
      CREATE TABLE favorite_verses (
        user_id TEXT DEFAULT 'default',
        verse_id TEXT,
        created_at TEXT NOT NULL,
        PRIMARY KEY (user_id, verse_id),
        FOREIGN KEY (verse_id) REFERENCES verses(id)
      )
    ''');

    // Seed initial verses
    await _seedInitialVerses(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // ==================== VERSE OPERATIONS ====================

  Future<int> insertVerse(BibleVerse verse) async {
    final db = await database;
    return await db.insert('verses', verse.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BibleVerse>> getAllVerses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('verses');
    return List.generate(maps.length, (i) => BibleVerse.fromJson(maps[i]));
  }

  Future<BibleVerse?> getVerseById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BibleVerse.fromJson(maps.first);
  }

  Future<List<BibleVerse>> getVersesByCategory(VerseCategory category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'category = ?',
      whereArgs: [category.value],
    );
    return List.generate(maps.length, (i) => BibleVerse.fromJson(maps[i]));
  }

  Future<List<BibleVerse>> searchVerses(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'text LIKE ? OR reference LIKE ? OR book LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => BibleVerse.fromJson(maps[i]));
  }

  Future<BibleVerse?> getRandomVerse({VerseCategory? category}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = category != null
        ? await db.query('verses', where: 'category = ?', whereArgs: [category.value])
        : await db.query('verses');

    if (maps.isEmpty) return null;

    maps.shuffle();
    return BibleVerse.fromJson(maps.first);
  }

  // ==================== SCHEDULE OPERATIONS ====================

  Future<int> insertSchedule(LockSchedule schedule) async {
    final db = await database;
    return await db.insert('lock_schedules', schedule.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateSchedule(LockSchedule schedule) async {
    final db = await database;
    return await db.update(
      'lock_schedules',
      schedule.toJson(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(String id) async {
    final db = await database;
    return await db.delete('lock_schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LockSchedule>> getAllSchedules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('lock_schedules');
    return List.generate(maps.length, (i) => LockSchedule.fromJson(maps[i]));
  }

  Future<List<LockSchedule>> getActiveSchedules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lock_schedules',
      where: 'is_enabled = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => LockSchedule.fromJson(maps[i]));
  }

  // ==================== STATS OPERATIONS ====================

  Future<int> insertDailyStats(DailyStats stats) async {
    final db = await database;
    return await db.insert('user_stats', stats.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DailyStats> getDailyStats(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'user_stats',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isEmpty) {
      return DailyStats.empty(date);
    }
    return DailyStats.fromJson(maps.first);
  }

  Future<List<DailyStats>> getStatsRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'user_stats',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) => DailyStats.fromJson(maps[i]));
  }

  // ==================== UNLOCK HISTORY OPERATIONS ====================

  Future<int> insertUnlockAttempt(UnlockAttempt attempt) async {
    final db = await database;
    return await db.insert('unlock_history', attempt.toJson());
  }

  Future<List<UnlockAttempt>> getUnlockHistory({int limit = 100}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unlock_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => UnlockAttempt.fromJson(maps[i]));
  }

  Future<List<UnlockAttempt>> getTodayUnlocks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final List<Map<String, dynamic>> maps = await db.query(
      'unlock_history',
      where: 'timestamp >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => UnlockAttempt.fromJson(maps[i]));
  }

  // ==================== FAVORITE VERSES ====================

  Future<int> addFavorite(String verseId) async {
    final db = await database;
    return await db.insert(
      'favorite_verses',
      {
        'user_id': 'default',
        'verse_id': verseId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String verseId) async {
    final db = await database;
    return await db.delete(
      'favorite_verses',
      where: 'verse_id = ? AND user_id = ?',
      whereArgs: [verseId, 'default'],
    );
  }

  Future<bool> isFavorite(String verseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_verses',
      where: 'verse_id = ? AND user_id = ?',
      whereArgs: [verseId, 'default'],
    );
    return maps.isNotEmpty;
  }

  Future<List<BibleVerse>> getFavoriteVerses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.* FROM verses v
      INNER JOIN favorite_verses fv ON v.id = fv.verse_id
      WHERE fv.user_id = ?
      ORDER BY fv.created_at DESC
    ''', ['default']);

    return List.generate(maps.length, (i) => BibleVerse.fromJson(maps[i]));
  }

  // ==================== SEED DATA ====================

  Future<void> _seedInitialVerses(Database db) async {
    final verses = _getInitialVerses();
    for (final verse in verses) {
      await db.insert('verses', verse.toJson());
    }
  }

  List<BibleVerse> _getInitialVerses() {
    return [
      // Strength verses
      const BibleVerse(
        id: 'verse_001',
        text: 'I can do all things through Christ who strengthens me.',
        reference: 'Philippians 4:13',
        book: 'Philippians',
        chapter: 4,
        verse: 13,
        category: VerseCategory.strength,
      ),
      const BibleVerse(
        id: 'verse_002',
        text: 'The Lord is my strength and my shield; my heart trusts in him, and he helps me.',
        reference: 'Psalm 28:7',
        book: 'Psalm',
        chapter: 28,
        verse: 7,
        category: VerseCategory.strength,
      ),
      const BibleVerse(
        id: 'verse_003',
        text: 'But those who hope in the Lord will renew their strength.',
        reference: 'Isaiah 40:31',
        book: 'Isaiah',
        chapter: 40,
        verse: 31,
        category: VerseCategory.strength,
      ),

      // Peace verses
      const BibleVerse(
        id: 'verse_004',
        text: 'Peace I leave with you; my peace I give you.',
        reference: 'John 14:27',
        book: 'John',
        chapter: 14,
        verse: 27,
        category: VerseCategory.peace,
      ),
      const BibleVerse(
        id: 'verse_005',
        text: 'Do not be anxious about anything, but in every situation, by prayer present your requests to God.',
        reference: 'Philippians 4:6',
        book: 'Philippians',
        chapter: 4,
        verse: 6,
        category: VerseCategory.peace,
      ),
      const BibleVerse(
        id: 'verse_006',
        text: 'The Lord gives strength to his people; the Lord blesses his people with peace.',
        reference: 'Psalm 29:11',
        book: 'Psalm',
        chapter: 29,
        verse: 11,
        category: VerseCategory.peace,
      ),

      // Wisdom verses
      const BibleVerse(
        id: 'verse_007',
        text: 'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault.',
        reference: 'James 1:5',
        book: 'James',
        chapter: 1,
        verse: 5,
        category: VerseCategory.wisdom,
      ),
      const BibleVerse(
        id: 'verse_008',
        text: 'The fear of the Lord is the beginning of wisdom.',
        reference: 'Proverbs 9:10',
        book: 'Proverbs',
        chapter: 9,
        verse: 10,
        category: VerseCategory.wisdom,
      ),

      // Love verses
      const BibleVerse(
        id: 'verse_009',
        text: 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.',
        reference: '1 Corinthians 13:4',
        book: '1 Corinthians',
        chapter: 13,
        verse: 4,
        category: VerseCategory.love,
      ),
      const BibleVerse(
        id: 'verse_010',
        text: 'Above all, love each other deeply, because love covers over a multitude of sins.',
        reference: '1 Peter 4:8',
        book: '1 Peter',
        chapter: 4,
        verse: 8,
        category: VerseCategory.love,
      ),

      // Faith verses
      const BibleVerse(
        id: 'verse_011',
        text: 'Now faith is confidence in what we hope for and assurance about what we do not see.',
        reference: 'Hebrews 11:1',
        book: 'Hebrews',
        chapter: 11,
        verse: 1,
        category: VerseCategory.faith,
      ),
      const BibleVerse(
        id: 'verse_012',
        text: 'For we live by faith, not by sight.',
        reference: '2 Corinthians 5:7',
        book: '2 Corinthians',
        chapter: 5,
        verse: 7,
        category: VerseCategory.faith,
      ),
    ];
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
