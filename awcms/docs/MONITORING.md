
# Monitoring & Logging

## System Logs
Supabase provides logs for:
-   **Auth**: Sign-ins, failures, password resets.
-   **Database**: Slow queries, connection counts.
-   **API**: Request latency, error rates.

## Application Logs
AWCMS has an internal `ExtensionLogs` component for extension-specific events. Core application errors are logged to the browser console and can be integrated with Sentry or LogRocket.

## Health Check
The `/health` endpoint (if configured via Edge Function) or simple database connectivity check in the dashboard indicates system status.
