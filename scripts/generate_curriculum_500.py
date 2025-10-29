#!/usr/bin/env python3
"""
Generate 500-verse curriculum by finding relevant verses in bible_bsb.db
Uses keyword matching to categorize verses intelligently
"""

import sqlite3
import sys
from pathlib import Path

# Category definitions with expanded keywords
CATEGORIES = {
    'temptation': {
        'keywords': [
            '%tempt%', '%trial%', '%test%', '%resist%', '%overcome%', '%endure%',
            '%strength%', '%deliver%', '%flee%', '%stand%', '%armor%',
            '%fight%', '%struggle%', '%victory%', '%conquer%', '%sin%',
            '%Spirit%', '%flesh%', '%self-control%', '%discipline%',
            '%guard%', '%watch%', '%alert%', '%sober%', '%vigilant%',
            '%righteous%', '%holy%', '%obey%', '%command%', '%law%',
            '%faithful%', '%steadfast%', '%persever%', '%endure%'
        ],
        'target': 100
    },
    'fear_anxiety': {
        'keywords': [
            '%fear%', '%afraid%', '%anxiety%', '%anxious%', '%worry%',
            '%peace%', '%trust%', '%faith%', '%courage%', '%comfort%',
            '%refuge%', '%strength%', '%deliver%', '%protect%', '%safety%',
            '%calm%', '%rest%', '%hope%', '%confident%', '%assurance%',
            '%shield%', '%fortress%', '%rock%', '%shelter%', '%help%',
            '%strong%', '%mighty%', '%power%', '%upholds%', '%sustain%'
        ],
        'target': 100
    },
    'pride': {
        'keywords': [
            '%pride%', '%proud%', '%humble%', '%humility%', '%arrogant%',
            '%boast%', '%exalt%', '%lowly%', '%meek%', '%modest%',
            '%conceit%', '%haughty%', '%vain%', '%glory%',
            '%servant%', '%serve%', '%submit%', '%obedient%', '%obey%',
            '%wise%', '%wisdom%', '%foolish%', '%fool%', '%understanding%',
            '%teach%', '%learn%', '%know%', '%knowledge%'
        ],
        'target': 100
    },
    'lust': {
        'keywords': [
            '%lust%', '%adulter%', '%fornic%', '%sexual%', '%pure%',
            '%purity%', '%chaste%', '%marriage%', '%body%', '%temple%',
            '%desire%', '%covet%', '%eyes%', '%heart%', '%sanctif%',
            '%holiness%', '%holy%', '%righteous%', '%clean%', '%unclean%',
            '%immoral%', '%sin%', '%flesh%', '%passion%', '%control%',
            '%honor%', '%dishonor%', '%corrupt%'
        ],
        'target': 100
    },
    'anger': {
        'keywords': [
            '%anger%', '%wrath%', '%rage%', '%furious%', '%patient%',
            '%patience%', '%gentle%', '%kindness%', '%peace%', '%calm%',
            '%forgive%', '%mercy%', '%compassion%', '%grace%',
            '%temper%', '%bitter%', '%resentment%', '%grudge%',
            '%love%', '%hate%', '%enemy%', '%neighbor%', '%brother%',
            '%quarrel%', '%strife%', '%contention%', '%dispute%'
        ],
        'target': 100
    }
}

def connect_db(db_path):
    """Connect to the Bible database"""
    return sqlite3.connect(db_path)

def find_verses_for_category(conn, category, keywords, limit):
    """Find verses matching category keywords"""
    cursor = conn.cursor()

    # Build query with all keywords
    conditions = ' OR '.join(['v.text LIKE ?' for _ in keywords])

    query = f'''
        SELECT DISTINCT
            b.name as book_name,
            v.chapter,
            v.verse,
            v.text,
            v.id
        FROM BSB_verses v
        JOIN BSB_books b ON v.book_id = b.id
        WHERE v.category IS NULL
        AND ({conditions})
        AND LENGTH(v.text) > 30
        AND LENGTH(v.text) < 600
        ORDER BY RANDOM()
        LIMIT ?
    '''

    cursor.execute(query, keywords + [limit])
    return cursor.fetchall()

