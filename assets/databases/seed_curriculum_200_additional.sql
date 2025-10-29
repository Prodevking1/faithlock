-- ============================================
-- FaithLock Curriculum Extension - 200 Additional Verses
-- Manually curated for relevance and spiritual impact
-- Run seed_curriculum.sql FIRST (100 base verses)
-- Then run this file (200 additional verses)
-- Total: 300 verses (60 per category)
-- ============================================

-- ============================================
-- CATEGORY 1: TEMPTATION (40 additional verses)
-- Weeks 5-12 (5 verses per week)
-- ============================================

-- === WEEK 5: Victory Through Christ ===

-- 21. Romans 8:37
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'conquerors'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 37;

-- 22. 1 John 4:4
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'greater'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 4 AND verse = 4;

-- 23. 1 John 5:4
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'overcomes'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 5 AND verse = 4;

-- 24. John 16:33
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'overcome'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 16 AND verse = 33;

-- 25. Romans 8:1
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'condemnation'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 1;

-- === WEEK 6: Spiritual Warfare ===

-- 26. Ephesians 6:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'struggle'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 12;

-- 27. Ephesians 6:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'armor'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 13;

-- 28. Ephesians 6:14
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'truth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 14;

-- 29. Ephesians 6:16
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'shield'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 16;

-- 30. Ephesians 6:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 3,
  keyword = 'sword'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 17;

-- === WEEK 7: Walking in the Spirit ===

-- 31. Galatians 5:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'contrary'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 5 AND verse = 17;

-- 32. Galatians 5:25
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'walk'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 5 AND verse = 25;

-- 33. Romans 8:4
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 3,
  keyword = 'Spirit'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 4;

-- 34. Romans 8:6
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'mind'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 6;

-- 35. 2 Corinthians 5:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'creation'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 5 AND verse = 17;

-- === WEEK 8: Renewing the Mind ===

-- 36. Romans 12:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'transformed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 2;

-- 37. Philippians 4:8
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'think'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 4 AND verse = 8;

-- 38. Colossians 3:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'above'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 2;

-- 39. Psalm 19:14
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'meditation'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 19 AND verse = 14;

-- 40. Psalm 101:3
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'eyes'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 101 AND verse = 3;

-- === WEEK 9: God's Faithfulness ===

-- 41. Lamentations 3:22-23
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'mercies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Lamentations')
  AND chapter = 3 AND verse = 22;

-- 42. Deuteronomy 7:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'faithful'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 7 AND verse = 9;

-- 43. Psalm 145:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'promises'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 145 AND verse = 13;

-- 44. 2 Thessalonians 3:3
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'strengthen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Thessalonians')
  AND chapter = 3 AND verse = 3;

-- 45. 1 Thessalonians 5:24
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'faithful'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Thessalonians')
  AND chapter = 5 AND verse = 24;

-- === WEEK 10: Perseverance ===

-- 46. Hebrews 10:36
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 3,
  keyword = 'endurance'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 10 AND verse = 36;

-- 47. James 1:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'perseveres'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 1 AND verse = 12;

-- 48. Revelation 2:10
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 3,
  keyword = 'faithful'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation')
  AND chapter = 2 AND verse = 10;

-- 49. Galatians 6:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'weary'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 6 AND verse = 9;

-- 50. 2 Timothy 4:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 3,
  keyword = 'finished'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Timothy')
  AND chapter = 4 AND verse = 7;

-- === WEEK 11: God's Word as Weapon ===

-- 51. Hebrews 4:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'living'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 4 AND verse = 12;

-- 52. Psalm 119:105
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'lamp'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 105;

-- 53. Jeremiah 15:16
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'delight'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 15 AND verse = 16;

-- 54. Joshua 1:8
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'meditate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joshua')
  AND chapter = 1 AND verse = 8;

-- 55. Colossians 3:16
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'dwell'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 16;

-- === WEEK 12: Final Victory ===

-- 56. Revelation 3:21
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'overcomes'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation')
  AND chapter = 3 AND verse = 21;

