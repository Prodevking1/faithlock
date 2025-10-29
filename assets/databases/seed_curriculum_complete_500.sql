-- ============================================
-- FaithLock Complete Curriculum - 500 Power Verses
-- Auto-generated from Bible database
-- Run seed_curriculum.sql FIRST (100 base verses)
-- Then run this file (400 additional verses)
-- ============================================


-- ============================================
-- CATEGORY: TEMPTATION (80 verses)
-- ============================================


-- === WEEK 1 ===

-- 1. Judges 16:23
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'lords'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Judges')
  AND chapter = 16 AND verse = 23;

-- 2. Exodus 8:26
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'moses'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 8 AND verse = 26;

-- 3. Genesis 18:22
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'turned'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 18 AND verse = 22;

-- 4. Leviticus 17:6
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'priest'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 17 AND verse = 6;

-- 5. I Kings 2:32
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'bring'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 2 AND verse = 32;


-- === WEEK 2 ===

-- 6. Numbers 32:25
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'gadites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 32 AND verse = 25;

-- 7. Matthew 27:47
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'those'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 27 AND verse = 47;

-- 8. Exodus 25:35
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'branches'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 25 AND verse = 35;

-- 9. Numbers 4:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'cloth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 4 AND verse = 9;

-- 10. Leviticus 24:15
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'israelites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 24 AND verse = 15;


-- === WEEK 3 ===

-- 11. Isaiah 27:3
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'keeper;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 27 AND verse = 3;

-- 12. Exodus 4:28
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'moses'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 4 AND verse = 28;

-- 13. Proverbs 20:24
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'man’s'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 20 AND verse = 24;

-- 14. I Kings 13:1
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'suddenly'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 13 AND verse = 1;

-- 15. Ezra 9:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'fathers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezra')
  AND chapter = 9 AND verse = 7;


-- === WEEK 4 ===

-- 16. Isaiah 59:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'iniquities'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 59 AND verse = 2;

-- 17. Numbers 29:11
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'include'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 29 AND verse = 11;

-- 18. II Chronicles 21:19
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'continued'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 21 AND verse = 19;

-- 19. Numbers 15:39
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'these'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 15 AND verse = 39;

-- 20. Jeremiah 40:5
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'before'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 40 AND verse = 5;


-- === WEEK 5 ===

-- 21. Micah 6:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'pleased'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Micah')
  AND chapter = 6 AND verse = 7;

-- 22. II Kings 20:6
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'fifteen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 20 AND verse = 6;

-- 23. I John 5:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'accept'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 5 AND verse = 9;

-- 24. II Kings 24:14
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'carried'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 24 AND verse = 14;

-- 25. Psalms 14:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'looks'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 14 AND verse = 2;


-- === WEEK 6 ===

-- 26. Galatians 3:10
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'works'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 3 AND verse = 10;

-- 27. Numbers 31:48
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'officers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 31 AND verse = 48;

-- 28. John 16:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'however'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 16 AND verse = 13;

-- 29. Philippians 3:1
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'finally'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Philippians')
  AND chapter = 3 AND verse = 1;

-- 30. John 21:24
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'disciple'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 21 AND verse = 24;


-- === WEEK 7 ===

-- 31. Mark 3:26
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'satan'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 3 AND verse = 26;

-- 32. Exodus 12:39
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'since'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 12 AND verse = 39;

-- 33. Jeremiah 5:25
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'iniquities'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 5 AND verse = 25;

-- 34. Zechariah 10:6
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'strengthen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Zechariah')
  AND chapter = 10 AND verse = 6;

-- 35. Jeremiah 17:22
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'carry'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 17 AND verse = 22;


-- === WEEK 8 ===

-- 36. Matthew 13:41
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'angels'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 13 AND verse = 41;

-- 37. Psalms 40:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'evils'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 40 AND verse = 12;

-- 38. I Kings 18:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'obadiah'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 18 AND verse = 9;

-- 39. Leviticus 16:20
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'aaron'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 16 AND verse = 20;

-- 40. Proverbs 8:15
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'kings'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 8 AND verse = 15;


-- === WEEK 9 ===

-- 41. Deuteronomy 8:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 8 AND verse = 17;

-- 42. I Corinthians 2:15
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'spiritual'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 2 AND verse = 15;

-- 43. II Kings 15:28
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'sight'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 15 AND verse = 28;

-- 44. Proverbs 28:5
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'understand'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 28 AND verse = 5;

-- 45. Ephesians 2:1
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'trespasses'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 2 AND verse = 1;


-- === WEEK 10 ===

-- 46. Proverbs 31:27
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'watches'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 31 AND verse = 27;

-- 47. Daniel 9:14
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'therefore'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Daniel')
  AND chapter = 9 AND verse = 14;

-- 48. I Samuel 4:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'arrived'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 4 AND verse = 13;

-- 49. II Chronicles 24:20
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'spirit'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 24 AND verse = 20;

-- 50. Genesis 18:19
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'chosen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 18 AND verse = 19;


