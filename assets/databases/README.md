# FaithLock Bible Curriculum Database

## Overview

The FaithLock app uses a curated curriculum of ~280 Bible verses across 5 categories to help users overcome specific spiritual challenges.

## Database Structure

### BSB_verses Table
- **31,102 total verses** from Berean Study Bible (BSB) translation
- **279 categorized verses** for the curriculum
- Columns: `id`, `book_id`, `chapter`, `verse`, `text`, `category`, `curriculum_week`, `difficulty`, `keyword`

### BSB_books Table
- 66 books of the Bible
- Columns: `id`, `name`

## Curriculum Categories

### 1. Temptation (54 verses)
Overcoming temptation, resisting sin, walking in the Spirit
- **Weeks 1-4**: Foundation (escaping, resisting, God's way out)
- **Weeks 5-8**: Victory through Christ, spiritual warfare, mind renewal
- **Weeks 9-12**: Perseverance, God's Word as weapon, final victory

### 2. Fear & Anxiety (57 verses)
Conquering fear, trusting God, finding peace
- **Weeks 1-4**: Foundation (God's presence, trust, peace)
- **Weeks 5-8**: Perfect love casts out fear, rest in God, His care
- **Weeks 9-12**: Strength in weakness, God as refuge, eternal perspective

### 3. Pride (56 verses)
Cultivating humility, defeating pride, servant leadership
- **Weeks 1-4**: Foundation (humility, God opposes proud, exaltation)
- **Weeks 5-8**: Christ's example, wisdom, boasting in the Lord, grace
- **Weeks 9-12**: Servant leadership, dangers of pride, putting others first

### 4. Lust (56 verses)
Maintaining purity, self-control, honoring God with body
- **Weeks 1-4**: Foundation (purity, fleeing immorality, guarding heart)
- **Weeks 5-8**: Temple of Holy Spirit, fleeing, mind/heart guard, marriage honor
- **Weeks 9-12**: Self-control, transformation, living sacrifices, victory

### 5. Anger (56 verses)
Managing anger, practicing patience, forgiveness
- **Weeks 1-4**: Foundation (slow to anger, gentle answer, self-control)
- **Weeks 5-8**: Forgiveness, gentleness, patience, peacemaking
- **Weeks 9-12**: Love enemies, controlling tongue, God's mercy, final peace

## Difficulty Progression

- **Level 1** (Easy): Encouraging, clear promises, short verses (Weeks 1-4)
- **Level 2** (Medium): Practical application, deeper theology (Weeks 5-10)
- **Level 3** (Hard): Complex, theological depth, requires reflection (Weeks 11-12)

## Files

### seed_curriculum.sql
Base curriculum with 100 carefully selected "power verses"
- 20 verses per category
- 4 weeks of content
- Foundation for the entire curriculum

### seed_curriculum_200_additional.sql
Extension with 200 additional verses
- 40 verses per category
- Weeks 5-12 content
- Manually curated for relevance and spiritual impact

### bible_bsb.db
SQLite database containing:
- Complete BSB translation (31,102 verses)
- Categorized curriculum verses
- Book metadata

## Setup Instructions

1. **Initial Setup**: Run `seed_curriculum.sql` first
   ```bash
   sqlite3 bible_bsb.db < seed_curriculum.sql
   ```

2. **Extension**: Run `seed_curriculum_200_additional.sql` second
   ```bash
   sqlite3 bible_bsb.db < seed_curriculum_200_additional.sql
   ```

3. **Verification**: Check verse counts
   ```bash
   sqlite3 bible_bsb.db "SELECT category, COUNT(*) FROM BSB_verses WHERE category IS NOT NULL GROUP BY category"
   ```

Expected output:
```
anger|56
fear_anxiety|57
lust|56
pride|56
temptation|54
```

## Verse Selection Strategy

Each verse was manually selected based on:
1. **Relevance**: Direct connection to category theme
2. **Impact**: Spiritually powerful and transformative
3. **Variety**: Diverse books (Old + New Testament)
4. **Memorability**: Suitable for meditation and memorization
5. **Progression**: Builds understanding week by week

## Usage in App

The app loads categorized verses and selects them based on:
- User's selected categories during onboarding
- Current curriculum week (1-12)
- User's difficulty preference (adaptive learning)
- Time of day and context
- Previous verse exposure (to avoid repetition)

## Maintenance

To add more verses:
1. Identify gaps in coverage
2. Select theologically sound, relevant verses
3. Assign appropriate week (1-12) and difficulty (1-3)
4. Choose meaningful keyword for quick reference
5. Test SQL updates against bible_bsb.db
6. Update this README with new verse count

## Translation

Currently using **Berean Study Bible (BSB)**:
- Modern, readable English
- Free for non-commercial use
- Includes study notes and cross-references
- Conservative translation philosophy

## Future Enhancements

- [ ] Expand to 500 verses (100 per category, 20 weeks)
- [ ] Add more categories (greed, envy, laziness, doubt)
- [ ] Multiple translations (NIV, ESV, KJV options)
- [ ] User-submitted verse suggestions
- [ ] AI-powered verse relevance scoring
- [ ] Cross-references and related verses
- [ ] Audio recordings for each verse

## License

- **BSB Translation**: Free for non-commercial use
- **Curriculum Structure**: Proprietary to FaithLock
- **Database Schema**: MIT License

## Contact

For questions about the curriculum or to suggest verses:
- Email: support@faithlock.app
- Repository: github.com/faithlock/curriculum

---

Last Updated: January 2025
Total Verses: 279
Categories: 5
Weeks: 12