-- 57. 1 Corinthians 15:57
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'victory'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 15 AND verse = 57;

-- 58. Jude 1:24
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'keep'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jude')
  AND chapter = 1 AND verse = 24;

-- 59. Psalm 18:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'fortress'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 18 AND verse = 2;

-- 60. Proverbs 18:10
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'tower'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 18 AND verse = 10;


-- ============================================
-- CATEGORY 2: FEAR & ANXIETY (40 additional verses)
-- Weeks 5-12 (5 verses per week)
-- ============================================

-- === WEEK 5: God's Presence ===

-- 21. Psalm 139:7
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'spirit'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 139 AND verse = 7;

-- 22. Matthew 28:20
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'always'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 28 AND verse = 20;

-- 23. Deuteronomy 31:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'before'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 31 AND verse = 8;

-- 24. Hebrews 13:5
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'leave'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 13 AND verse = 5;

-- 25. Psalm 73:23
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'always'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 73 AND verse = 23;

-- === WEEK 6: Perfect Love Casts Out Fear ===

-- 26. 1 John 4:18
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'perfect'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 4 AND verse = 18;

-- 27. Romans 8:38-39
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 3,
  keyword = 'separate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 38;

-- 28. Psalm 118:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'helper'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 118 AND verse = 6;

-- 29. Psalm 56:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'afraid'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 56 AND verse = 11;

-- 30. Nahum 1:7
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'stronghold'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nahum')
  AND chapter = 1 AND verse = 7;

-- === WEEK 7: Trust and Rest ===

-- 31. Psalm 62:5
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'hope'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 62 AND verse = 5;

-- 32. Matthew 11:28
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'rest'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 11 AND verse = 28;

-- 33. Psalm 4:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 4 AND verse = 8;

-- 34. Zephaniah 3:17
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'rejoice'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Zephaniah')
  AND chapter = 3 AND verse = 17;

-- 35. Psalm 62:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'trust'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 62 AND verse = 8;

-- === WEEK 8: God's Care ===

-- 36. Matthew 6:25-26
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'worry'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 6 AND verse = 25;

-- 37. Luke 12:7
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'afraid'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 12 AND verse = 7;

-- 38. Psalm 147:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'heals'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 147 AND verse = 3;

-- 39. Nahum 1:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'patient'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nahum')
  AND chapter = 1 AND verse = 3;

-- 40. Psalm 121:1-2
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'help'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 121 AND verse = 1;

-- === WEEK 9: Strength in Weakness ===

-- 41. 2 Corinthians 12:9
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'grace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 12 AND verse = 9;

-- 42. Isaiah 40:31
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'wait'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 40 AND verse = 31;

-- 43. Philippians 4:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'strengthens'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 4 AND verse = 13;

-- 44. Psalm 73:26
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'strength'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 73 AND verse = 26;

-- 45. Isaiah 40:29
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'weary'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 40 AND verse = 29;

-- === WEEK 10: God as Refuge ===

-- 46. Psalm 91:1-2
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'shelter'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 91 AND verse = 1;

-- 47. Psalm 91:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'shield'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 91 AND verse = 4;

-- 48. Psalm 18:30
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'perfect'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 18 AND verse = 30;

-- 49. Psalm 61:2
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'rock'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 61 AND verse = 2;

-- 50. Proverbs 14:26
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'confident'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 14 AND verse = 26;

-- === WEEK 11: Prayer and Peace ===

-- 51. Psalm 55:22
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'burden'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 55 AND verse = 22;

-- 52. Philippians 4:19
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'supply'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 4 AND verse = 19;

-- 53. Romans 15:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'hope'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 15 AND verse = 13;

-- 54. Psalm 119:165
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 165;

-- 55. Colossians 3:15
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 15;

-- === WEEK 12: Eternal Perspective ===

-- 56. 2 Corinthians 4:17-18
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'momentary'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 4 AND verse = 17;

-- 57. Revelation 21:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'tears'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation')
  AND chapter = 21 AND verse = 4;

-- 58. Psalm 16:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'joy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 16 AND verse = 11;