-- === WEEK 11 ===

-- 51. II Chronicles 4:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'lampstands'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 4 AND verse = 7;

-- 52. Micah 1:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'harness'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Micah')
  AND chapter = 1 AND verse = 13;

-- 53. Lamentations 4:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'while'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Lamentations')
  AND chapter = 4 AND verse = 17;

-- 54. Mark 5:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'jesus'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 5 AND verse = 2;

-- 55. Isaiah 58:8
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'light'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 58 AND verse = 8;


-- === WEEK 12 ===

-- 56. II Chronicles 4:14
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'stands;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 4 AND verse = 14;

-- 57. Acts 2:40
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'other'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 2 AND verse = 40;

-- 58. Matthew 4:6
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = '“throw'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 4 AND verse = 6;

-- 59. II Thessalonians 3:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'command'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Thessalonians')
  AND chapter = 3 AND verse = 12;

-- 60. Leviticus 26:29
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'flesh'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 26 AND verse = 29;


-- === WEEK 13 ===

-- 61. Psalms 47:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'earth;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 47 AND verse = 7;

-- 62. Joshua 22:9
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'reubenites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joshua')
  AND chapter = 22 AND verse = 9;

-- 63. Psalms 48:1
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'great'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 48 AND verse = 1;

-- 64. Ezekiel 37:10
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'prophesied'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 37 AND verse = 10;

-- 65. Psalms 119:125
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'servant;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 125;


-- === WEEK 14 ===

-- 66. II Timothy 1:8
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'ashamed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Timothy')
  AND chapter = 1 AND verse = 8;

-- 67. Exodus 40:7
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'place'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 40 AND verse = 7;

-- 68. Genesis 46:34
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 14,
  difficulty = 3,
  keyword = '‘your'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 46 AND verse = 34;

-- 69. Psalms 119:53
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'taken'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 53;

-- 70. Exodus 16:4
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'moses'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 16 AND verse = 4;


-- === WEEK 15 ===

-- 71. Psalms 119:145
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'heart;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 145;

-- 72. Job 36:10
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'opens'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 36 AND verse = 10;

-- 73. Romans 5:20
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'trespass'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 5 AND verse = 20;

-- 74. Ecclesiastes 8:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'although'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 8 AND verse = 12;

-- 75. I Samuel 24:17
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'david'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 24 AND verse = 17;


-- === WEEK 16 ===

-- 76. John 3:5
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'jesus'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 3 AND verse = 5;

-- 77. Psalms 60:8
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'washbasin;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 60 AND verse = 8;

-- 78. Galatians 4:2
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'subject'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 4 AND verse = 2;

-- 79. II Chronicles 18:11
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'prophets'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 18 AND verse = 11;

-- 80. Numbers 10:25
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'finally'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 10 AND verse = 25;

-- ============================================
-- CATEGORY: FEAR_ANXIETY (80 verses)
-- ============================================


-- === WEEK 1 ===

-- 1. I Samuel 10:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'before'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 10 AND verse = 8;

-- 2. Isaiah 11:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'delight'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 11 AND verse = 3;

-- 3. Job 39:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'great'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 39 AND verse = 11;

-- 4. Psalms 64:10
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'righteous'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 64 AND verse = 10;

-- 5. Ezekiel 34:27
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'trees'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 34 AND verse = 27;


-- === WEEK 2 ===

-- 6. Isaiah 54:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'afraid'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 54 AND verse = 4;

-- 7. Acts 28:9
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'after'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 28 AND verse = 9;

-- 8. Romans 1:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'impart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 1 AND verse = 11;

-- 9. II Kings 21:17
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'manasseh'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 21 AND verse = 17;

-- 10. I Timothy 1:19
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'holding'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Timothy')
  AND chapter = 1 AND verse = 19;


-- === WEEK 3 ===

-- 11. Isaiah 21:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 21 AND verse = 4;

-- 12. Ezekiel 27:35
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'people'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 27 AND verse = 35;

-- 13. Exodus 4:21
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'instructed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 4 AND verse = 21;

-- 14. II Thessalonians 1:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'always'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Thessalonians')
  AND chapter = 1 AND verse = 11;

-- 15. Job 30:20
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'answer;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 30 AND verse = 20;


-- === WEEK 4 ===

-- 16. Ecclesiastes 4:12
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'though'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 4 AND verse = 12;

-- 17. II Chronicles 17:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'supplies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 17 AND verse = 13;

-- 18. Hebrews 11:31
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'faith'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 11 AND verse = 31;

-- 19. II Chronicles 27:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'jotham'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 27 AND verse = 6;

-- 20. Romans 8:24
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'saved;'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 24;


-- === WEEK 5 ===

-- 21. Psalms 111:10
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'beginning'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 111 AND verse = 10;

-- 22. Joshua 2:14
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'lives'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joshua')
  AND chapter = 2 AND verse = 14;

-- 23. Psalms 102:1
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'prayer'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 102 AND verse = 1;

