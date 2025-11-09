# Localization Platform Integration Guide

This guide explains how to integrate the Boz Godot Framework with professional localization platforms for managing translations at scale.

## Table of Contents

1. [Overview](#overview)
2. [When to Use Localization Platforms](#when-to-use-localization-platforms)
3. [Platform Comparison](#platform-comparison)
4. [Weblate Integration](#weblate-integration)
5. [Crowdin Integration](#crowdin-integration)
6. [Lokalise Integration](#lokalise-integration)
7. [General Workflow](#general-workflow)
8. [Automation & CI/CD](#automation--cicd)
9. [Best Practices](#best-practices)

## Overview

The Boz Godot Framework uses gettext PO files (`messages.po` / `messages.pot`), which are the industry-standard format for software localization. All major localization platforms support PO files natively.

**Current Setup:**
- Source language: English
- Translation files: `translations/messages.*.po`
- Template file: `translations/messages.pot`
- Supported languages: en, de, hu, ja

## When to Use Localization Platforms

Consider using a localization platform when you:

- Have **100+ translation keys** to manage
- Work with **multiple translators** or translation agencies
- Need **professional translation memory** and terminology management
- Want **collaborative translation workflows** with review processes
- Require **translation analytics** and progress tracking
- Need **integration with your CI/CD pipeline**
- Want to **crowdsource translations** from community

For smaller projects (<100 keys), direct PO file editing with Poedit may be sufficient.

## Platform Comparison

| Feature | Weblate | Crowdin | Lokalise | Phrase |
|---------|---------|---------|----------|--------|
| **Cost** | Free (open-source) | Free tier + paid | Paid (free trial) | Enterprise pricing |
| **Self-hosted** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **PO Support** | ✅ Native | ✅ Native | ✅ Native | ✅ Native |
| **Git Integration** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Good |
| **Translation Memory** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Machine Translation** | ✅ Multiple engines | ✅ Yes | ✅ Yes | ✅ Yes |
| **Community/Volunteer** | ✅ Excellent | ✅ Good | ⚠️ Limited | ⚠️ Limited |
| **API** | ✅ REST API | ✅ REST API | ✅ REST API | ✅ REST API |
| **Best For** | Open-source, community | Professional teams | Agile teams | Enterprise |

### Recommendation by Project Type

- **Open-source / Community**: **Weblate** (free, self-hosted, excellent for volunteers)
- **Indie / Small Teams**: **Crowdin** (generous free tier, easy setup)
- **Professional Teams**: **Lokalise** or **Phrase** (advanced workflows)
- **Budget-Conscious**: **Weblate** (completely free if self-hosted)

## Weblate Integration

[Weblate](https://weblate.org) is an excellent free and open-source choice.

### Setup Steps

1. **Create Weblate Account**
   - Cloud: https://hosted.weblate.org (free for open-source)
   - Self-hosted: https://docs.weblate.org/en/latest/admin/install.html

2. **Create Project**
   - Add new project: "Boz Godot Framework"
   - Set source language: English

3. **Add Component**
   - Component name: "Game UI"
   - Version control: Link to your Git repository
   - Repository branch: `main`
   - File mask: `translations/messages.*.po`
   - Template: `translations/messages.pot`
   - File format: Gettext PO file

4. **Configure Languages**
   - Add target languages: de, hu, ja
   - Enable automatic suggestions
   - Configure translation memory

5. **Set Up Git Integration**
   - Weblate creates pull requests automatically
   - Or push directly to repository (configure access)
   - Set commit message format

### Workflow with Weblate

```
Developer → Update source strings → Push to Git
         ↓
    Weblate detects changes
         ↓
    Translators work in Weblate UI
         ↓
    Weblate creates PR with translations
         ↓
    Review & merge PR → Godot imports updated PO files
```

### Weblate CLI Integration

```bash
# Install wlc (Weblate command-line client)
pip install wlc

# Configure API key
wlc --config

# Pull latest translations
wlc pull

# Push source strings
wlc push

# Check translation status
wlc show
```

## Crowdin Integration

[Crowdin](https://crowdin.com) offers a professional platform with a generous free tier.

### Setup Steps

1. **Create Crowdin Account**
   - Sign up at https://crowdin.com
   - Free for open-source projects

2. **Create Project**
   - Project type: File-based
   - Source language: English
   - Target languages: de, hu, ja

3. **Upload Files**
   - Upload `translations/messages.pot` as source file
   - Upload existing `.po` files for pre-translation
   - Set file format: Gettext PO

4. **Configure GitHub Integration**
   - Install Crowdin GitHub app
   - Authorize repository access
   - Configure sync settings

5. **Set Up Automation**
   - Enable automatic source file updates
   - Configure pull request creation
   - Set translation approval workflow

### Workflow with Crowdin

```
Developer → Update POT file → Push to Git
         ↓
    Crowdin syncs source strings
         ↓
    Translators work in Crowdin
         ↓
    Crowdin creates PR automatically
         ↓
    CI runs tests on translations
         ↓
    Merge PR → Godot imports updated PO files
```

### Crowdin CLI Integration

```bash
# Install Crowdin CLI
npm install -g @crowdin/cli

# Initialize configuration
crowdin init

# Upload source files
crowdin upload sources

# Download translations
crowdin download

# Check project status
crowdin status
```

## Lokalise Integration

[Lokalise](https://lokalise.com) is a powerful platform for agile teams.

### Setup Steps

1. **Create Lokalise Account**
   - Sign up at https://lokalise.com
   - Free trial available

2. **Create Project**
   - Project name: "Boz Godot Framework"
   - Base language: English
   - Add target languages

3. **Upload Files**
   - Upload POT and PO files
   - Configure file format settings
   - Set key structure

4. **Configure Git Integration**
   - Connect to GitHub/GitLab
   - Set up bidirectional sync
   - Configure branch and file paths

5. **Set Up Workflow**
   - Define translation roles
   - Configure review process
   - Enable translation memory

### Lokalise CLI Integration

```bash
# Install Lokalise CLI
brew install lokalise/cli/lokalise2

# Upload files
lokalise2 file upload \
    --file translations/messages.pot \
    --lang-iso en \
    --replace-modified

# Download translations
lokalise2 file download \
    --format po \
    --dest translations/

# Check project status
lokalise2 project list
```

## General Workflow

Regardless of platform, follow this general workflow:

### 1. Extract Source Strings

When you add new translatable text to your game:

**In scenes:**
```gdscript
# Old approach (before migration):
text = "BUTTON_NEW_FEATURE"

# New approach (after migration):
text = "New Feature"
```

**In scripts:**
```gdscript
# Add new translation call
print(tr("New feature activated!"))
```

### 2. Update POT File

Manually add the new string to `translations/messages.pot`:

```po
#: New feature button
msgid "New Feature"
msgstr ""

#: Status message for new feature
msgid "New feature activated!"
msgstr ""
```

**Note:** Godot does not auto-extract strings to POT files. You must update manually or use external tools (see Automation section).

### 3. Sync to Platform

Push changes to Git, or manually upload POT file to your localization platform.

### 4. Translate

Translators work in the platform UI to translate new strings.

### 5. Download Translations

Platform creates PR with updated PO files, or you download manually.

### 6. Test in Godot

Godot automatically imports PO files and generates `.translation` binaries. Test translations in-game.

## Automation & CI/CD

### GitHub Actions Example

Create `.github/workflows/translations.yml`:

```yaml
name: Sync Translations

on:
  push:
    paths:
      - 'translations/messages.pot'
  pull_request:
    paths:
      - 'translations/messages.*.po'

jobs:
  sync-to-crowdin:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      - name: Upload to Crowdin
        uses: crowdin/github-action@v1
        with:
          upload_sources: true
          upload_translations: false
        env:
          CROWDIN_PROJECT_ID: ${{ secrets.CROWDIN_PROJECT_ID }}
          CROWDIN_PERSONAL_TOKEN: ${{ secrets.CROWDIN_PERSONAL_TOKEN }}

  validate-translations:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
      - name: Validate PO files
        run: |
          sudo apt-get install -y gettext
          for file in translations/messages.*.po; do
            msgfmt -c -v -o /dev/null "$file"
          done
      - name: Run Godot tests
        uses: croconut/godot-tester@v1
        with:
          version: '4.5'
          test-dir: 'tests/'
```

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Validate PO files before commit
for file in translations/messages.*.po; do
    if ! msgfmt -c -o /dev/null "$file" 2>/dev/null; then
        echo "Error: Invalid PO file: $file"
        exit 1
    fi
done

echo "✓ All PO files valid"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

### POT Generation Scripts

Since Godot doesn't auto-extract strings, you can create helper scripts:

**Option 1: Manual Template**
Keep a documented list of all strings in `translations/STRING_LIST.md` and update POT manually.

**Option 2: Python Script**
Create `scripts/extract_strings.py`:

```python
#!/usr/bin/env python3
import re
import sys
from pathlib import Path

def extract_tr_calls(filepath):
    """Extract tr() calls from GDScript files"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    # Match tr("string") and tr('string')
    pattern = r'tr\(["\']([^"\']+)["\']\)'
    return re.findall(pattern, content)

def extract_scene_text(filepath):
    """Extract text properties from .tscn files"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    # Match text = "string"
    pattern = r'text = "([^"]+)"'
    return re.findall(pattern, content)

def main():
    strings = set()

    # Extract from scripts
    for script in Path('scripts').rglob('*.gd'):
        strings.update(extract_tr_calls(script))

    # Extract from scenes
    for scene in Path('scenes').rglob('*.tscn'):
        strings.update(extract_scene_text(scene))

    # Generate POT file
    with open('translations/messages.pot', 'w', encoding='utf-8') as f:
        f.write('# GENERATED POT FILE\n')
        f.write('msgid ""\nmsgstr ""\n\n')
        for string in sorted(strings):
            f.write(f'msgid "{string}"\n')
            f.write(f'msgstr ""\n\n')

    print(f"✓ Extracted {len(strings)} strings to messages.pot")

if __name__ == '__main__':
    main()
```

Run manually when adding new strings:
```bash
python scripts/extract_strings.py
```

## Best Practices

### 1. Source String Guidelines

- **Use complete sentences**: "Save file" not "Save" + "file"
- **Include punctuation**: "Are you sure?" not "Are you sure"
- **Avoid concatenation**: Bad: `tr("Hello") + " " + name`
- **Use placeholders**: Good: `tr("Hello, %s!") % name`
- **Be descriptive**: "Game saved successfully" not "Success"

### 2. Context for Translators

Add comments to PO files to provide context:

```po
#. This button saves the game progress to disk
msgid "Save"
msgstr ""

#. This label shows the player's current level
msgid "Level"
msgstr ""
```

### 3. Plural Forms

Use proper plural forms for languages with complex plural rules:

```po
msgid "1 item"
msgid_plural "%d items"
msgstr[0] "1 předmět"
msgstr[1] "%d předměty"
msgstr[2] "%d předmětů"
```

In GDScript:
```gdscript
# Note: Godot's tr() doesn't support ngettext yet
# Use conditional formatting as workaround
var count = 5
var text = tr("%d items") % count if count != 1 else tr("1 item")
```

### 4. Translation Memory

- Enable translation memory in your platform
- Reuse existing translations for similar strings
- Maintain a glossary for consistent terminology

### 5. Review Process

- Set up review workflow: Translator → Reviewer → Approved
- Never merge unreviewed translations to main
- Test translations in-game before releasing

### 6. Version Control

- **Commit PO files**: Always commit translations to Git
- **Separate PRs**: One PR per language or feature
- **Descriptive commits**: "Add German translations for settings menu"

### 7. Testing Translations

Always test translations in-game:

```bash
# Run tests with specific language
LANGUAGE=de docker-compose run --rm test

# Or test manually in Godot editor
# Settings > Internationalization > Override locale: de
```

### 8. Handling Machine Translation

- Use MT for initial drafts only
- Always have human review of MT output
- Mark MT strings as "fuzzy" in PO files
- Consider MT quality by language pair

## Common Issues & Solutions

### Issue: POT file not syncing to platform

**Solution**: Check that your platform is watching the correct branch and file path. Manually trigger sync if needed.

### Issue: Translations not appearing in-game

**Solution**:
1. Verify PO files are in `translations/` directory
2. Check `project.godot` has correct paths
3. Reimport project in Godot editor (Project > Reimport All)
4. Verify language code matches (`en`, `de`, not `en_US`, `de_DE`)

### Issue: Special characters broken

**Solution**: Ensure all PO files use UTF-8 encoding:
```bash
file -bi translations/messages.de.po
# Should show: charset=utf-8
```

### Issue: Merge conflicts in PO files

**Solution**: Use PO-specific merge tools:
```bash
# Install gettext tools
sudo apt-get install gettext

# Merge PO files intelligently
msgcat --use-first theirs.po ours.po -o merged.po
```

## Resources

- **Godot Localization Docs**: https://docs.godotengine.org/en/stable/tutorials/i18n/
- **Gettext Manual**: https://www.gnu.org/software/gettext/manual/
- **Weblate Documentation**: https://docs.weblate.org/
- **Crowdin Documentation**: https://support.crowdin.com/
- **Lokalise Documentation**: https://docs.lokalise.com/
- **PO File Format**: https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html

## Summary

Integrating a localization platform scales your translation workflow from manual editing to professional translation management. Start with:

1. Choose a platform based on your project size and budget
2. Connect your Git repository
3. Upload POT and PO files
4. Invite translators or enable community contributions
5. Set up automation to sync translations
6. Test thoroughly before releasing

The Boz Godot Framework's gettext-based system is compatible with all major platforms, giving you flexibility to choose the best solution for your needs.