-- 59. Jeremiah 29:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'plans'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 29 AND verse = 11;

-- 60. Romans 8:28
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'good'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 28;


-- ============================================
-- CATEGORY 3: PRIDE (40 additional verses)
-- Weeks 5-12 (5 verses per week)
-- ============================================

-- === WEEK 5: Christ's Example ===

-- 21. Philippians 2:6-8
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 3,
  keyword = 'humbled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 2 AND verse = 6;

-- 22. Matthew 20:26-27
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'servant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 20 AND verse = 26;

-- 23. John 13:14-15
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'washed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 13 AND verse = 14;

-- 24. Mark 10:43-44
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'servant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 10 AND verse = 43;

-- 25. Luke 22:26
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'greatest'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 22 AND verse = 26;

-- === WEEK 6: Wisdom and Humility ===

-- 26. Proverbs 3:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'wise'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 3 AND verse = 7;

-- 27. Proverbs 12:15
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'counsel'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 12 AND verse = 15;

-- 28. Proverbs 15:33
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'humility'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 15 AND verse = 33;

-- 29. Ecclesiastes 7:8
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'patient'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 7 AND verse = 8;

-- 30. Proverbs 18:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'destruction'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 18 AND verse = 12;

-- === WEEK 7: Boasting in the Lord ===

-- 31. Jeremiah 9:24
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 9 AND verse = 24;

-- 32. 2 Corinthians 10:17
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 10 AND verse = 17;

-- 33. Galatians 6:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 6 AND verse = 14;

-- 34. Psalm 34:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 34 AND verse = 2;

-- 35. 1 Corinthians 1:29
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 1 AND verse = 29;

-- === WEEK 8: Grace and Dependence ===

-- 36. John 15:5
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'nothing'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 15 AND verse = 5;

-- 37. 2 Corinthians 3:5
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'competence'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 3 AND verse = 5;

-- 38. 1 Corinthians 4:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'received'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 4 AND verse = 7;

-- 39. Ephesians 2:8-9
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'grace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 2 AND verse = 8;

-- 40. Romans 3:27
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 3,
  keyword = 'boasting'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 3 AND verse = 27;

-- === WEEK 9: Servant Leadership ===

-- 41. Matthew 23:11-12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'servant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 23 AND verse = 11;

-- 42. 1 Peter 5:6
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'exalt'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 5 AND verse = 6;

-- 43. Titus 3:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'gentle'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Titus')
  AND chapter = 3 AND verse = 2;

-- 44. Proverbs 25:6-7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'exalt'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 25 AND verse = 6;

-- 45. Proverbs 27:1
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 27 AND verse = 1;

-- === WEEK 10: The Dangers of Pride ===

-- 46. Proverbs 6:16-17
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'haughty'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 6 AND verse = 16;

-- 47. Daniel 4:37
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 3,
  keyword = 'humbles'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Daniel')
  AND chapter = 4 AND verse = 37;

-- 48. Isaiah 5:21
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'wise'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 5 AND verse = 21;

-- 49. Proverbs 3:34
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'mocks'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 3 AND verse = 34;

-- 50. Proverbs 21:24
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'arrogance'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 21 AND verse = 24;

-- === WEEK 11: Putting Others First ===

-- 51. Romans 12:10
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'honor'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 10;

-- 52. 1 Corinthians 13:4
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'boast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 13 AND verse = 4;

-- 53. Ephesians 4:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'humility'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 4 AND verse = 2;

-- 54. Colossians 3:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'humility'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 12;

-- 55. Romans 12:3
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'sober'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 3;

-- === WEEK 12: Final Humility ===

-- 56. 1 Corinthians 3:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'growth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 3 AND verse = 7;

-- 57. Isaiah 66:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'humble'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 66 AND verse = 2;

-- 58. 2 Chronicles 7:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'humble'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 7 AND verse = 14;

-- 59. James 3:13
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'humility'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 13;

-- 60. Luke 18:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'humbles'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 18 AND verse = 14;


-- ============================================
-- CATEGORY 4: LUST (40 additional verses)
-- Weeks 5-12 (5 verses per week)
-- ============================================