-- 24. II Samuel 2:7
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'strong'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 2 AND verse = 7;

-- 25. Job 5:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'safety'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 5 AND verse = 4;


-- === WEEK 6 ===

-- 26. Psalms 110:2
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'extends'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 110 AND verse = 2;

-- 27. Numbers 5:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = '“tell'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 5 AND verse = 6;

-- 28. Job 7:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'think'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 7 AND verse = 13;

-- 29. I Corinthians 16:12
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'about'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 16 AND verse = 12;

-- 30. Leviticus 23:24
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 6,
  difficulty = 2,
  keyword = '“speak'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 23 AND verse = 24;


-- === WEEK 7 ===

-- 31. Zechariah 8:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'curse'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Zechariah')
  AND chapter = 8 AND verse = 13;

-- 32. Leviticus 25:43
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'harshly'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 25 AND verse = 43;

-- 33. Numbers 25:12
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'declare'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 25 AND verse = 12;

-- 34. Job 27:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'instruct'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 27 AND verse = 11;

-- 35. Psalms 62:10
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'place'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 62 AND verse = 10;


-- === WEEK 8 ===

-- 36. Psalms 132:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'arise'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 132 AND verse = 8;

-- 37. I Corinthians 8:10
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'someone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 8 AND verse = 10;

-- 38. Matthew 15:31
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'crowd'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 15 AND verse = 31;

-- 39. Matthew 17:4
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'peter'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 17 AND verse = 4;

-- 40. Romans 8:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'flesh'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 6;


-- === WEEK 9 ===

-- 41. Psalms 72:12
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'deliver'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 72 AND verse = 12;

-- 42. Psalms 89:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'mighty'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 89 AND verse = 13;

-- 43. Psalms 119:138
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'testimonies'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 138;

-- 44. Acts 28:15
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'brothers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 28 AND verse = 15;

-- 45. II John 1:12
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'things'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II John')
  AND chapter = 1 AND verse = 12;


-- === WEEK 10 ===

-- 46. Exodus 6:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'appeared'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 6 AND verse = 3;

-- 47. Romans 13:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'rulers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 13 AND verse = 3;

-- 48. Job 26:14
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'indeed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 26 AND verse = 14;

-- 49. Acts 10:26
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'peter'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 10 AND verse = 26;

-- 50. Acts 3:16
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'faith'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 3 AND verse = 16;


-- === WEEK 11 ===

-- 51. Romans 15:5
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'gives'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 15 AND verse = 5;

-- 52. Romans 10:8
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'mouth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 10 AND verse = 8;

-- 53. Ezekiel 46:2
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'prince'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 46 AND verse = 2;

-- 54. Proverbs 31:30
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'charm'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 31 AND verse = 30;

-- 55. Proverbs 3:29
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'devise'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 3 AND verse = 29;


-- === WEEK 12 ===

-- 56. I Samuel 11:15
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'people'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 11 AND verse = 15;

-- 57. Psalms 62:1
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'alone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 62 AND verse = 1;

-- 58. Genesis 19:30
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'daughters'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 19 AND verse = 30;

-- 59. Psalms 61:7
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'enthroned'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 61 AND verse = 7;

-- 60. Proverbs 29:18
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'where'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 29 AND verse = 18;


-- === WEEK 13 ===

-- 61. Job 15:31
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'deceive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 15 AND verse = 31;

-- 62. Jeremiah 46:25
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'hosts'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 46 AND verse = 25;

-- 63. Psalms 19:14
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'words'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 19 AND verse = 14;

-- 64. Joel 2:11
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'raises'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joel')
  AND chapter = 2 AND verse = 11;

-- 65. Isaiah 49:25
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'indeed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 49 AND verse = 25;


-- === WEEK 14 ===

-- 66. Luke 9:34
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'while'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 9 AND verse = 34;

-- 67. Ezra 3:3
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'altar'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezra')
  AND chapter = 3 AND verse = 3;

-- 68. Exodus 34:21
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'labor'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 34 AND verse = 21;

-- 69. Daniel 6:20
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'reached'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Daniel')
  AND chapter = 6 AND verse = 20;

-- 70. Psalms 65:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'formed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 65 AND verse = 6;


-- === WEEK 15 ===

-- 71. II Samuel 22:26
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'faithful'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 22 AND verse = 26;

-- 72. Proverbs 10:29
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'refuge'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 10 AND verse = 29;

-- 73. II Chronicles 6:32
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'foreigner'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 6 AND verse = 32;

-- 74. Joshua 1:18
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joshua')
  AND chapter = 1 AND verse = 18;

-- 75. Nehemiah 9:33
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'befallen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nehemiah')
  AND chapter = 9 AND verse = 33;


-- === WEEK 16 ===

-- 76. Lamentations 1:17
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'stretches'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Lamentations')
  AND chapter = 1 AND verse = 17;

-- 77. Psalms 150:1
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'hallelujah!'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 150 AND verse = 1;

-- 78. I Kings 22:6
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'israel'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 22 AND verse = 6;

