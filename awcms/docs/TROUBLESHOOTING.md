
# Troubleshooting Guide

## Common Issues and Solutions

---

## Installation Issues

### "Cannot find module" Error

**Problem:** Module not found after npm install

**Solution:**

```bash
rm -rf node_modules package-lock.json
npm install
```

### npm WARN EBADENGINE

**Problem:** Node.js version warning

**Solution:**

```bash
# Check Node version
node --version

# Should be 20.x or higher
# If lower, upgrade Node.js
```

---

## Development Issues

### Port Already in Use

**Problem:** Port 3000 is in use

**Solution:**
Vite automatically uses next available port (3001, 3002, etc.)

Or kill the process:

```bash
# Find process
lsof -i :3000

# Kill it
kill -9 <PID>
```

### Hot Module Replacement (HMR) Not Working

**Problem:** Changes don't reflect immediately

**Solutions:**

1. Clear browser cache
2. Restart dev server: `npm run dev`
3. Check for syntax errors in console

---

## Supabase Issues

### Authentication Failed

**Problem:** Login/signup not working

**Checks:**

1. Verify `.env.local` credentials
2. Check Supabase project is active
3. Verify auth settings in Supabase Dashboard
4. Check browser console for errors

### Database Query Errors

**Problem:** PGRST errors

| Error | Meaning | Solution |
|-------|---------|----------|
| PGRST116 | Row not found | Check if record exists |
| 42501 | RLS violation | Check RLS policies |
| 23505 | Unique violation | Duplicate key exists |

### Connection Refused

**Problem:** Cannot connect to Supabase

**Checks:**

1. Internet connection
2. Supabase project status
3. Correct URL in `.env.local`
4. No firewall blocking

---

## Build Issues

### Build Fails

**Problem:** `npm run build` fails

**Solutions:**

1. Check console for specific error
2. Run `npm run lint` to find issues
3. Verify all imports exist
4. Check for TypeScript errors

### Large Bundle Size Warning

**Problem:** Chunk size exceeds limit

**Note:** This is a warning, not an error. The build still succeeds.

**Optimization options:**

1. Dynamic imports for large components
2. Code splitting in vite.config.js
3. Lazy load routes

---

## UI/UX Issues

### Styles Not Applying

**Problem:** Tailwind classes not working

**Solutions:**

1. Restart dev server
2. Clear browser cache
3. Check `src/index.css` has `@import "tailwindcss"`
4. Verify class names are correct
5. TailwindCSS 4.0 uses CSS-based config (no tailwind.config.js needed)

### Toast Not Showing

**Problem:** Toast notifications don't appear

**Check:**

```jsx
// Ensure Toaster is in app root
import { Toaster } from '@/components/ui/toaster';

function App() {
  return (
    <>
      <MainContent />
      <Toaster />
    </>
  );
}
```

---

## Permission Issues

### Access Denied

**Problem:** User can't access certain pages

**Checks:**

1. Verify user role in database
2. Check role_permissions table
3. Verify menu_permissions for that role
4. Clear session and re-login

### Super Admin Can't Access

**Problem:** Super admin blocked

**Solution:**

1. Check user's role assignment in database
2. Verify role name is exactly "super_admin"

---

## Editor Issues

### TipTap Editor Not Loading

**Problem:** Rich text editor shows blank

**Solutions:**

1. Check browser console for errors
2. Verify TipTap dependencies installed
3. Clear browser cache

### Content Not Saving

**Problem:** Editor content doesn't persist

**Checks:**

1. Check onChange handler
2. Verify form submission
3. Check database write permissions

---

## Getting Help

If issues persist:

1. **Check Documentation**: Review relevant docs
2. **GitHub Issues**: Search existing issues
3. **Create Issue**: With reproduction steps
4. **Community**: Ask in discussions

### Information to Include

When reporting issues:

- AWCMS version
- Node.js version
- Browser and version
- Error messages (full)
- Steps to reproduce
- Expected vs actual behavior
