-- ============================================
-- Fix Temptation Category Duplicates
-- Replace 5 verses that were duplicated with lust category
-- ============================================

-- Replace I John 2:16 (Week 1) with James 1:13
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 1,
  difficulty = 1,
  keyword = 'tempts'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 1 AND verse = 13;

-- Replace II Timothy 2:22 (Week 2) with Titus 2:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 2,
  keyword = 'self-control'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Titus')
  AND chapter = 2 AND verse = 12;

-- Replace I Peter 2:11 (Week 2) with Romans 6:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 2,
  difficulty = 2,
  keyword = 'reign'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'Romans')
  AND chapter = 6 AND verse = 12;

-- Replace I Corinthians 6:18 (Week 3) with I Thessalonians 5:22
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 3,
  difficulty = 2,
  keyword = 'evil'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'I Thessalonians')
  AND chapter = 5 AND verse = 22;

-- Replace Colossians 3:5 (Week 4) with James 1:12
UPDATE BSB_verses SET
  category = 'temptation',
  curriculum_week = 4,
  difficulty = 3,
  keyword = 'perseveres'
WHERE book_id = (SELECT id FROM BSB_books WHERE name = 'James')
  AND chapter = 1 AND verse = 12;
