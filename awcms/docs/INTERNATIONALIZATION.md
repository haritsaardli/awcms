
# Internationalization (i18n)

## Overview

AWCMS supports multiple languages using i18next. Currently available: English (en) and Indonesian (id).

---

## Configuration

### Setup (`src/i18n.js`)

```javascript
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import en from './locales/en.json';
import id from './locales/id.json';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      id: { translation: id }
    },
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
```

---

## Translation Files

### English (`src/locales/en.json`)

```json
{
  "menu": {
    "home": "Home",
    "articles": "Articles",
    "products": "Products",
    "dashboard": "Dashboard"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "register": "Register"
  },
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "edit": "Edit"
  }
}
```

### Indonesian (`src/locales/id.json`)

```json
{
  "menu": {
    "home": "Beranda",
    "articles": "Artikel",
    "products": "Produk",
    "dashboard": "Dasbor"
  },
  "auth": {
    "login": "Masuk",
    "logout": "Keluar",
    "register": "Daftar"
  },
  "common": {
    "save": "Simpan",
    "cancel": "Batal",
    "delete": "Hapus",
    "edit": "Ubah"
  }
}
```

---

## Usage in Components

### Using the `useTranslation` Hook

```jsx
import { useTranslation } from 'react-i18next';

function MyComponent() {
  const { t, i18n } = useTranslation();

  return (
    <div>
      <h1>{t('menu.home')}</h1>
      <button onClick={() => i18n.changeLanguage('id')}>
        Switch to Indonesian
      </button>
    </div>
  );
}
```

### With Variables

```jsx
// In translation file
{
  "greeting": "Hello, {{name}}!"
}

// In component
<p>{t('greeting', { name: 'John' })}</p>
// Output: "Hello, John!"
```

### Pluralization

```jsx
// In translation file
{
  "items": "{{count}} item",
  "items_plural": "{{count}} items"
}

// In component
<p>{t('items', { count: 5 })}</p>
// Output: "5 items"
```

---

## Language Selector Component

```jsx
// src/components/ui/LanguageSelector.jsx
import { useTranslation } from 'react-i18next';
import { Select } from '@/components/ui/select';

function LanguageSelector() {
  const { i18n } = useTranslation();

  return (
    <Select 
      value={i18n.language} 
      onValueChange={(lang) => i18n.changeLanguage(lang)}
    >
      <SelectItem value="en">English</SelectItem>
      <SelectItem value="id">Indonesia</SelectItem>
    </Select>
  );
}
```

---

## Adding a New Language

### 1. Create Translation File

```bash
# Create new translation file
touch src/locales/fr.json
```

### 2. Add Translations

```json
{
  "menu": {
    "home": "Accueil",
    "articles": "Articles"
  }
}
```

### 3. Register in i18n.js

```javascript
import fr from './locales/fr.json';

i18n.init({
  resources: {
    en: { translation: en },
    id: { translation: id },
    fr: { translation: fr }  // Add new language
  }
});
```

### 4. Update Language Selector

Add the new language option to the LanguageSelector component.

---

## Best Practices

1. **Use Nested Keys**: Organize by feature (`menu.home`, `auth.login`)
2. **Consistent Naming**: Use lowercase snake_case
3. **Fallback Handling**: Always set `fallbackLng`
4. **Dynamic Content**: Use interpolation for variables
5. **Context**: Provide context in key names

---

## Browser Language Detection

i18next automatically detects the browser's language preference and uses it if available.

Priority order:

1. Saved preference (localStorage)
2. Browser language
3. Fallback language (en)