-- 79. II Timothy 2:13
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'faithless'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Timothy')
  AND chapter = 2 AND verse = 13;

-- 80. Genesis 43:23
UPDATE BSB_verses SET
  category = 'fear_anxiety',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'fine”'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 43 AND verse = 23;

-- ============================================
-- CATEGORY: PRIDE (80 verses)
-- ============================================


-- === WEEK 1 ===

-- 1. II Chronicles 36:20
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'those'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 36 AND verse = 20;

-- 2. Isaiah 58:8
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'light'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 58 AND verse = 8;

-- 3. I Chronicles 19:4
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'hanun'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 19 AND verse = 4;

-- 4. James 3:1
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'become'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 3 AND verse = 1;

-- 5. John 13:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'teacher'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 13 AND verse = 14;


-- === WEEK 2 ===

-- 6. Luke 21:31
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'these'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 21 AND verse = 31;

-- 7. Psalms 86:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'arrogant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 86 AND verse = 14;

-- 8. I Corinthians 14:26
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'brothers?'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 14 AND verse = 26;

-- 9. Isaiah 19:11
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'princes'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 19 AND verse = 11;

-- 10. Matthew 12:18
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 2,
  difficulty = 1,
  keyword = '“here'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 12 AND verse = 18;


-- === WEEK 3 ===

-- 11. Psalms 138:5
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'glory'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 138 AND verse = 5;

-- 12. Proverbs 30:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'surely'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 30 AND verse = 2;

-- 13. I Kings 8:28
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'regard'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 8 AND verse = 28;

-- 14. Ecclesiastes 7:11
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'wisdom'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 7 AND verse = 11;

-- 15. Jeremiah 51:57
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'princes'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 51 AND verse = 57;


-- === WEEK 4 ===

-- 16. Jeremiah 10:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'earth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 10 AND verse = 12;

-- 17. Isaiah 36:11
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'eliakim'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 36 AND verse = 11;

-- 18. Ephesians 6:8
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'because'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ephesians')
  AND chapter = 6 AND verse = 8;

-- 19. II Samuel 9:11
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 4,
  difficulty = 1,
  keyword = '“your'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 9 AND verse = 11;

-- 20. Exodus 26:24
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'coupled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 26 AND verse = 24;


-- === WEEK 5 ===

-- 21. Proverbs 9:9
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'instruct'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 9 AND verse = 9;

-- 22. Exodus 12:42
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'because'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 12 AND verse = 42;

-- 23. Acts 22:19
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = '‘lord’'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 22 AND verse = 19;

-- 24. Numbers 4:37
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'these'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 4 AND verse = 37;

-- 25. Numbers 4:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'place'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 4 AND verse = 14;


-- === WEEK 6 ===

-- 26. Genesis 31:32
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 31 AND verse = 32;

-- 27. I Timothy 3:6
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'recent'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Timothy')
  AND chapter = 3 AND verse = 6;

-- 28. Psalms 76:1
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'known'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 76 AND verse = 1;

-- 29. Luke 23:34
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'jesus'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 23 AND verse = 34;

-- 30. Psalms 35:27
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'those'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 35 AND verse = 27;


-- === WEEK 7 ===

-- 31. II Kings 4:25
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'mount'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 4 AND verse = 25;

-- 32. Acts 17:13
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'thessalonica'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 17 AND verse = 13;

-- 33. Revelation of John 22:9
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'that!'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation of John')
  AND chapter = 22 AND verse = 9;

-- 34. Luke 15:17
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'finally'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 15 AND verse = 17;

-- 35. Job 5:13
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'catches'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 5 AND verse = 13;


-- === WEEK 8 ===

-- 36. Mark 4:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = '‘they'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 4 AND verse = 12;

-- 37. Matthew 25:19
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'after'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 25 AND verse = 19;

-- 38. Proverbs 17:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'servant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 17 AND verse = 2;

-- 39. Deuteronomy 30:20
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'prolong'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 30 AND verse = 20;

-- 40. II Samuel 14:19
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'asked'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 14 AND verse = 19;


-- === WEEK 9 ===

-- 41. Hebrews 1:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'about'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 1 AND verse = 7;

-- 42. Revelation of John 19:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'blazing'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation of John')
  AND chapter = 19 AND verse = 12;

-- 43. Genesis 44:23
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'servants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 44 AND verse = 23;

-- 44. Acts 6:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'continued'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 6 AND verse = 7;

-- 45. Job 19:15
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'guests'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 19 AND verse = 15;


-- === WEEK 10 ===

-- 46. Nehemiah 1:10
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'servants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nehemiah')
  AND chapter = 1 AND verse = 10;

-- 47. I Samuel 18:23
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'saul’s'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 18 AND verse = 23;

-- 48. Job 33:3
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'words'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 33 AND verse = 3;

-- 49. Acts 9:30
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'brothers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 9 AND verse = 30;

-- 50. II Corinthians 4:15
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'benefit'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Corinthians')
  AND chapter = 4 AND verse = 15;


