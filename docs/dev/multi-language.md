# Multi-Language Development Guide

This guide covers internationalization (i18n) across all AWCMS channels.

## Supported Languages

| Code | Language | Status |
| :--- | :------- | :----- |
| `en` | English | **Primary** (Default) |
| `id` | Indonesian | Secondary |

---

## Channel-Specific Implementation

### awcms (Admin Panel)

**Technology:** React + i18next

**Location:** `awcms/src/locales/`

**Usage:**

```jsx
import { useTranslation } from 'react-i18next';

function Component() {
  const { t } = useTranslation();
  return <h1>{t('common.loading')}</h1>;
}
```

**Key Files:**

- [i18n.js](file:///home/data/dev_react/awcms-dev/awcms/src/lib/i18n.js)
- [en.json](file:///home/data/dev_react/awcms-dev/awcms/src/locales/en.json)
- [id.json](file:///home/data/dev_react/awcms-dev/awcms/src/locales/id.json)

---

### awcms-public (Public Portal)

**Technology:** Astro + TypeScript utility

**Location:** `awcms-public/primary/src/locales/`

**Usage:**

```astro
---
import { t, getLocale } from '../utils/i18n';
const locale = getLocale(Astro.request);
---
<h1>{t('nav.home', locale)}</h1>
```

**Key Files:**

- [i18n.ts](file:///home/data/dev_react/awcms-dev/awcms-public/primary/src/utils/i18n.ts)
- [en.json](file:///home/data/dev_react/awcms-dev/awcms-public/primary/src/locales/en.json)
- [id.json](file:///home/data/dev_react/awcms-dev/awcms-public/primary/src/locales/id.json)

---

### awcms-mobile (Flutter App)

**Technology:** Flutter + intl

**Location:** `awcms-mobile/primary/lib/l10n/`

**Usage:**

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.loading)
```

**Setup in main.dart:**

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
);
```

**Key Files:**

- [l10n.yaml](file:///home/data/dev_react/awcms-dev/awcms-mobile/primary/l10n.yaml)
- [app_en.arb](file:///home/data/dev_react/awcms-dev/awcms-mobile/primary/lib/l10n/app_en.arb)
- [app_id.arb](file:///home/data/dev_react/awcms-dev/awcms-mobile/primary/lib/l10n/app_id.arb)

---

### awcms-esp32 (IoT Firmware)

**Technology:** C++ (Arduino)

**Location:** `awcms-esp32/primary/include/`

**Usage:**

```cpp
#include "config.h"  // Includes the correct language file

Serial.println(STR_DEVICE_READY);
```

**Change Language:**
Edit `config.h`:

```cpp
#define DEVICE_LANGUAGE "id"  // Change from "en" to "id"
```

**Key Files:**

- [config.h](file:///home/data/dev_react/awcms-dev/awcms-esp32/primary/include/config.h)
- [lang_en.h](file:///home/data/dev_react/awcms-dev/awcms-esp32/primary/include/lang_en.h)
- [lang_id.h](file:///home/data/dev_react/awcms-dev/awcms-esp32/primary/include/lang_id.h)

---

## Adding New Translations

### Step 1: Add English Key

Add the key to the English locale file first.

### Step 2: Add Indonesian Translation

Add the same key with Indonesian translation.

### Step 3: Use in Code

Reference the key in your component/code.

---

## Key Naming Conventions

| Pattern | Example | Use Case |
| :------ | :------ | :------- |
| `{namespace}.{key}` | `common.loading` | Shared strings |
| `{module}.{action}` | `auth.login` | Module-specific actions |
| `{module}.form.{field}` | `contact.form.name` | Form labels |

---

## Testing Translations

1. **Admin Panel**: Clear localStorage, reload
2. **Public Portal**: Add `?lang=id` to URL
3. **Mobile**: Change device language settings
4. **ESP32**: Recompile with different `DEVICE_LANGUAGE`
