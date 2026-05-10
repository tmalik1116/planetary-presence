# Planetary Presence UI Design System & Visual Guidelines

## Overview

Planetary Presence is a gamified travel and exploration app focused on quests, city discovery, and social competition. The UI should feel:

* Clean
* Modern
* Lightweight
* Motivating
* Adventure-oriented
* Minimal but vibrant

The visual style should primarily use a **white + green foundation**, with controlled accent colors for data visualization and category differentiation.

The reference style is:

* Flat UI
* Rounded cards
* Thin borders
* Minimal shadows
* Spacious layouts
* High readability
* iOS-inspired polish
* Soft visual hierarchy

---

# Core Design Philosophy

## Primary Principles

### 1. Green Represents Action & Progress

Green is the core identity color and should be reserved for:

* Primary buttons
* Active navigation states
* Main CTAs
* Selected tabs
* Important metrics
* Progress indicators
* Confirmation/success states

### 2. White/Neutral Base

Most screens should remain:

* Bright
* Open
* Minimal
* White-background dominant

Avoid overwhelming the interface with too many colored surfaces.

### 3. Accent Colors Only Where Meaningful

Non-green colors should appear ONLY in:

* Badges
* Charts
* Quest categories
* Map pins
* Data visualizations
* Achievement rarity
* Activity heatmaps

This creates visual interest without breaking the core identity.

---

# Color Palette

## Primary Brand Colors

### Main Green

```css
#207000
```

### Dark Green

```css
#165200
```

### Light Green

```css
#EAF6E5
```

### Success Green

```css
#2E9B1F
```

---

# Neutral Palette

### Background

```css
#FFFFFF
```

### Secondary Background

```css
#F7F7F7
```

### Card Border

```css
#E5E5E5
```

### Divider

```css
#ECECEC
```

### Primary Text

```css
#111111
```

### Secondary Text

```css
#666666
```

### Tertiary Text

```css
#999999
```

---

# Accent Colors

These should ONLY appear in:

* Charts
* Badges
* Pins
* Category tags
* Rare achievements
* Progress visualizations

## Category Colors

### Nature

```css
#2E9B1F
```

### Food

```css
#FF9800
```

### Culture

```css
#A855F7
```

### Landmark

```css
#2563EB
```

---

# Typography

## Font Style

Use:

* Inter
* SF Pro
* Manrope
* Or similar clean sans-serif

Avoid decorative fonts.

---

## Font Hierarchy

### Large Titles

* Bold
* 28–34px

### Section Headers

* Semibold
* 20–24px

### Card Titles

* Semibold
* 16–18px

### Body Text

* Regular
* 14–16px

### Metadata

* Medium
* 12–13px

---

# Global UI Rules

## Corner Radius

### Cards

```css
20px
```

### Buttons

```css
14px
```

### Pills/Tags

```css
999px
```

---

## Shadows

Very subtle shadows only.

Example:

```css
0 2px 10px rgba(0,0,0,0.04)
```

Avoid:

* Heavy drop shadows
* Skeuomorphic depth
* Neumorphism

---

## Borders

Most cards should use:

```css
1px solid #E5E5E5
```

Prefer borders over shadows.

---

# Navigation

## Bottom Navbar

5 items:

```text
Map | Quests | + | Stats | Profile
```

## Navbar Style

### Background

White

### Active Icon/Text

