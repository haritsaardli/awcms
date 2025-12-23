import React, { useEffect, useRef, useState, useCallback } from 'react';
import { Loader2, AlertCircle } from 'lucide-react';

/**
 * Cloudflare Turnstile CAPTCHA Component
 * 
 * @param {string} siteKey - Turnstile Site Key
 * @param {function} onVerify - Callback when verification succeeds, receives token
 * @param {function} onError - Callback when verification fails
 * @param {function} onExpire - Callback when token expires
 * @param {string} theme - 'light', 'dark', or 'auto'
 * @param {string} size - 'normal' or 'compact'
 */
const Turnstile = ({
    siteKey,
    onVerify,
    onError,
    onExpire,
    theme = 'auto',
    size = 'normal',
    appearance = 'always',
    className = '',
}) => {
    const containerRef = useRef(null);
    const widgetIdRef = useRef(null);
    const [isLoading, setIsLoading] = useState(true);
    const [hasError, setHasError] = useState(false);
    const [scriptLoaded, setScriptLoaded] = useState(false);

    // Load Turnstile script
    useEffect(() => {
        const scriptId = 'turnstile-script';

        // Check if turnstile is already available
        if (window.turnstile) {
            setScriptLoaded(true);
            setIsLoading(false);
            return;
        }

        // Check if script already exists but not yet loaded
        const existingScript = document.getElementById(scriptId);
        if (existingScript) {
            // Wait for it to load
            const checkTurnstile = setInterval(() => {
                if (window.turnstile) {
                    clearInterval(checkTurnstile);
                    setScriptLoaded(true);
                    setIsLoading(false);
                }
            }, 100);

            // Timeout after 10 seconds
            setTimeout(() => {
                clearInterval(checkTurnstile);
                if (!window.turnstile) {
                    console.error('Turnstile script timeout');
                    setIsLoading(false);
                    setHasError(true);
                    onError?.();
                }
            }, 10000);
            return;
        }

        // Create and load new script
        const script = document.createElement('script');
        script.id = scriptId;
        script.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=onTurnstileLoad';
        script.async = true;

        // Global callback for when Turnstile is ready
        window.onTurnstileLoad = () => {
            setScriptLoaded(true);
            setIsLoading(false);
        };

        script.onerror = () => {
            console.error('Failed to load Turnstile script');
            setIsLoading(false);
            setHasError(true);
            onError?.();
        };

        document.head.appendChild(script);

        return () => {
            // Cleanup widget on unmount
            if (widgetIdRef.current && window.turnstile) {
                try {
                    window.turnstile.remove(widgetIdRef.current);
                    widgetIdRef.current = null;
                } catch (e) {
                    console.warn('Turnstile cleanup error:', e);
                }
            }
        };
    }, [onError]);

    // Render widget when script is loaded
    useEffect(() => {
        if (!scriptLoaded || hasError || !containerRef.current || !window.turnstile) {
            return;
        }

        // Remove existing widget if any
        if (widgetIdRef.current !== null) {
            try {
                window.turnstile.remove(widgetIdRef.current);
                widgetIdRef.current = null;
            } catch (e) {
                console.warn('Turnstile remove error:', e);
            }
        }

        // Render new widget
        try {
            widgetIdRef.current = window.turnstile.render(containerRef.current, {
                sitekey: siteKey,
                theme,
                size,
                appearance, // 'always', 'execute', or 'interaction-only' (for invisible mode)
                'retry': 'auto', // Enable automatic retry on failure
                'retry-interval': 2000, // Retry every 2 seconds
                callback: (token) => {
                    console.log('[Turnstile] Verification successful');
                    onVerify?.(token);
                },
                'error-callback': (errorCode) => {
                    console.warn('Turnstile error (may auto-retry):', errorCode);
                    // Only set hasError for critical errors, not transient ones
                    // Transient errors will auto-retry
                    if (errorCode === 'invalid-input-response' || errorCode === 'bad-request') {
                        setHasError(true);
                        onError?.();
                    }
                    // For other errors, let Turnstile handle retry automatically
                },
                'expired-callback': () => {
                    console.log('[Turnstile] Token expired, resetting...');
                    onExpire?.();
                    // Auto-reset on expiration
                    if (widgetIdRef.current !== null && window.turnstile) {
                        window.turnstile.reset(widgetIdRef.current);
                    }
                },
                'timeout-callback': () => {
                    console.warn('[Turnstile] Verification timed out, retrying...');
                    // Auto-reset on timeout
                    if (widgetIdRef.current !== null && window.turnstile) {
                        window.turnstile.reset(widgetIdRef.current);
                    }
                },
            });
        } catch (e) {
            console.error('Turnstile render error:', e);
            setHasError(true);
            onError?.();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [scriptLoaded, hasError, siteKey, theme, size, appearance]);

    // Reset function
    const reset = useCallback(() => {
        if (widgetIdRef.current !== null && window.turnstile) {
            window.turnstile.reset(widgetIdRef.current);
            setHasError(false);
        }
    }, []);

    // Expose reset function via window for external access
    useEffect(() => {
        window.turnstileReset = reset;
        return () => {
            delete window.turnstileReset;
        };
    }, [reset]);

    if (hasError) {
        return (
            <div className={`flex items-center justify-center gap-2 p-4 bg-red-50 border border-red-200 rounded-lg text-red-600 ${className}`}>
                <AlertCircle className="w-5 h-5" />
                <span className="text-sm font-medium">Security check failed. Please refresh the page.</span>
            </div>
        );
    }

    if (isLoading) {
        return (
            <div className={`flex items-center justify-center gap-2 p-4 bg-slate-50 border border-slate-200 rounded-lg text-slate-500 ${className}`}>
                <Loader2 className="w-5 h-5 animate-spin" />
                <span className="text-sm">Loading security check...</span>
            </div>
        );
    }

    return (
        <div className={`turnstile-wrapper ${className}`}>
            <div
                ref={containerRef}
                className="flex items-center justify-center"
            />
        </div>
    );
};

export default Turnstile;
