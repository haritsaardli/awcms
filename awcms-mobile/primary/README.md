# Primary Tenant Configuration

This folder contains tenant-specific configuration for the **primary** tenant.

## Environment

Copy `.env.example` to `.env.primary` and configure:

```env
TENANT_CODE=primary
TENANT_DOMAIN=primarymobile.ahliweb.com
API_BASE_URL=https://imveukxxtdwjgwsafwfl.supabase.co
```

## Build

```bash
# Development
flutter run --dart-define=TENANT=primary

# Production
flutter build apk --dart-define=TENANT=primary
```

## API Configuration

The mobile app uses the `tenant_channels` table for domain resolution:

- Channel: `mobile`
- Domain: `primarymobile.ahliweb.com`
- Base Path: `/awcms-mobile/primary/`
