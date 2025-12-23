-- 1. Services Page (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "hero-services",
                "title": "World-Class Digital Services",
                "height": "medium",
                "overlay": true,
                "subtitle": "We provide end-to-end solutions that help your business grow, innovate, and lead in the digital era.",
                "alignment": "center",
                "buttonLink": "#pricing",
                "buttonText": "View Our Plans",
                "backgroundImage": "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2670&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "intro-section",
                "paddingTop": "96px",
                "paddingBottom": "64px",
                "containerWidth": "800px",
                "backgroundColor": "#ffffff"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "features-grid-section",
                "paddingTop": "64px",
                "paddingBottom": "96px",
                "backgroundColor": "#f8fafc"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "pricing-section",
                "paddingTop": "96px",
                "paddingBottom": "96px",
                "backgroundColor": "#ffffff"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "cta-section",
                "paddingTop": "96px",
                "paddingBottom": "96px",
                "backgroundColor": "#0f172a",
                "textColor": "#ffffff"
            }
        }
    ],
    "root": {
        "props": {
            "maxWidth": "full",
            "backgroundColor": "#ffffff"
        }
    },
    "zones": {
        "intro-section:content": [
            {
                "type": "Text",
                "props": {
                    "id": "intro-text",
                    "content": "<h2 style=\"text-align: center; font-size: 2.25rem; font-weight: 700; margin-bottom: 1.5rem;\">Comprehensive Solutions for Every Need</h2><p style=\"text-align: center; font-size: 1.125rem; color: #475569; line-height: 1.8;\">We don''t just build software; we build businesses. From initial consultation to final deployment, our team of experts is dedicated to your success.</p>",
                    "alignment": "center"
                }
            }
        ],
        "features-grid-section:content": [
            {
                "type": "Grid",
                "props": {
                    "id": "services-grid",
                    "gap": 32,
                    "columns": 3
                }
            }
        ],
        "pricing-section:content": [
            {
                "type": "Text",
                "props": {
                    "id": "pricing-header",
                    "content": "<h2 style=\"text-align: center; font-size: 2.25rem; font-weight: 700; margin-bottom: 3rem;\">Transparent Pricing</h2>",
                    "alignment": "center"
                }
            },
            {
                "type": "Pricing",
                "props": {
                    "id": "pricing-table",
                    "items": [
                        { "title": "Startup", "price": "$999", "period": "one-time", "description": "Perfect for small businesses getting started.", "buttonText": "Get Started" },
                        { "title": "Growth", "price": "$2,499", "period": "one-time", "description": "For scaling businesses needing more power.", "isPopular": true, "buttonText": "Most Popular" },
                        { "title": "Enterprise", "price": "Custom", "period": "contact us", "description": "Full-scale solutions for large organizations.", "buttonText": "Contact Sales" }
                    ]
                }
            }
        ],
        "cta-section:content": [
             {
                "type": "Text",
                "props": {
                    "id": "cta-text",
                    "content": "<h2 style=\"text-align: center; font-size: 2.5rem; color: white; margin-bottom: 1.5rem;\">Ready to Transform Your Business?</h2><p style=\"text-align: center; font-size: 1.25rem; color: #94a3b8; margin-bottom: 2rem;\">Let''s discuss your project and see how we can help.</p>",
                    "alignment": "center"
                }
            },
            {
                "type": "Button",
                "props": {
                    "id": "cta-btn",
                    "link": "/contact",
                    "text": "Start a Project",
                    "variant": "primary",
                    "alignment": "center"
                }
            }
        ],
        "services-grid:column-0": [
            {
                "type": "Feature",
                "props": {
                    "id": "feat-1",
                    "icon": "code",
                    "title": "Custom Development",
                    "iconColor": "#3b82f6",
                    "description": "Tailored software solutions built with the latest technologies to meet your specific business requirements."
                }
            },
            {
                "type": "Feature",
                "props": {
                    "id": "feat-4",
                    "icon": "database",
                    "title": "Database Design",
                    "iconColor": "#8b5cf6",
                    "description": "Scalable and secure database architectures ensuring data integrity and fast access speeds."
                }
            }
        ],
        "services-grid:column-1": [
            {
                "type": "Feature",
                "props": {
                    "id": "feat-2",
                    "icon": "smartphone",
                    "title": "Mobile Solutions",
                    "iconColor": "#10b981",
                    "description": "Native and cross-platform mobile applications that provide seamless user experiences on any device."
                }
            },
            {
                "type": "Feature",
                "props": {
                    "id": "feat-5",
                    "icon": "cloud",
                    "title": "Cloud Migration",
                    "iconColor": "#f59e0b",
                    "description": "Expert assistance in moving your infrastructure to the cloud for better flexibility and cost savings."
                }
            }
        ],
        "services-grid:column-2": [
            {
                "type": "Feature",
                "props": {
                    "id": "feat-3",
                    "icon": "layout",
                    "title": "UI/UX Design",
                    "iconColor": "#ec4899",
                    "description": "User-centric design focus creating intuitive and engaging interfaces that users love."
                }
            },
            {
                "type": "Feature",
                "props": {
                    "id": "feat-6",
                    "icon": "shield",
                    "title": "Cybersecurity",
                    "iconColor": "#ef4444",
                    "description": "Protecting your digital assets with advanced security audits, testing, and implementation."
                }
            }
        ]
    }
}'::jsonb
WHERE slug = 'services-page-template';
-- 2. Portfolio/Gallery (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "hero-portfolio",
                "title": "Selected Works",
                "height": "medium",
                "overlay": true,
                "subtitle": "A collection of our finest creations, designing the future one pixel at a time.",
                "alignment": "center",
                "backgroundImage": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=2670&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "gallery-section",
                "paddingTop": "96px",
                "paddingBottom": "96px",
                "backgroundColor": "#ffffff"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "stats-section",
                "paddingTop": "64px",
                "paddingBottom": "64px",
                "backgroundColor": "#f8fafc"
            }
        }
    ],
    "root": {
        "props": {
            "maxWidth": "full",
            "backgroundColor": "#ffffff"
        }
    },
    "zones": {
        "gallery-section:content": [
             {
                "type": "Gallery",
                "props": {
                    "id": "main-gallery",
                    "gap": 16,
                    "images": [
                        "https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=2670&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2670&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1554469384-e58fac16e23a?q=80&w=2574&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2669&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=2670&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=2670&auto=format&fit=crop"
                    ],
                    "columns": 3,
                    "lightbox": true,
                    "aspectRatio": "square",
                    "borderRadius": "md"
                }
            }
        ],
        "stats-section:content": [
            {
                "type": "Stats",
                "props": {
                    "id": "portfolio-stats",
                    "items": [
                        { "icon": "check", "label": "Projects Completed", "value": "150+" },
                        { "icon": "award", "label": "Awards Won", "value": "24" },
                        { "icon": "globe", "label": "Global Clients", "value": "40+" }
                    ]
                }
            }
        ]
    }
}'::jsonb
WHERE slug = 'portfolio-page-template';
-- 3. Contact Page (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "hero-contact",
                "title": "Get in Touch",
                "height": "small",
                "overlay": true,
                "subtitle": "We''d love to hear from you. Here''s how you can reach us...",
                "alignment": "center",
                "backgroundImage": "https://images.unsplash.com/photo-1557426272-fc759fdf7a8d?q=80&w=2670&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "contact-section",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "map-section",
                "paddingTop": "0px",
                "paddingBottom": "0px",
                "containerWidth": "full"
            }
        }
    ],
    "root": { "props": { "maxWidth": "full" } },
    "zones": {
        "contact-section:content": [
            {
                "type": "Grid",
                "props": {
                    "id": "contact-grid",
                    "gap": 64,
                    "columns": 2
                }
            }
        ],
        "map-section:content": [
           {
                "type": "Text",
                "props": {
                    "id": "map-embed",
                    "content": "<div style=\"width: 100%; height: 400px; background: #e2e8f0; border-radius: 0; overflow: hidden; display: flex; align-items: center; justify-content: center;\"><p style=\"color: #64748b;\">[Interactive Map Placeholder - Embed GMusic/Leaflet Here]</p></div>",
                    "alignment": "center"
                }
           }
        ],
        "contact-grid:column-0": [
            {
                "type": "Text",
                "props": {
                    "id": "contact-info",
                    "content": "<h2>Contact Information</h2><p class=\"mb-6\">Feel free to reach out to us with any questions about our services or just to say hello.</p><div style=\"margin-bottom: 24px;\"><h4 style=\"font-weight: bold;\">Headquarters</h4><p>123 Innovation Drive,<br>Silicon Valley, CA 94025</p></div><div style=\"margin-bottom: 24px;\"><h4 style=\"font-weight: bold;\">Phone</h4><p>+1 (555) 123-4567</p></div><div><h4 style=\"font-weight: bold;\">Email</h4><p>contact@awcms.com</p></div>",
                    "alignment": "left"
                }
            }
        ],
        "contact-grid:column-1": [
            {
                "type": "ContactForm",
                "props": {
                    "id": "main-contact-form",
                    "title": "Send us a Message",
                    "variant": "card",
                    "showName": true,
                    "showPhone": true,
                    "buttonText": "Send Message",
                    "showSubject": true,
                    "subtitle": "We usually respond within 24 hours.",
                    "successMessage": "Message sent successfully!"
                }
            }
        ]
    }
}'::jsonb
WHERE slug = 'contact-page-template';
-- 4. Testimonials Page (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "hero-testimonials",
                "title": "Client Success Stories",
                "height": "medium",
                "overlay": true,
                "subtitle": "See what our partners have to say about working with us.",
                "alignment": "center",
                "backgroundImage": "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=2664&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "stats-proof",
                "paddingTop": "64px",
                "paddingBottom": "64px",
                "backgroundColor": "#f8fafc"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "reviews-grid",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        }
    ],
    "root": { "props": { "maxWidth": "full" } },
    "zones": {
        "stats-proof:content": [
            {
                "type": "Stats",
                "props": {
                    "id": "proof-stats",
                    "items": [
                        { "icon": "users", "label": "Happy Clients", "value": "500+" },
                        { "icon": "star", "label": "5-Star Reviews", "value": "150+" },
                        { "icon": "thumbs-up", "label": "Projects Delivered", "value": "1200+" }
                    ]
                }
            }
        ],
        "reviews-grid:content": [
            {
                "type": "Grid",
                "props": {
                    "id": "testimonials-grid",
                    "gap": 32,
                    "columns": 3
                }
            }
        ],
        "testimonials-grid:column-0": [
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-1",
                    "name": "Sarah Miller",
                    "role": "CEO, TechStart",
                    "quote": "The team delivered beyond our expectations. Their attention to detail and commitment to quality is unmatched.",
                    "rating": 5,
                    "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            },
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-4",
                    "name": "Emily Rose",
                    "role": "Marketing Dir.",
                    "quote": "Our conversion rates doubled after the redesign. Highly recommended!",
                    "rating": 5,
                    "avatar": "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            }
        ],
        "testimonials-grid:column-1": [
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-2",
                    "name": "James Smith",
                    "role": "Founder, InnovateInc",
                    "quote": "Truly a professional service. They understood our vision from day one and executed it perfectly.",
                    "rating": 5,
                    "avatar": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            },
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-5",
                    "name": "Michael Brown",
                    "role": "CTO, SoftWarez",
                    "quote": "Technical expertise was top-notch. Secure, fast, and reliable delivery.",
                    "rating": 4,
                    "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            }
        ],
        "testimonials-grid:column-2": [
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-3",
                    "name": "Lisa Wang",
                    "role": "Designer",
                    "quote": "As a designer, I appreciate their clean code and respect for the design fidelity. Beautiful work.",
                    "rating": 5,
                    "avatar": "https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            },
            {
                "type": "Testimonial",
                "props": {
                    "id": "test-6",
                    "name": "David Clark",
                    "role": "Manager",
                    "quote": "Communication was excellent throughout the project. No hidden surprises.",
                    "rating": 5,
                    "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop",
                    "variant": "card"
                }
            }
        ]
    }
}'::jsonb
WHERE slug = 'testimonials-page-template';
-- 5. Landing Page (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "landing-hero",
                "title": "Launch Your Dream Project",
                "height": "large",
                "overlay": true,
                "subtitle": "The most powerful platform to build, manage, and scale your digital presence with ease.",
                "alignment": "left",
                "buttonLink": "/signup",
                "buttonText": "Start Free Trial",
                "backgroundImage": "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2670&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "clients-logo",
                "paddingTop": "48px",
                "paddingBottom": "48px",
                "backgroundColor": "#f8fafc"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "features-landing",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        },
         {
            "type": "Section",
            "props": {
                "id": "video-section",
                "paddingTop": "96px",
                "paddingBottom": "96px",
                "backgroundColor": "#1e293b",
                "textColor": "#ffffff"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "pricing-landing",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "cta-landing",
                "paddingTop": "80px",
                "paddingBottom": "80px",
                "backgroundColor": "#3b82f6",
                "textColor": "#ffffff"
            }
        }
    ],
    "root": { "props": { "maxWidth": "full" } },
    "zones": {
        "clients-logo:content": [
             {
                "type": "Text",
                "props": {
                    "id": "trusted-by",
                    "content": "<p style=\"text-align: center; font-weight: 600; color: #94a3b8; letter-spacing: 0.1em; text-transform: uppercase;\">Trusted by industry leaders</p>",
                    "alignment": "center"
                }
            },
            {
                "type": "Stats",
                "props": {
                    "id": "intro-stats",
                    "items": [
                        { "icon": "download", "label": "Downloads", "value": "2M+" },
                        { "icon": "users", "label": "Active Users", "value": "500k" },
                        { "icon": "globe", "label": "Countries", "value": "120" }
                    ]
                }
            }
        ],
        "features-landing:content": [
            {
                "type": "Text",
                "props": {
                    "id": "feat-head",
                    "content": "<h2 style=\"text-align: center; margin-bottom: 2rem;\">Why Choose Us</h2>",
                    "alignment": "center"
                }
            },
            {
                "type": "Grid",
                "props": {
                    "id": "feat-grid-landing",
                    "gap": 32,
                    "columns": 3
                }
            }
        ],
        "video-section:content": [
            {
                "type": "Text",
                "props": {
                    "id": "video-head",
                    "content": "<h2 style=\"text-align: center; color: white; margin-bottom: 2rem;\">See it in Action</h2>",
                    "alignment": "center"
                }
            },
            {
                "type": "YouTube",
                "props": {
                    "id": "demo-video",
                    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                    "autoplay": false,
                    "aspectRatio": "16/9"
                }
            }
        ],
        "pricing-landing:content": [
            {
                "type": "Pricing",
                "props": {
                    "id": "pricing-grid",
                    "items": [
                        { "title": "Basic", "price": "Free", "period": "forever", "description": "For hobbies", "buttonText": "Sign Up" },
                        { "title": "Pro", "price": "$29", "period": "/mo", "description": "For serious creators", "isPopular": true, "buttonText": "Get Pro" },
                        { "title": "Team", "price": "$99", "period": "/mo", "description": "For agencies", "buttonText": "Contact Sales" }
                    ]
                }
            }
        ],
        "cta-landing:content": [
             {
                "type": "Text",
                "props": {
                    "id": "final-cta-text",
                    "content": "<h2 style=\"text-align: center; color: white; margin-bottom: 1rem;\">Ready to get started?</h2><p style=\"text-align: center; color: rgba(255,255,255,0.9); margin-bottom: 2rem;\">Create your account today and start building.</p>",
                    "alignment": "center"
                }
            },
             {
                "type": "Button",
                "props": {
                    "id": "final-cta-btn",
                    "link": "/signup",
                    "text": "Create Free Account",
                    "variant": "secondary",
                    "alignment": "center"
                }
            }
        ],
        "feat-grid-landing:column-0": [
            { "type": "Feature", "props": { "id": "lf-1", "icon": "zap", "title": "Blazing Fast", "description": "Optimized performance out of the box." } }
        ],
        "feat-grid-landing:column-1": [
            { "type": "Feature", "props": { "id": "lf-2", "icon": "lock", "title": "Secure by Default", "description": "Enterprise-grade security features included." } }
        ],
        "feat-grid-landing:column-2": [
            { "type": "Feature", "props": { "id": "lf-3", "icon": "sliders", "title": "Highly Customizable", "description": "Modify every aspect to fit your brand." } }
        ]
    }
}'::jsonb
WHERE slug = 'landing-page-template';
-- 6. About Page (Fixed JSON Structure)
UPDATE public.templates
SET data = '{
    "content": [
        {
            "type": "Hero",
            "props": {
                "id": "hero-about",
                "title": "About Our Company",
                "height": "medium",
                "overlay": true,
                "subtitle": "Driven by innovation, united by passion.",
                "alignment": "center",
                "backgroundImage": "https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=2670&auto=format&fit=crop"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "story-section",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "values-section",
                "paddingTop": "96px",
                "paddingBottom": "96px",
                "backgroundColor": "#f8fafc"
            }
        },
        {
            "type": "Section",
            "props": {
                "id": "team-section",
                "paddingTop": "96px",
                "paddingBottom": "96px"
            }
        }
    ],
    "root": { "props": { "maxWidth": "full" } },
    "zones": {
        "story-section:content": [
            {
                "type": "Grid",
                "props": {
                    "id": "story-grid",
                    "columns": 2,
                    "gap": 48
                }
            }
        ],
        "values-section:content": [
             {
                "type": "Text",
                "props": {
                    "id": "val-head",
                    "content": "<h2 style=\"text-align: center; margin-bottom: 2rem;\">Our Core Values</h2>",
                    "alignment": "center"
                }
            },
            {
                "type": "Grid",
                "props": {
                    "id": "values-grid",
                    "columns": 3,
                    "gap": 32
                }
            }
        ],
        "team-section:content": [
             {
                "type": "Text",
                "props": {
                    "id": "team-head",
                    "content": "<h2 style=\"text-align: center; margin-bottom: 2rem;\">Meet the Leaders</h2>",
                    "alignment": "center"
                }
            },
            {
                "type": "Grid",
                "props": {
                    "id": "team-grid",
                    "columns": 3,
                    "gap": 32
                }
            }
        ],
        "story-grid:column-0": [
             {
                "type": "Image",
                "props": {
                    "id": "story-img",
                    "src": "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=2670&auto=format&fit=crop",
                    "borderRadius": "lg",
                    "alt": "Office environment"
                }
            }
        ],
        "story-grid:column-1": [
             {
                "type": "Text",
                "props": {
                    "id": "story-text",
                    "content": "<h2>Our Story</h2><p class=\"mb-4\">Founded in 2020, we started with a mission to simplify digital transformation for small businesses. Today, we have grown into a global team helping thousands of companies.</p><p>We believe in transparency, quality, and continuous improvement.</p>",
                    "alignment": "left"
                }
            }
        ],
        "values-grid:column-0": [
            { "type": "Feature", "props": { "id": "val-1", "icon": "heart", "title": "Passion", "description": "We love what we do and it shows in our work." } }
        ],
        "values-grid:column-1": [
             { "type": "Feature", "props": { "id": "val-2", "icon": "users", "title": "Collaboration", "description": "Great things are achieved together." } }
        ],
        "values-grid:column-2": [
             { "type": "Feature", "props": { "id": "val-3", "icon": "star", "title": "Excellence", "description": "We never settle for good enough." } }
        ],
          "team-grid:column-0": [
            { "type": "Card", "props": { "id": "team-1", "title": "Jane Doe", "description": "CEO & Founder", "image": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2670&auto=format&fit=crop" } }
        ],
        "team-grid:column-1": [
             { "type": "Card", "props": { "id": "team-2", "title": "John Smith", "description": "CTO", "image": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=2670&auto=format&fit=crop" } }
        ],
        "team-grid:column-2": [
             { "type": "Card", "props": { "id": "team-3", "title": "Emily White", "description": "VP of Design", "image": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=2688&auto=format&fit=crop" } }
        ]
    }
}'::jsonb
WHERE slug = 'about-page-template';
