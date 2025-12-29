# Brand Replacement Checklist

## Prerequisites
- [ ] Know the old brand name to replace
- [ ] Know the new brand name
- [ ] Have the correct project directory path
- [ ] Ensure you're in a git repository (or initialize one first)

## Step 1: Search for All Instances
- [ ] Use grep to find all instances:
  ```bash
  grep -r "OLD_BRAND_NAME" /path/to/project
  ```
- [ ] Note the count and file locations
- [ ] Or use IDE: Cmd+Shift+F (VS Code/Cursor) to search entire project

## Step 2: Batch Replace (Choose One Method)

### Method A: IDE Find & Replace (FASTEST - Recommended)
- [ ] Open Find & Replace: Cmd+Shift+H (or Edit → Replace in Files)
- [ ] Enter old brand name in "Find" field
- [ ] Enter new brand name in "Replace" field
- [ ] Check "Match Case" if needed
- [ ] Review preview of all changes
- [ ] Click "Replace All" or review each match individually
- [ ] Done! Skip to Step 3

### Method B: Command Line (sed)
- [ ] Make a backup first: `cp -r project project-backup`
- [ ] Run sed command (macOS):
  ```bash
  find /path/to/project -type f -exec sed -i '' 's/OLD_BRAND_NAME/NEW_BRAND_NAME/g' {} +
  ```
- [ ] For Linux, remove the empty quotes: `-i` instead of `-i ''`

## Step 3: Verify All Replacements Complete
- [ ] Search again to confirm zero matches:
  ```bash
  grep -r "OLD_BRAND_NAME" /path/to/project
  ```
- [ ] Should return "No matches found" or empty results

## Step 4: Review Changed Files
- [ ] Check git status:
  ```bash
  git status
  ```
- [ ] Review sample files to verify changes look correct
- [ ] Check translations files (if multiple languages exist)
- [ ] Check documentation files
- [ ] Check email templates

## Step 5: Commit Changes
- [ ] Navigate to correct git repository:
  ```bash
  cd /path/to/project
  ```
- [ ] Stage all changes:
  ```bash
  git add -A
  ```
- [ ] Create commit with detailed message:
  ```bash
  git commit -m "Replace all 'OLD_BRAND' references with 'NEW_BRAND'
  
  - Updated branding across XX files
  - Changed XX instances in components, templates, docs, and i18n
  - Includes SEO metadata, page titles, UI text, and translations
  - Maintains consistency across all user-facing content"
  ```

## Step 6: Push to Remote (if applicable)
- [ ] Push changes:
  ```bash
  git push origin main
  ```

## Common File Types to Check
- [ ] React/Vue components (`.tsx`, `.jsx`, `.vue`)
- [ ] Navigation components
- [ ] Footer/header components
- [ ] Email templates
- [ ] SEO metadata files
- [ ] Translation/i18n files (`en.json`, `es.json`, `fr.json`, `de.json`)
- [ ] Markdown documentation (`.md`)
- [ ] Configuration files (`robots.txt`, `package.json`, etc.)
- [ ] Layout files
- [ ] Modal/dialog components

## Verification Checklist
- [ ] No instances of old brand name remain
- [ ] All modified files committed
- [ ] Application builds successfully (if applicable)
- [ ] No broken links or references
- [ ] Translations updated in all languages

## Pro Tips ⚡
- ✅ **USE YOUR IDE'S FIND & REPLACE** - It's the fastest method
- ✅ Create a branch first: `git checkout -b rebrand-YYYYMMDD`
- ✅ Use case-sensitive search for accuracy
- ✅ Check both frontend AND backend directories
- ✅ Don't forget archive/backup folders if they exist
- ✅ Test build after changes
- ✅ Review git diff before committing: `git diff`

## Quick Reference Commands
```bash
# Find instances
grep -r "OLD_BRAND" .

# Count matches
grep -r "OLD_BRAND" . | wc -l

# Check git status
git status

# View changes
git diff

# Commit with message
git add -A && git commit -m "Replace OLD_BRAND with NEW_BRAND"
```

---

## Example: Recent Brand Replacement
**What we did:** Replaced "NAMOS Launch Kit" with "Hudson Life Dispatch"

**Results:**
- 95 instances replaced across 34 files in frontend
- Files affected: components, email templates, docs, i18n (en, es, fr, de)
- Single commit with clear message
- Zero instances remaining after replacement

**Key Takeaway:** Using IDE's Find & Replace took 30 seconds vs. doing it file-by-file manually!