-- === WEEK 5: Temple of the Holy Spirit ===

-- 21. 1 Corinthians 6:19-20
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'temple'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 6 AND verse = 19;

-- 22. 1 Corinthians 3:16
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'temple'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 3 AND verse = 16;

-- 23. Romans 6:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'instruments'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 6 AND verse = 13;

-- 24. 1 Thessalonians 4:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'vessel'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Thessalonians')
  AND chapter = 4 AND verse = 4;

-- 25. 2 Corinthians 7:1
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'cleanse'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 7 AND verse = 1;

-- === WEEK 6: Fleeing Immorality ===

-- 26. Proverbs 5:8
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'path'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 5 AND verse = 8;

-- 27. Proverbs 7:25
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'stray'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 7 AND verse = 25;

-- 28. Proverbs 6:27-28
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'burned'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 6 AND verse = 27;

-- 29. 1 Corinthians 10:8
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'immoral'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 10 AND verse = 8;

-- 30. Jude 1:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 3,
  keyword = 'immorality'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jude')
  AND chapter = 1 AND verse = 7;

-- === WEEK 7: Mind and Heart Guard ===

-- 31. Matthew 5:8
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'pure'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 5 AND verse = 8;

-- 32. Psalm 24:3-4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'clean'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 24 AND verse = 3;

-- 33. Proverbs 4:23
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 4 AND verse = 23;

-- 34. 2 Corinthians 10:5
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 3,
  keyword = 'captive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 10 AND verse = 5;

-- 35. Psalm 51:10
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'create'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 51 AND verse = 10;

-- === WEEK 8: Marriage and Honor ===

-- 36. 1 Corinthians 7:2
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'immorality'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 7 AND verse = 2;

-- 37. Proverbs 5:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'cistern'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 5 AND verse = 15;

-- 38. Song of Solomon 8:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'love'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Song of Solomon')
  AND chapter = 8 AND verse = 7;

-- 39. Genesis 2:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'unite'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 2 AND verse = 24;

-- 40. Malachi 2:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'faithful'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Malachi')
  AND chapter = 2 AND verse = 15;

-- === WEEK 9: Self-Control ===

-- 41. Galatians 5:22-23
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'self-control'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 5 AND verse = 22;

-- 42. 2 Peter 1:6
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'self-control'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Peter')
  AND chapter = 1 AND verse = 6;

-- 43. Proverbs 25:28
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'self-control'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 25 AND verse = 28;

-- 44. 1 Peter 1:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'self-controlled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 1 AND verse = 13;

-- 45. 1 Peter 4:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'self-controlled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 4 AND verse = 7;

-- === WEEK 10: Transformation ===

-- 46. Romans 6:11
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'alive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 6 AND verse = 11;

-- 47. Ezekiel 36:26
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 36 AND verse = 26;

-- 48. 2 Peter 1:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 3,
  keyword = 'divine'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Peter')
  AND chapter = 1 AND verse = 4;

-- 49. 1 John 3:3
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'purifies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 3 AND verse = 3;

-- 50. Ezekiel 11:19
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 11 AND verse = 19;

-- === WEEK 11: Living Sacrifices ===

-- 51. Romans 12:1
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'bodies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 1;

-- 52. 1 Thessalonians 5:23
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'sanctify'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Thessalonians')
  AND chapter = 5 AND verse = 23;

-- 53. 1 Peter 1:15-16
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'holy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 1 AND verse = 15;

-- 54. Leviticus 19:2
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'holy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 19 AND verse = 2;

-- 55. Psalm 51:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'cleanse'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 51 AND verse = 7;

-- === WEEK 12: Victory and Holiness ===

-- 56. 1 Corinthians 10:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'temptation'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 10 AND verse = 13;

-- 57. 1 John 5:18
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 3,
  keyword = 'protects'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 5 AND verse = 18;

-- 58. Psalm 119:37
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'worthless'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 37;

-- 59. James 4:8
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'purify'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 4 AND verse = 8;

