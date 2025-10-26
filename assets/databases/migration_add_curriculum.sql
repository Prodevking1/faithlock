-- ============================================
-- FaithLock Bible Database Migration
-- Add curriculum and categorization columns
-- ============================================

-- Add new columns for verse categorization and curriculum
ALTER TABLE BSB_verses ADD COLUMN category TEXT DEFAULT NULL;
ALTER TABLE BSB_verses ADD COLUMN curriculum_week INTEGER DEFAULT NULL; -- 1-4 for structured learning
ALTER TABLE BSB_verses ADD COLUMN difficulty INTEGER DEFAULT NULL; -- 1=easy, 2=medium, 3=hard
ALTER TABLE BSB_verses ADD COLUMN keyword TEXT DEFAULT NULL; -- Pre-calculated word for fill-in-the-blank

-- Create index for category queries (performance optimization)
CREATE INDEX idx_category ON BSB_verses(category) WHERE category IS NOT NULL;
CREATE INDEX idx_curriculum ON BSB_verses(category, curriculum_week) WHERE category IS NOT NULL;

-- ============================================
-- Categories (matching onboarding):
-- - temptation
-- - fear_anxiety
-- - pride
-- - lust
-- - anger
-- ============================================

-- Note: Only ~100 verses will be categorized initially
-- The remaining 31,002 verses stay NULL for future expansion