Green (#207000)

### Inactive

Gray (#777777)

### Center "+" Button

* Circular
* Larger than other nav items
* Filled green
* White icon
* Floating appearance
* Main action emphasis

---

# Screen Guidelines

# 1. Map Screen

## Layout

Large interactive map occupying most of screen.

Bottom floating city card:

* Rounded
* White
* Slight shadow
* Displays:

  * City name
  * Active quests
  * User rank
  * Points
  * CTA button

---

## Pins

Pins CAN use multiple colors:

* Green = standard
* Purple = culture-heavy city
* Orange = food-heavy
* Blue = landmark-heavy

Pins should:

* Be rounded
* Soft-glow or shadow
* Never neon

---

# 2. Quest List Screen

## Quest Cards

Each card contains:

* Thumbnail image
* Quest title
* Category pill
* Location
* Difficulty
* Points
* Distance

---

## Category Pills

Use accent colors:

* Nature = green
* Food = orange
* Culture = purple
* Landmark = blue

Pills should be:

* Small
* Rounded
* Soft background tint
* Minimal

---

## Buttons

Primary buttons remain green only.

Examples:

* Submit Quest
* Start Quest
* Record Completion

---

# 3. Stats Screen

## Top Metric Card

Large green summary card:

* Total points
* Rank
* Trophy icon

Should feel:

* Rewarding
* Motivational
* Clean

---

## Small Stat Cards

White cards with:

* Small colored icon
* Black text
* Minimal style

---

## Charts

Charts SHOULD use multiple colors.

### Activity Heatmap

Green intensity scale only.

### Pie/Donut Charts

Use:

* Green
* Purple
* Orange
* Blue

### Graphs

Can include:

* Green primary line
* Secondary accent lines

---

# 4. Profile Screen

## Header

Should include:

* Profile photo
* Username
* Handle
* Home city

Optional:

* Soft green gradient
* Light green background section

---

## Achievement Badges

Badges SHOULD use multiple colors:

* Bronze
* Silver
* Gold
* Purple
* Blue
* Emerald

Badges are one of the few places where vibrant colors are encouraged.

---

# 5. Add Quest Flow

## Style

Multi-step form:

1. Details
2. Location
3. Review

Minimal and spacious.

---

## Inputs

Style:

* Rounded
* Light borders
* White fill
* Large touch targets

---

## Difficulty Buttons

Can use tinted colors:

* Easy = green
* Medium = yellow/orange
* Hard = red
* Epic = purple

But selected state should still visually align with app style.

---

# 6. Quest Detail Screen

## Hero Image

Large top image with:

* Rounded corners
* Edge-to-edge feel

---

## Information Layout

Use:

* White space
* Dividers
* Clear sections

Sections:

* Description
* Requirements
* Leaderboard
* Completion stats

---

## Main CTA

Always green:

```text
Record Completion
```

---

# Icons

## Style

Use:

* Rounded outlined icons
* Minimal stroke icons
* Lucide or SF Symbols style

Avoid:

* Cartoon icons
* Filled bulky icons
* Material-heavy visuals

---

# Animation Style

Animations should feel:

* Smooth
* Fast
* Light

Examples:

* Card hover lift
* Button press scaling
* Smooth page transitions
* Floating nav button motion

Avoid:

* Bouncy exaggerated animations
* Overly playful motion

---

# Layout & Spacing

## Preferred Spacing System

Use:

```text
4 / 8 / 12 / 16 / 24 / 32
```

Consistent spacing is extremely important.

---

# Visual Tone

The app should feel like:

* A modern fitness/travel app
* Social but not noisy
* Rewarding but not childish
* Competitive but approachable

The user should feel:

* Encouraged to explore
* Motivated to complete quests
* Proud of progress
* Curious about new places

---

# Things to Avoid

## Do NOT use:

* Dark backgrounds as primary theme
* Heavy gradients everywhere
* Neon colors
* Oversaturated UI
* Thick borders
* Complex glassmorphism
* Excessive shadows
* Cluttered layouts
* Dense information stacking

---

# Flutter Implementation Notes

Recommended:

* Rounded reusable card widgets
* Consistent padding constants
* Shared color theme file
* Shared typography styles
* Reusable pill/tag widgets
* Reusable quest card component
* Reusable stat tile component

---

# Final Visual Goal

Planetary Presence should visually feel like a blend of:

* Modern travel app
* Fitness tracking app
* Social exploration platform
* Lightweight game UI

The UI should prioritize:

* Simplicity
* Clarity
* Motivation
* Discoverability
* Reward feedback
* Exploration excitement

Add the following section to the existing design document for dark mode support.

---

# Dark Mode Design Guidelines

## Dark Mode Philosophy

Dark mode should feel:

* Premium
* Clean
* Atmospheric
* Adventure-oriented
* Less harsh at night
* Still lightweight and readable

The app should NOT become:

* Cyberpunk
* Neon-heavy
* Pure black everywhere
* Oversaturated

Dark mode should preserve the same identity as light mode while slightly increasing immersion and map-focused exploration vibes.

---

# Dark Theme Palette

## Primary Background

Instead of pure black, use soft dark surfaces.

### Main Background

```css id="dm1"
#111315
```

### Secondary Background

```css id="dm2"
#181B1F
```

### Elevated Surface / Cards

```css id="dm3"
#1F2328
```

### Input Background

```css id="dm4"
#252A30
```

### Border Color

```css id="dm5"
#2F353D
```

---

# Text Colors (Dark Mode)

### Primary Text

```css id="dm6"
#F5F5F5
```

### Secondary Text

```css id="dm7"
#B0B7C3
```

### Muted Text

```css id="dm8"
#7B8494
```

---

# Green Usage in Dark Mode

Green remains the primary identity color.

However:

* Slightly brighten green for contrast
* Avoid neon saturation

### Primary Green (Dark Mode)

```css id="dm9"
#2E9B1F
```

### Hover/Pressed

```css id="dm10"
#38B825
```

### Soft Green Surface

```css id="dm11"
rgba(46,155,31,0.15)
```

---

# Accent Colors in Dark Mode

Accent colors should become slightly brighter for readability against dark surfaces.

## Nature

```css id="dm12"
#4ADE80
```

## Food

```css id="dm13"
#FFB020
```

## Culture

```css id="dm14"
#C084FC
```

## Landmark

```css id="dm15"
#60A5FA
```

---

# Global Dark Mode Rules

## Avoid Pure Black

Never use:

```css id="dm16"
#000000
```

Pure black removes depth and feels too harsh.

---

## Increase Surface Separation

In dark mode:

* Borders become more important
* Shadows should become softer
* Layering should rely more on brightness differences

Use:

* Slightly lighter cards on darker backgrounds
* Thin borders
* Minimal glow

---

## Shadows in Dark Mode

Use extremely soft shadows:

```css id="dm17"
0 2px 12px rgba(0,0,0,0.25)
```

Avoid:

* Bright glow effects
* Colored shadows

---

# Dark Mode Component Rules

# Navigation Bar

## Background

```css id="dm18"
#181B1F
```

## Active Item

Green

## Inactive Item

Muted gray-blue

## Floating "+" Button

Still green with white icon.

Should remain the strongest visual CTA.

---

# Cards

## Card Background

```css id="dm19"
#1F2328
```

## Border

```css id="dm20"
1px solid #2F353D
```

Cards should feel:

* Soft
* Layered
* Easy to scan

---

# Quest Cards

Quest images should:

* Remain vibrant
* Be slightly elevated visually
* Add life to the darker interface

Category pills should retain their accent colors.

---

# Charts

Charts are one of the main areas where vibrant colors are encouraged in dark mode.

## Activity Heatmap

Use green intensity scaling:

* Low = muted green-gray
* High = vibrant green

## Pie Charts / Graphs

Can use:

* Purple
* Orange
* Blue
* Green

Charts should become a focal point in dark mode.

---

# Maps in Dark Mode

Maps should use a dark map theme:

* Deep grays
* Muted roads
* Soft labels
* Dim water

Pins should remain colorful and readable.

Recommended pin behavior:

* Slight glow
* Bright center
* Soft shadow

---

# Profile Screen

Profile headers can use:

* Dark green tinted surfaces
* Soft gradients
* Low-opacity accent overlays

Badges should pop more strongly in dark mode.

This is one of the few areas where vivid colors are encouraged.

---

# Buttons

## Primary Buttons

Filled green.

## Secondary Buttons

Dark surface with outlined border.

## Disabled Buttons

Muted gray background with muted text.

---

# Inputs

Inputs should use:

```css id="dm21"
background: #252A30;
border: 1px solid #2F353D;
```

Focused state:

* Green border
* Slight green glow

Example:

```css id="dm22"
box-shadow: 0 0 0 3px rgba(46,155,31,0.15)
```

---

# Achievement Badges

Badges should become:

* Slightly more saturated
* Higher contrast
* More visually rewarding

Possible finishes:

* Metallic gold
* Emerald glow
* Purple rarity
* Blue mastery
* Orange legendary

These are intentionally more vibrant than the rest of the UI.

---

# Dark Mode Animation Feel

Dark mode transitions should feel:

* Smooth
* Subtle
* Atmospheric

Good examples:

* Surface fade-ins
* Slight glow on active buttons
* Soft hover elevation

Avoid:

* Flashy color transitions
* Pulsing neon animations

---

# Accessibility Requirements

Dark mode must maintain:

* Strong contrast
* Readable typography
* Clear tap targets
* Non-reliance on color alone

Always ensure:

* Text remains readable over colored surfaces
* Accent colors pass accessibility contrast ratios

---

# Theme Switching

Support:

* Light mode
* Dark mode
* System mode

Theme changes should animate smoothly:

* ~200ms fade
* No harsh flashes

---

# Final Dark Mode Goal

Dark mode should feel like:

* Exploring cities at night
* Premium travel tech
* Calm exploration
* Competitive but immersive

It should preserve:

* Cleanliness
* Simplicity
* Motivation
* Exploration energy

while adding:

* Depth
* Atmosphere
* Focus
* Visual richness without clutter.