-- 60. 1 John 2:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'world'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 2 AND verse = 15;


-- ============================================
-- CATEGORY 5: ANGER (40 additional verses)
-- Weeks 5-12 (5 verses per week)
-- ============================================

-- === WEEK 5: Forgiveness ===

-- 21. Ephesians 4:26
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'sunset'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 4 AND verse = 26;

-- 22. Matthew 6:14
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'forgive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 6 AND verse = 14;

-- 23. Matthew 18:21-22
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'seventy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 18 AND verse = 21;

-- 24. Luke 6:37
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'condemn'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 6 AND verse = 37;

-- 25. Colossians 3:13
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'forgive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 13;

-- === WEEK 6: Gentleness ===

-- 26. Proverbs 15:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'tempered'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 15 AND verse = 18;

-- 27. Proverbs 17:27
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'restrains'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 17 AND verse = 27;

-- 28. Titus 3:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'gentle'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Titus')
  AND chapter = 3 AND verse = 2;

-- 29. 2 Timothy 2:24
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'gentle'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Timothy')
  AND chapter = 2 AND verse = 24;

-- 30. James 3:17
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'gentle'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 17;

-- === WEEK 7: Patience ===

-- 31. 1 Corinthians 13:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'patient'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 13 AND verse = 4;

-- 32. Colossians 3:12
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'patience'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 3 AND verse = 12;

-- 33. Galatians 5:22
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'patience'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 5 AND verse = 22;

-- 34. 1 Thessalonians 5:14
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'patient'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Thessalonians')
  AND chapter = 5 AND verse = 14;

-- 35. James 5:7-8
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'patient'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 5 AND verse = 7;

-- === WEEK 8: Peacemaking ===

-- 36. Matthew 5:9
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peacemakers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 5 AND verse = 9;

-- 37. Romans 12:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 18;

-- 38. Hebrews 12:14
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 12 AND verse = 14;

-- 39. James 3:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 18;

-- 40. 1 Peter 3:11
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 3 AND verse = 11;

-- === WEEK 9: Love Your Enemies ===

-- 41. Matthew 5:44
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 5 AND verse = 44;

-- 42. Luke 6:27-28
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 6 AND verse = 27;

-- 43. Romans 12:20
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 20;

-- 44. Proverbs 24:17
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 24 AND verse = 17;

-- 45. Proverbs 25:21
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 25 AND verse = 21;

-- === WEEK 10: Controlling the Tongue ===

-- 46. James 3:5-6
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'tongue'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 5;

-- 47. James 3:8
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'tongue'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 8;

-- 48. Proverbs 21:23
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'tongue'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 21 AND verse = 23;

-- 49. Proverbs 10:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'words'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 10 AND verse = 19;

-- 50. Proverbs 12:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'tongue'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 12 AND verse = 18;

-- === WEEK 11: God's Mercy ===

-- 51. Psalm 103:8
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'compassionate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 103 AND verse = 8;

-- 52. Numbers 14:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'slow'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 14 AND verse = 18;

-- 53. Joel 2:13
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'compassionate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joel')
  AND chapter = 2 AND verse = 13;

-- 54. Micah 7:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'pardons'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Micah')
  AND chapter = 7 AND verse = 18;

-- 55. Exodus 34:6
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'compassionate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 34 AND verse = 6;

-- === WEEK 12: Final Peace ===

-- 56. Philippians 4:7
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'guard'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 4 AND verse = 7;

-- 57. John 14:27
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 14 AND verse = 27;

-- 58. Isaiah 26:3
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'steadfast'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 26 AND verse = 3;

-- 59. Romans 14:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 14 AND verse = 19;

-- 60. 2 Thessalonians 3:16
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Thessalonians')
  AND chapter = 3 AND verse = 16;


-- ============================================
-- CURRICULUM EXTENSION COMPLETE
-- ============================================
-- Base curriculum: 100 verses (seed_curriculum.sql)
-- Extension: 200 verses (this file)
-- Total: 300 verses (60 per category, 12 weeks)
-- All verses manually curated for relevance
-- ============================================
