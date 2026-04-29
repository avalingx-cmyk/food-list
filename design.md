╔═════════════════════════════════════════════════════════════════════════════════════════╗
║  TARGET: FoodList - RECOMMENDED DESIGN SYSTEM                                           ║
╚═════════════════════════════════════════════════════════════════════════════════════════╝
┌─────────────────────────────────────────────────────────────────────────────────────────┐
├─── PATTERN ──────────────────────────────────────────────────────────────────────────────┤
│  Name: App Store Style Landing                                                          │
│     Conversion: Show real screenshots. Include ratings (4.5+ stars). QR code for mobile. Platform-specific CTAs.│
│     CTA: Download buttons prominent (App Store + Play Store) throughout                 │
│     Sections:                                                                           │
│       1. 1. Hero with device mockup, 2. Screenshots carousel, 3. Features with icons, 4. Reviews/ratings, 5. Download CTAs│
├─── STYLE ────────────────────────────────────────────────────────────────────────────────┤
│  Name: Exaggerated Minimalism                                                           │
│     Mode Support: Light ✓ Full  Dark ✓ Full                                             │
│     Keywords: Bold minimalism, oversized typography, high contrast, negative space,     │
│     loud minimal, statement design                                                      │
│     Best For: Fashion, architecture, portfolios, agency landing pages, luxury brands,   │
│     editorial                                                                           │
│     Performance: ⚡ Excellent | Accessibility: ✓ WCAG AA                                 │
├─── COLORS ───────────────────────────────────────────────────────────────────────────────┤
│     Primary:       #0891B2    (--color-primary)                                         │
│     On Primary:    #FFFFFF    (--color-on-primary)                                      │
│     Secondary:     #22D3EE    (--color-secondary)                                       │
│     Accent/CTA:    #059669    (--color-accent)                                          │
│     Background:    #ECFEFF    (--color-background)                                      │
│     Foreground:    #164E63    (--color-foreground)                                      │
│     Muted:         #E8F1F6    (--color-muted)                                           │
│     Border:        #A5F3FC    (--color-border)                                          │
│     Destructive:   #DC2626    (--color-destructive)                                     │
│     Ring:          #0891B2    (--color-ring)                                            │
│     Notes: Calm cyan + health green                                                     │
├─── TYPOGRAPHY ───────────────────────────────────────────────────────────────────────────┤
│  Calistoga / Inter                                                                      │
│     Mood: saas, boutique, electric, warm, editorial, bold, premium, fintech, business,  │
│     dual font, human warmth                                                             │
│     Best For: B2B SaaS mobile, fintech apps, analytics dashboards, marketing tools,     │
│     operations platforms                                                                │
│     Google Fonts: https://fonts.google.com/share?selection.family=Calistoga:ital@0;1|Inter:wght@300;400;500;600;700|JetBrains+Mono:wght@400;500│
│     CSS Import: @import url('https://fonts.googleapis.com/css2?family=Calistoga:ital@0...│
├─── KEY EFFECTS ──────────────────────────────────────────────────────────────────────────┤
│     font-size: clamp(3rem 10vw 12rem), font-weight: 900, letter-spacing: -0.05em,       │
│     massive whitespace                                                                  │
├─── AVOID ────────────────────────────────────────────────────────────────────────────────┤
│     Playful design + Poor security UX + AI purple/pink gradients                        │
├─── PRE-DELIVERY CHECKLIST ───────────────────────────────────────────────────────────────┤
│     [ ] No emojis as icons (use SVG: Heroicons/Lucide)                                  │
│     [ ] cursor-pointer on all clickable elements                                        │
│     [ ] Hover states with smooth transitions (150-300ms)                                │
│     [ ] Light mode: text contrast 4.5:1 minimum                                         │
│     [ ] Focus states visible for keyboard nav                                           │
│     [ ] prefers-reduced-motion respected                                                │
│     [ ] Responsive: 375px, 768px, 1024px, 1440px                                        │
└─────────────────────────────────────────────────────────────────────────────────────────┘