-- === WEEK 11 ===

-- 51. I Kings 2:44
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 2 AND verse = 44;

-- 52. II Samuel 12:5
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'david'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 12 AND verse = 5;

-- 53. II Samuel 12:19
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'david'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 12 AND verse = 19;

-- 54. II Kings 19:23
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'through'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 19 AND verse = 23;

-- 55. Galatians 2:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'response'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 2 AND verse = 2;


-- === WEEK 12 ===

-- 56. Job 21:22
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 21 AND verse = 22;

-- 57. Job 5:27
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'indeed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 5 AND verse = 27;

-- 58. Isaiah 37:24
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'through'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 37 AND verse = 24;

-- 59. Ecclesiastes 2:9
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'became'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 2 AND verse = 9;

-- 60. John 8:54
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'jesus'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 8 AND verse = 54;


-- === WEEK 13 ===

-- 61. Nehemiah 13:19
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'evening'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nehemiah')
  AND chapter = 13 AND verse = 19;

-- 62. Esther 1:3
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'third'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Esther')
  AND chapter = 1 AND verse = 3;

-- 63. Romans 6:17
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'thanks'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 6 AND verse = 17;

-- 64. Acts 19:25
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'demetrius'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 19 AND verse = 25;

-- 65. Numbers 32:31
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'gadites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 32 AND verse = 31;


-- === WEEK 14 ===

-- 66. Leviticus 23:29
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 23 AND verse = 29;

-- 67. Jonah 1:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 14,
  difficulty = 3,
  keyword = '“pick'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jonah')
  AND chapter = 1 AND verse = 12;

-- 68. Ezekiel 24:21
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'house'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 24 AND verse = 21;

-- 69. Ezra 2:55
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'descendants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezra')
  AND chapter = 2 AND verse = 55;

-- 70. Psalms 69:36
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'descendants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 69 AND verse = 36;


-- === WEEK 15 ===

-- 71. Ezekiel 12:20
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'inhabited'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 12 AND verse = 20;

-- 72. Psalms 9:20
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'terror'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 9 AND verse = 20;

-- 73. Daniel 10:12
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'afraid'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Daniel')
  AND chapter = 10 AND verse = 12;

-- 74. Colossians 2:1
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'struggling'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Colossians')
  AND chapter = 2 AND verse = 1;

-- 75. Jeremiah 44:10
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'humbled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 44 AND verse = 10;


-- === WEEK 16 ===

-- 76. Luke 12:2
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'there'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 12 AND verse = 2;

-- 77. Psalms 104:31
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'glory'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 104 AND verse = 31;

-- 78. Genesis 24:65
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'asked'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 24 AND verse = 65;

-- 79. Psalms 102:14
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'servants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 102 AND verse = 14;

-- 80. Romans 2:7
UPDATE BSB_verses SET
  category = 'pride',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'those'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 2 AND verse = 7;

-- ============================================
-- CATEGORY: LUST (80 verses)
-- ============================================


-- === WEEK 1 ===

-- 1. Luke 16:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'justify'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 16 AND verse = 15;

-- 2. Psalms 49:3
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'mouth'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 49 AND verse = 3;

-- 3. Acts 26:21
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'reason'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 26 AND verse = 21;

-- 4. Jeremiah 43:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'demolish'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 43 AND verse = 13;

-- 5. II Chronicles 28:23
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'since'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 28 AND verse = 23;


-- === WEEK 2 ===

-- 6. I Samuel 18:6
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'troops'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 18 AND verse = 6;

-- 7. Leviticus 7:35
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'portion'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 7 AND verse = 35;

-- 8. Romans 11:27
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'covenant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 11 AND verse = 27;

-- 9. Luke 16:16
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'prophets'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 16 AND verse = 16;

-- 10. Hosea 10:2
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'their'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hosea')
  AND chapter = 10 AND verse = 2;


-- === WEEK 3 ===

-- 11. Ecclesiastes 8:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'since'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ecclesiastes')
  AND chapter = 8 AND verse = 7;

-- 12. Ezekiel 16:30
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'weak-willed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 16 AND verse = 30;

-- 13. Revelation of John 17:17
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'their'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation of John')
  AND chapter = 17 AND verse = 17;

-- 14. Isaiah 1:18
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 3,
  difficulty = 1,
  keyword = '“come'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 1 AND verse = 18;

-- 15. Romans 9:31
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'israel'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 9 AND verse = 31;


-- === WEEK 4 ===

-- 16. Psalms 37:32
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'though'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 37 AND verse = 32;

-- 17. Romans 15:23
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'there'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 15 AND verse = 23;

-- 18. I Chronicles 21:8
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'david'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 21 AND verse = 8;

-- 19. I Peter 3:12
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'righteous'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Peter')
  AND chapter = 3 AND verse = 12;

-- 20. Psalms 78:41
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'again'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 78 AND verse = 41;


-- === WEEK 5 ===