def assign_week_and_difficulty(verse_index, total_verses):
    """Calculate curriculum week and difficulty based on position"""
    verses_per_week = 5
    week = (verse_index // verses_per_week) + 1

    # Difficulty progression: weeks 1-4 = 1, 5-12 = 2, 13-20 = 3
    if week <= 4:
        difficulty = 1
    elif week <= 12:
        difficulty = 2
    else:
        difficulty = 3

    return week, difficulty

def extract_keyword(text):
    """Extract a meaningful keyword from verse text"""
    # Common meaningful words (excluding very common words)
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'as', 'is', 'was', 'be', 'been', 'have',
        'has', 'had', 'do', 'does', 'did', 'will', 'shall', 'would', 'should',
        'may', 'might', 'can', 'could', 'must'
    }

    words = text.lower().replace(',', '').replace('.', '').split()
    for word in words:
        if len(word) > 4 and word not in stop_words:
            return word[:15]  # First meaningful word, max 15 chars

    return 'faith'  # fallback

def generate_sql_output(category, verses):
    """Generate SQL UPDATE statements for verses"""
    sql_lines = []

    sql_lines.append(f"\n-- ============================================")
    sql_lines.append(f"-- CATEGORY: {category.upper()} ({len(verses)} verses)")
    sql_lines.append(f"-- ============================================\n")

    for idx, (book, chapter, verse, text, verse_id) in enumerate(verses, start=1):
        week, difficulty = assign_week_and_difficulty(idx - 1, len(verses))
        keyword = extract_keyword(text)

        # Add week comment every 5 verses
        if (idx - 1) % 5 == 0:
            sql_lines.append(f"\n-- === WEEK {week} ===\n")

        sql_lines.append(f"-- {idx}. {book} {chapter}:{verse}")
        sql_lines.append(f"UPDATE BSB_verses SET")
        sql_lines.append(f"  category = '{category}',")
        sql_lines.append(f"  curriculum_week = {week},")
        sql_lines.append(f"  difficulty = {difficulty},")
        sql_lines.append(f"  keyword = '{keyword}'")
        sql_lines.append(f"WHERE book_id = (SELECT id FROM BSB_books WHERE name = '{book}')")
        sql_lines.append(f"  AND chapter = {chapter} AND verse = {verse};")
        sql_lines.append("")

    return '\n'.join(sql_lines)

def main():
    # Database path
    script_dir = Path(__file__).parent
    db_path = script_dir.parent / 'assets' / 'databases' / 'bible_bsb.db'

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        sys.exit(1)

    print(f"📖 Connecting to database: {db_path}")
    conn = connect_db(db_path)

    # Output SQL file
    output_path = script_dir.parent / 'assets' / 'databases' / 'seed_curriculum_complete_500.sql'

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("-- ============================================\n")
        f.write("-- FaithLock Complete Curriculum - 500 Power Verses\n")
        f.write("-- Auto-generated from Bible database\n")
        f.write("-- Run seed_curriculum.sql FIRST (100 base verses)\n")
        f.write("-- Then run this file (400 additional verses)\n")
        f.write("-- ============================================\n\n")

        total_generated = 0

        for category, config in CATEGORIES.items():
            print(f"\n🔍 Finding verses for: {category}")

            # Find verses (target - 20 already in base curriculum)
            additional_needed = config['target'] - 20
            verses = find_verses_for_category(
                conn,
                category,
                config['keywords'],
                additional_needed
            )

            print(f"   ✅ Found {len(verses)} verses")
            total_generated += len(verses)

            # Generate SQL
            sql = generate_sql_output(category, verses)
            f.write(sql)

        f.write("\n-- ============================================\n")
        f.write(f"-- COMPLETE: {total_generated} additional verses generated\n")
        f.write(f"-- Total with base: {100 + total_generated} verses\n")
        f.write("-- ============================================\n")

    conn.close()

    print(f"\n✅ Generated curriculum SQL: {output_path}")
    print(f"📊 Total verses: {100 + total_generated}")
    print(f"📝 Run: sqlite3 bible_bsb.db < seed_curriculum.sql")
    print(f"📝 Then: sqlite3 bible_bsb.db < seed_curriculum_complete_500.sql")

if __name__ == '__main__':
    main()
