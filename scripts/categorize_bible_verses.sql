-- Script to categorize 500 Bible verses (100 per category)
-- Run this against bible_bsb.db database

-- First, reset all existing categories to start fresh
UPDATE BSB_verses SET category = NULL, curriculum_week = NULL, difficulty = NULL, keyword = NULL;

-- ============================================================================
-- TEMPTATION CATEGORY (100 verses)
-- ============================================================================
-- Keywords: tempt, test, trial, resist, flee, overcome, endure, strength, power, victory

UPDATE BSB_verses SET category = 'temptation', curriculum_week = 1, difficulty = 1, keyword = 'resist'
WHERE id IN (
    SELECT id FROM BSB_verses
    WHERE category IS NULL AND (
        text LIKE '%tempt%' OR
        text LIKE '%test%' OR
        text LIKE '%trial%' OR
        text LIKE '%resist%' OR
        text LIKE '%overcome%' OR
        text LIKE '%endure%' OR
        text LIKE '%strength%' OR
        text LIKE '%victory%' OR
        text LIKE '%flee%' OR
        text LIKE '%deliver%'
    )
    ORDER BY RANDOM()
    LIMIT 100
);

-- ============================================================================
-- LUST CATEGORY (100 verses)
-- ============================================================================
-- Keywords: lust, desire, covet, adultery, pure, purity, heart, eyes, body, flee

UPDATE BSB_verses SET category = 'lust', curriculum_week = 1, difficulty = 1, keyword = 'purity'
WHERE id IN (
    SELECT id FROM BSB_verses
    WHERE category IS NULL AND (
        text LIKE '%lust%' OR
        text LIKE '%adulter%' OR
        text LIKE '%fornic%' OR
        text LIKE '%covet%' OR
        text LIKE '%pure%' OR
        text LIKE '%purity%' OR
        text LIKE '%flee%' OR
        text LIKE '%sexual%' OR
        text LIKE '%desire%' OR
        text LIKE '%body%' OR
        text LIKE '%eyes%' OR
        text LIKE '%heart%'
    )
    ORDER BY RANDOM()
    LIMIT 100
);

-- ============================================================================
-- ANGER CATEGORY (100 verses)
-- ============================================================================
-- Keywords: anger, wrath, rage, furious, gentle, patient, peace, slow, temper, calm

UPDATE BSB_verses SET category = 'anger', curriculum_week = 1, difficulty = 1, keyword = 'peace'
WHERE id IN (
    SELECT id FROM BSB_verses
    WHERE category IS NULL AND (
        text LIKE '%anger%' OR
        text LIKE '%wrath%' OR
        text LIKE '%rage%' OR
        text LIKE '%furious%' OR
        text LIKE '%gentle%' OR
        text LIKE '%patient%' OR
        text LIKE '%peace%' OR
        text LIKE '%slow to anger%' OR
        text LIKE '%temper%' OR
        text LIKE '%calm%'
    )
    ORDER BY RANDOM()
    LIMIT 100
);

-- ============================================================================
-- PRIDE CATEGORY (100 verses)
-- ============================================================================
-- Keywords: pride, proud, humble, humility, arrogant, boast, exalt, lowly, meek

UPDATE BSB_verses SET category = 'pride', curriculum_week = 1, difficulty = 1, keyword = 'humility'
WHERE id IN (
    SELECT id FROM BSB_verses
    WHERE category IS NULL AND (
        text LIKE '%pride%' OR
        text LIKE '%proud%' OR
        text LIKE '%humble%' OR
        text LIKE '%humility%' OR
        text LIKE '%arrogant%' OR
        text LIKE '%boast%' OR
        text LIKE '%exalt%' OR
        text LIKE '%lowly%' OR
        text LIKE '%meek%'
    )
    ORDER BY RANDOM()
    LIMIT 100
);

-- ============================================================================
-- FEAR & ANXIETY CATEGORY (100 verses)
-- ============================================================================
-- Keywords: fear, afraid, anxiety, worry, anxious, peace, trust, faith, courage, comfort

UPDATE BSB_verses SET category = 'fear_anxiety', curriculum_week = 1, difficulty = 1, keyword = 'trust'
WHERE id IN (
    SELECT id FROM BSB_verses
    WHERE category IS NULL AND (
        text LIKE '%fear%' OR
        text LIKE '%afraid%' OR
        text LIKE '%anxiety%' OR
        text LIKE '%anxious%' OR
        text LIKE '%worry%' OR
        text LIKE '%peace%' OR
        text LIKE '%trust%' OR
        text LIKE '%faith%' OR
        text LIKE '%courage%' OR
        text LIKE '%comfort%'
    )
    ORDER BY RANDOM()
    LIMIT 100
);

-- ============================================================================
-- Verify categorization results
-- ============================================================================
SELECT
    category,
    COUNT(*) as verse_count,
    ROUND(AVG(LENGTH(text))) as avg_text_length
FROM BSB_verses
WHERE category IS NOT NULL
GROUP BY category
ORDER BY category;

-- Total count
SELECT COUNT(*) as total_categorized_verses
FROM BSB_verses
WHERE category IS NOT NULL;