-- 21. I Kings 8:32
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'heaven'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 8 AND verse = 32;

-- 22. Habakkuk 1:6
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'behold'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Habakkuk')
  AND chapter = 1 AND verse = 6;

-- 23. Isaiah 65:14
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'servants'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 65 AND verse = 14;

-- 24. Romans 12:10
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'devoted'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 12 AND verse = 10;

-- 25. I Corinthians 7:5
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'deprive'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 7 AND verse = 5;


-- === WEEK 6 ===

-- 26. Proverbs 9:9
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'instruct'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 9 AND verse = 9;

-- 27. Numbers 14:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'because'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 14 AND verse = 24;

-- 28. Jeremiah 23:17
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'saying'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 23 AND verse = 17;

-- 29. Romans 6:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'present'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 6 AND verse = 13;

-- 30. Acts 11:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'barnabas'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 11 AND verse = 24;


-- === WEEK 7 ===

-- 31. II Chronicles 31:6
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'israelites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 31 AND verse = 6;

-- 32. I Kings 5:11
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'after'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 5 AND verse = 11;

-- 33. II Chronicles 24:2
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'joash'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 24 AND verse = 2;

-- 34. Leviticus 26:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'hostility'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 26 AND verse = 24;

-- 35. Proverbs 24:32
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'observed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 24 AND verse = 32;


-- === WEEK 8 ===

-- 36. Esther 6:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'haman'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Esther')
  AND chapter = 6 AND verse = 13;

-- 37. Proverbs 15:9
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'detests'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 15 AND verse = 9;

-- 38. Romans 2:22
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'forbid'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 2 AND verse = 22;

-- 39. Obadiah 1:16
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'drank'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Obadiah')
  AND chapter = 1 AND verse = 16;

-- 40. Jeremiah 13:17
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'listen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 13 AND verse = 17;


-- === WEEK 9 ===

-- 41. Genesis 8:21
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'smelled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 8 AND verse = 21;

-- 42. Psalms 141:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'heart'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 141 AND verse = 4;

-- 43. Isaiah 14:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'contempt'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 14 AND verse = 4;

-- 44. II Chronicles 26:10
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'since'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 26 AND verse = 10;

-- 45. Romans 16:18
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'people'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 16 AND verse = 18;


-- === WEEK 10 ===

-- 46. I Samuel 2:1
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'hannah'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 2 AND verse = 1;

-- 47. Isaiah 66:20
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'bring'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 66 AND verse = 20;

-- 48. Jeremiah 7:9
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'steal'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 7 AND verse = 9;

-- 49. Proverbs 17:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'acquitting'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 17 AND verse = 15;

-- 50. Ezekiel 46:19
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'brought'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 46 AND verse = 19;


-- === WEEK 11 ===

-- 51. Deuteronomy 24:1
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'marries'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 24 AND verse = 1;

-- 52. Mark 9:33
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'capernaum'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 9 AND verse = 33;

-- 53. I Chronicles 29:12
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'riches'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 29 AND verse = 12;

-- 54. II Chronicles 7:14
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'people'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Chronicles')
  AND chapter = 7 AND verse = 14;

-- 55. Leviticus 5:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'someone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 5 AND verse = 15;


-- === WEEK 12 ===

-- 56. Psalms 119:148
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'anticipate'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 148;

-- 57. Matthew 5:32
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 5 AND verse = 32;

-- 58. Proverbs 10:21
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'righteous'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 10 AND verse = 21;

-- 59. Leviticus 10:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'place'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 10 AND verse = 13;

-- 60. I Samuel 19:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'jonathan'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 19 AND verse = 4;


-- === WEEK 13 ===

-- 61. Romans 4:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'righteousness'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 4 AND verse = 24;

-- 62. Titus 3:11
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'knowing'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Titus')
  AND chapter = 3 AND verse = 11;

-- 63. Psalms 72:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'righteous'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 72 AND verse = 7;

-- 64. Ezekiel 27:26
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'oarsmen'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 27 AND verse = 26;

-- 65. Numbers 36:11
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'mahlah'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 36 AND verse = 11;


-- === WEEK 14 ===

-- 66. Leviticus 15:4
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'which'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 15 AND verse = 4;

-- 67. Ezekiel 39:27
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'bring'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 39 AND verse = 27;

-- 68. Isaiah 11:5
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'righteousness'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 11 AND verse = 5;

-- 69. Ezekiel 1:11
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'their'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 1 AND verse = 11;

-- 70. Genesis 10:17
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'hivites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 10 AND verse = 17;


-- === WEEK 15 ===

-- 71. Numbers 28:24
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'offer'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 28 AND verse = 24;

-- 72. Job 24:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'adulterer'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 24 AND verse = 15;

-- 73. Galatians 6:17
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'cause'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 6 AND verse = 17;

-- 74. Isaiah 3:5
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'people'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 3 AND verse = 5;

-- 75. I Samuel 2:2
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'there'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 2 AND verse = 2;


-- === WEEK 16 ===

