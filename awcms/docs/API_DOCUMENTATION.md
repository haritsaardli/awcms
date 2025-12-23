
# API Documentation

## Overview

AWCMS uses Supabase as its backend, which automatically generates RESTful APIs from the PostgreSQL database schema using PostgREST.

---

## Base Configuration

```javascript
// Client initialization
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
);
```

---

## Authentication API

### Sign Up

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword'
});
```

### Sign In

```javascript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securepassword'
});
```

### Sign Out

```javascript
const { error } = await supabase.auth.signOut();
```

### Get Current User

```javascript
const { data: { user } } = await supabase.auth.getUser();
```

### Password Reset

```javascript
const { error } = await supabase.auth.resetPasswordForEmail(email, {
  redirectTo: 'https://yourapp.com/reset-password'
});
```

---

## Data API

### Select (Read)

```javascript
// Get all articles
const { data, error } = await supabase
  .from('articles')
  .select('*');

// Get with relations
const { data, error } = await supabase
  .from('articles')
  .select(`
    *,
    author:users(id, full_name, avatar_url),
    category:categories(id, name)
  `);

// Filter
const { data, error } = await supabase
  .from('articles')
  .select('*')
  .eq('status', 'published')
  .is('deleted_at', null)
  .order('created_at', { ascending: false })
  .limit(10);
```

### Insert (Create)

```javascript
const { data, error } = await supabase
  .from('articles')
  .insert({
    title: 'New Article',
    content: '<p>Article content...</p>',
    author_id: userId,
    status: 'draft'
  })
  .select();
```

### Update

```javascript
const { data, error } = await supabase
  .from('articles')
  .update({
    title: 'Updated Title',
    updated_at: new Date().toISOString()
  })
  .eq('id', articleId)
  .select();
```

### Delete (Soft Delete)

```javascript
// AWCMS uses soft delete pattern
const { data, error } = await supabase
  .from('articles')
  .update({ deleted_at: new Date().toISOString() })
  .eq('id', articleId);
```

---

## Storage API

### Upload File

```javascript
const { data, error } = await supabase.storage
  .from('articles')
  .upload(`images/${fileName}`, file, {
    cacheControl: '3600',
    upsert: false
  });
```

### Get Public URL

```javascript
const { data } = supabase.storage
  .from('articles')
  .getPublicUrl('images/example.jpg');
// data.publicUrl
```

### Delete File

```javascript
const { error } = await supabase.storage
  .from('articles')
  .remove(['images/example.jpg']);
```

---

## Realtime API

### Subscribe to Changes

```javascript
const subscription = supabase
  .channel('articles-changes')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'articles' },
    (payload) => {
      console.log('Change received!', payload);
    }
  )
  .subscribe();

// Cleanup
subscription.unsubscribe();
```

---

## Custom Hooks

AWCMS provides custom hooks for common operations:

### useSupabaseQuery

```javascript
import { useSupabaseQuery } from '@/hooks/useSupabase';

function ArticlesList() {
  const { data, loading, error, refetch } = useSupabaseQuery(
    'articles',
    {
      select: '*, author:users(full_name)',
      filter: { status: 'published' },
      order: { column: 'created_at', ascending: false }
    }
  );

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  
  return <ArticleList articles={data} />;
}
```

### useSupabaseMutation

```javascript
import { useSupabaseMutation } from '@/hooks/useSupabase';

function CreateArticle() {
  const { mutate, loading } = useSupabaseMutation('articles', 'insert');

  const handleSubmit = async (formData) => {
    const result = await mutate(formData);
    if (result.success) {
      toast.success('Article created!');
    }
  };

  return <ArticleForm onSubmit={handleSubmit} loading={loading} />;
}
```

---

## Error Handling

```javascript
try {
  const { data, error } = await supabase.from('articles').select('*');
  
  if (error) {
    throw error;
  }
  
  return data;
} catch (error) {
  console.error('Database error:', error.message);
  toast.error('Failed to fetch articles');
}
```

### Common Error Codes

| Code | Meaning |
|------|---------|
| `PGRST116` | No rows returned |
| `23505` | Unique constraint violation |
| `42501` | RLS policy violation |
| `42883` | Function not found |

---

## Rate Limiting

Supabase applies rate limits:

| Plan | Requests/second |
|------|-----------------|
| Free | 500 |
| Pro | 1,000 |

For high-traffic applications, implement caching and debouncing.
