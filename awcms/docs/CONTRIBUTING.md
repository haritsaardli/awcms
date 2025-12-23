
# Contributing Guide

## Welcome

Thank you for your interest in contributing to AWCMS! This guide will help you get started.

---

## Getting Started

### 1. Fork the Repository

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/awcms.git
cd awcms
```

### 2. Set Up Development Environment

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env.local
# Configure your Supabase credentials

# Start development server
npm run dev
```

### 3. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

---

## Development Workflow

### Code Style

- **JavaScript**: ES2022+ syntax
- **React**: Functional components with hooks
- **CSS**: TailwindCSS utilities
- **No TypeScript**: JSDoc for type hints if needed

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `ArticleEditor.jsx` |
| Hooks | camelCase with "use" prefix | `useArticles.js` |
| Utilities | camelCase | `formatDate.js` |
| Pages | PascalCase | `ArticlesPage.jsx` |

### Commit Messages

Follow conventional commits:

```
type(scope): description

feat(articles): add bulk delete functionality
fix(auth): resolve session refresh issue
docs(readme): update installation steps
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## Pull Request Process

### 1. Before Submitting

- [ ] Run `npm run lint` and fix any issues
- [ ] Ensure `npm run build` succeeds
- [ ] Test your changes thoroughly
- [ ] Update documentation if needed

### 2. PR Description

Include:

- **What**: What does this PR do?
- **Why**: Why is this change needed?
- **How**: How was it implemented?
- **Testing**: How was it tested?

### 3. Review Process

1. Submit PR to `main` branch
2. Wait for CI checks to pass
3. Address reviewer feedback
4. Merge after approval

---

## Code Guidelines

### Component Structure

```jsx
// 1. Imports
import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';

// 2. Component definition
function MyComponent({ prop1, prop2 }) {
  // 3. Hooks
  const [state, setState] = useState(null);
  
  // 4. Effects
  useEffect(() => {
    // ...
  }, []);
  
  // 5. Handlers
  const handleClick = () => {
    // ...
  };
  
  // 6. Render
  return (
    <div>
      {/* JSX */}
    </div>
  );
}

// 7. Export
export default MyComponent;
```

### Supabase Queries

```jsx
// Always use try-catch
try {
  const { data, error } = await supabase
    .from('table')
    .select('*');
  
  if (error) throw error;
  return data;
} catch (error) {
  toast.error(error.message);
}
```

### Toast Notifications

All user actions should have feedback:

```jsx
const handleSave = async () => {
  try {
    await saveData();
    toast({ title: "Saved successfully" });
  } catch (error) {
    toast({ 
      variant: "destructive",
      title: "Failed to save",
      description: error.message
    });
  }
};
```

---

## Documentation

When adding features, update relevant docs:

- `README.md` - If it affects overview
- `docs/` folder - For detailed documentation
- JSDoc comments - For complex functions

---

## Testing

Currently, AWCMS relies on manual testing and linting:

```bash
# Lint check
npm run lint

# Build verification
npm run build
```

---

## Community

- **Issues**: Report bugs or request features
- **Discussions**: Ask questions, share ideas
- **Pull Requests**: Submit contributions

---

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