-- 76. II Kings 8:19
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'servant'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 8 AND verse = 19;

-- 77. Nehemiah 9:13
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'mount'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nehemiah')
  AND chapter = 9 AND verse = 13;

-- 78. Romans 8:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'because'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 8 AND verse = 7;

-- 79. Leviticus 5:7
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'however'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 5 AND verse = 7;

-- 80. Psalms 92:15
UPDATE BSB_verses SET
  category = 'lust',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'proclaim'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 92 AND verse = 15;

-- ============================================
-- CATEGORY: ANGER (80 verses)
-- ============================================


-- === WEEK 1 ===

-- 1. Nahum 1:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'jealous'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Nahum')
  AND chapter = 1 AND verse = 2;

-- 2. Jeremiah 12:6
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'brothers—'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 12 AND verse = 6;

-- 3. Leviticus 9:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'peace'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Leviticus')
  AND chapter = 9 AND verse = 4;

-- 4. Matthew 9:27
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'jesus'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 9 AND verse = 27;

-- 5. II Thessalonians 3:6
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'command'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Thessalonians')
  AND chapter = 3 AND verse = 6;


-- === WEEK 2 ===

-- 6. Proverbs 21:14
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'secret'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 21 AND verse = 14;

-- 7. I Kings 22:14
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'micaiah'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 22 AND verse = 14;

-- 8. Matthew 10:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'these'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Matthew')
  AND chapter = 10 AND verse = 2;

-- 9. Luke 1:72
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'mercy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 1 AND verse = 72;

-- 10. Exodus 32:22
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 2,
  difficulty = 1,
  keyword = 'enraged'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 32 AND verse = 22;


-- === WEEK 3 ===

-- 11. Mark 2:9
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 3,
  difficulty = 1,
  keyword = '“which'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Mark')
  AND chapter = 2 AND verse = 9;

-- 12. Job 9:15
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'right'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Job')
  AND chapter = 9 AND verse = 15;

-- 13. I John 4:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'there'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I John')
  AND chapter = 4 AND verse = 18;

-- 14. Isaiah 57:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'bringing'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 57 AND verse = 19;

-- 15. Genesis 42:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 3,
  difficulty = 1,
  keyword = 'jacob'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 42 AND verse = 4;


-- === WEEK 4 ===

-- 16. I Corinthians 15:58
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'therefore'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 15 AND verse = 58;

-- 17. Jeremiah 29:23
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'committed'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 29 AND verse = 23;

-- 18. Hosea 4:7
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'multiplied'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hosea')
  AND chapter = 4 AND verse = 7;

-- 19. Joshua 7:1
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'israelites'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Joshua')
  AND chapter = 7 AND verse = 1;

-- 20. Zephaniah 3:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 4,
  difficulty = 1,
  keyword = 'behold'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Zephaniah')
  AND chapter = 3 AND verse = 19;


-- === WEEK 5 ===

-- 21. Ezra 3:9
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'jeshua'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezra')
  AND chapter = 3 AND verse = 9;

-- 22. I Corinthians 2:1
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'brothers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 2 AND verse = 1;

-- 23. Revelation of John 2:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'deeds—your'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation of John')
  AND chapter = 2 AND verse = 19;

-- 24. Esther 10:3
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'mordecai'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Esther')
  AND chapter = 10 AND verse = 3;

-- 25. Revelation of John 6:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 5,
  difficulty = 2,
  keyword = 'another'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Revelation of John')
  AND chapter = 6 AND verse = 4;


-- === WEEK 6 ===

-- 26. Hosea 14:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'their'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hosea')
  AND chapter = 14 AND verse = 4;

-- 27. I Kings 9:19
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'store'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 9 AND verse = 19;

-- 28. I Corinthians 1:1
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'called'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Corinthians')
  AND chapter = 1 AND verse = 1;

-- 29. Acts 22:13
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'stood'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 22 AND verse = 13;

-- 30. I Chronicles 29:15
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 6,
  difficulty = 2,
  keyword = 'foreigners'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 29 AND verse = 15;


-- === WEEK 7 ===

-- 31. Ezekiel 16:42
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'wrath'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Ezekiel')
  AND chapter = 16 AND verse = 42;

-- 32. II Kings 4:3
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'elisha'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Kings')
  AND chapter = 4 AND verse = 3;

-- 33. I Chronicles 2:32
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'brother'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 2 AND verse = 32;

-- 34. Luke 18:38
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'called'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 18 AND verse = 38;

-- 35. Numbers 27:9
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 7,
  difficulty = 2,
  keyword = 'daughter'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Numbers')
  AND chapter = 27 AND verse = 9;


-- === WEEK 8 ===

-- 36. Exodus 23:5
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'donkey'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 23 AND verse = 5;

-- 37. II Samuel 2:7
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'strong'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 2 AND verse = 7;

-- 38. II Samuel 13:12
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'brother!”'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'II Samuel')
  AND chapter = 13 AND verse = 12;

-- 39. Genesis 26:22
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'moved'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 26 AND verse = 22;

-- 40. Jeremiah 44:8
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 8,
  difficulty = 2,
  keyword = 'provoking'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 44 AND verse = 8;


-- === WEEK 9 ===

-- 41. I Chronicles 24:31
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'their'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Chronicles')
  AND chapter = 24 AND verse = 31;

-- 42. Hebrews 10:24
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'consider'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 10 AND verse = 24;

-- 43. John 15:12
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'commandment'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 15 AND verse = 12;

-- 44. Deuteronomy 24:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'anything'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 24 AND verse = 10;

-- 45. Psalms 74:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 9,
  difficulty = 2,
  keyword = 'enemy'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 74 AND verse = 10;


-- === WEEK 10 ===

-- 46. Isaiah 66:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'jerusalem'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 66 AND verse = 10;

-- 47. I Samuel 2:16
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'burned'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Samuel')
  AND chapter = 2 AND verse = 16;

-- 48. Exodus 4:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'moses'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Exodus')
  AND chapter = 4 AND verse = 18;

-- 49. Psalms 119:104
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'understanding'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 119 AND verse = 104;

-- 50. Romans 14:15
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 10,
  difficulty = 2,
  keyword = 'brother'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 14 AND verse = 15;


-- === WEEK 11 ===

-- 51. Psalms 106:40
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'anger'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 106 AND verse = 40;

-- 52. Isaiah 57:17
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'enraged'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Isaiah')
  AND chapter = 57 AND verse = 17;

-- 53. Esther 1:7
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'beverages'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Esther')
  AND chapter = 1 AND verse = 7;

-- 54. Romans 2:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'glory'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 2 AND verse = 10;

-- 55. Psalms 11:5
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 11,
  difficulty = 2,
  keyword = 'tests'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 11 AND verse = 5;


-- === WEEK 12 ===

-- 56. Proverbs 14:20
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'hated'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Proverbs')
  AND chapter = 14 AND verse = 20;

-- 57. Deuteronomy 32:21
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'provoked'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 32 AND verse = 21;

-- 58. Acts 20:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'after'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 20 AND verse = 2;

-- 59. Song of Solomon 3:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'posts'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Song of Solomon')
  AND chapter = 3 AND verse = 10;

-- 60. John 14:28
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 12,
  difficulty = 2,
  keyword = 'heard'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 14 AND verse = 28;


-- === WEEK 13 ===

-- 61. Deuteronomy 3:18
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'commanded'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 3 AND verse = 18;

-- 62. Deuteronomy 25:1
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'there'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 25 AND verse = 1;

-- 63. Deuteronomy 1:27
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'grumbled'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Deuteronomy')
  AND chapter = 1 AND verse = 27;

-- 64. Galatians 5:13
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'brothers'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Galatians')
  AND chapter = 5 AND verse = 13;

-- 65. I Kings 11:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 13,
  difficulty = 3,
  keyword = 'these'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Kings')
  AND chapter = 11 AND verse = 2;


-- === WEEK 14 ===

-- 66. Jeremiah 2:33
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'skillfully'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Jeremiah')
  AND chapter = 2 AND verse = 33;

-- 67. I Timothy 5:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'known'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Timothy')
  AND chapter = 5 AND verse = 10;

-- 68. Acts 13:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'child'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Acts')
  AND chapter = 13 AND verse = 10;

-- 69. Genesis 43:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'brother'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Genesis')
  AND chapter = 43 AND verse = 4;

-- 70. Titus 1:7
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 14,
  difficulty = 3,
  keyword = 'god’s'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Titus')
  AND chapter = 1 AND verse = 7;


-- === WEEK 15 ===

-- 71. Psalms 23:6
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'surely'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 23 AND verse = 6;

-- 72. Judges 2:12
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'forsook'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Judges')
  AND chapter = 2 AND verse = 12;

-- 73. John 17:23
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'me—that'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 17 AND verse = 23;

-- 74. Hebrews 6:10
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'unjust'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Hebrews')
  AND chapter = 6 AND verse = 10;

-- 75. Luke 14:26
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 15,
  difficulty = 3,
  keyword = 'anyone'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Luke')
  AND chapter = 14 AND verse = 26;


-- === WEEK 16 ===

-- 76. John 15:17
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'command'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'John')
  AND chapter = 15 AND verse = 17;

-- 77. Judges 15:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'thoroughly'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Judges')
  AND chapter = 15 AND verse = 2;

-- 78. Psalms 109:4
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'return'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Psalms')
  AND chapter = 109 AND verse = 4;

-- 79. Lamentations 5:2
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'inheritance'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Lamentations')
  AND chapter = 5 AND verse = 2;

-- 80. Romans 7:15
UPDATE BSB_verses SET
  category = 'anger',
  curriculum_week = 16,
  difficulty = 3,
  keyword = 'understand'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 7 AND verse = 15;

-- ============================================
-- COMPLETE: 400 additional verses generated
-- Total with base: 500 verses
-- ============================================
