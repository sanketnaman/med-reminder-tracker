# Medicine Reminder App — Product Requirements Document

**Version:** 1.0
**Product Type:** Mobile Medicine Reminder & Medication Adherence App
**Primary Platform:** Android + iOS
**Recommended Framework:** Flutter
**Design Reference:** Provided Doseza-style screenshots
**Current Scope:** Medicine management, reminders, daily medication plan, inventory and adherence tracking
**Future Scope:** Post-surgery recovery, AI, wearable integration, doctor dashboard

---

# 1. Product Vision

The application will help users manage their daily medicines without forgetting doses.

The core experience should be extremely simple:

> **Add medicine → Set schedule → Get reminder → Take/Snooze → Track progress → Refill before medicine runs out**

The application should feel:

- Clean
- Medical but not intimidating
- Modern
- Elderly-friendly
- Minimal
- Fast
- Easy to understand

The visual language should closely follow the provided references: **soft blue background, rounded cards, blue/cyan primary actions, pill/medicine illustrations, generous spacing and clean typography.**

---

# 2. MVP Goals

The first version should allow a user to:

1. Create an account / continue with basic profile
2. Add medicines
3. Define dosage
4. Set medicine schedule
5. Define before/during/after meal instructions
6. Receive notifications
7. Mark medicine as Taken
8. Snooze a reminder
9. Mark a dose as Missed
10. View today's medication plan
11. View medication history
12. Track medicine inventory
13. Receive low-stock reminders
14. Track medication adherence
15. Edit/delete medicines
16. Manage notification preferences
17. Manage profile/settings

---

# 3. Target Users

## Primary Users

### A. Elderly Patients

Users who take multiple medicines every day.

Requirements:

- Large readable text
- Large buttons
- Simple navigation
- Minimal typing
- Clear notification wording
- High contrast
- Very few steps

### B. Chronic Medication Users

Users taking medicines for:

- Diabetes
- Blood pressure
- Heart conditions
- Thyroid
- Cholesterol
- Other long-term medication

### C. Caregivers / Family Members

Future version can allow a family member to monitor medication adherence.

---

# 4. Navigation Architecture

Bottom navigation should contain four sections:

### Home

Today's medication schedule and adherence.

### Inventory

Medicine stock and refill tracking.

### Progress

Medication adherence and historical performance.

### Profile

User profile and application settings.

Navigation:

```text
Home
 ├── Today's Plan
 ├── Medicine Details
 ├── Add Medicine
 └── Dose History

Inventory
 ├── Medicine List
 ├── Medicine Details
 └── Refill Reminder

Progress
 ├── Weekly
 ├── Monthly
 └── Medicine-wise Performance

Profile
 ├── Personal Information
 ├── Notifications
 ├── Security
 ├── Language
 ├── Subscription
 ├── Privacy
 └── Logout
```

---

# 5. Design System

## 5.1 Primary Color Palette

The application should use a soft healthcare-oriented palette.

### Primary Blue

**#5B8DEF**

Used for:

- Primary buttons
- Progress bars
- Active navigation
- Important actions
- Headers/cards

### Secondary Blue

**#7BA7F7**

Used for:

- Secondary buttons
- Background gradients
- Information cards

### Cyan

**#20C9D8**

Used for:

- Progress indicators
- Success states
- Secondary highlights

### Background

**#F3F6FF**

Main application background.

### Card

**#FFFFFF**

Used for:

- Medicine cards
- Forms
- Dashboard sections

### Primary Text

**#202733**

### Secondary Text

**#718096**

### Success

**#35B779**

### Warning

**#F5A623**

### Error

**#E85D75**

---

# 6. UI Characteristics

All screens should follow these rules:

- 16–24px screen padding
- 14–20px rounded cards
- Soft shadows
- No harsh borders
- Large touch targets
- Minimal icons
- Rounded buttons
- Clean typography
- Light background
- Blue/cyan gradients used sparingly

Recommended typography:

**Inter** or **SF Pro-style equivalent**

Hierarchy:

- Screen title: 24–28px
- Section title: 18–20px
- Medicine name: 16–18px
- Supporting text: 12–14px
- Button: 14–16px

---

# 7. Screen-by-Screen Requirements

# SCREEN 01 — Splash Screen

### Purpose

Introduce the brand while the application initializes.

### UI

Background:

**#F3F6FF**

Center:

Medicine/pill logo illustration.

Logo:

**[App Name]**

Tagline:

> Never miss a dose.

Bottom:

Small loading indicator.

### Behavior

Show for approximately 1–2 seconds.

Then:

- Logged-in user → Home
- New user → Onboarding

---

# SCREEN 02 — Onboarding 1

### Title

**Your daily medication companion**

### Description

> Stay on top of your medicines with timely reminders tailored to your schedule.

### Illustration

Medicine/pills illustration.

### CTA

**Next**

### Secondary

Skip

---

# SCREEN 03 — Onboarding 2

### Title

**Never miss a dose**

Explain:

- Smart reminders
- Snooze
- Taken/Missed tracking

CTA:

**Next**

---

# SCREEN 04 — Onboarding 3

### Title

**Track your medication progress**

Explain:

- Daily adherence
- Weekly progress
- Medicine history
- Refill reminders

CTA:

**Get Started**

---

# SCREEN 05 — Login / Registration

### Login Methods

- Mobile number + OTP
- Email + password
- Google Sign-In (optional)

### Fields

Email/mobile

Password where applicable

### Actions

**Login**

**Create Account**

**Forgot Password**

### Optional

Continue as Guest

Guest users can use local reminders but cloud synchronization will be unavailable.

---

# SCREEN 06 — Basic Profile Setup

After registration:

### Fields

Name

Age

Gender — optional

Timezone

### Optional

Profile photo

### CTA

**Continue**

The timezone is important because medicine reminders must follow the user's local time.

---

# SCREEN 07 — HOME DASHBOARD

This is the most important screen.

The design should closely follow the provided reference.

## Header

Example:

> Good Morning, Nicholas

For actual user:

> Good Morning, Sanket

Right:

Notification icon

---

# Today's Medication Progress Card

Large blue gradient card.

Example:

**Today's Medication Progress**

Total Dose: 5

Taken: 1

Progress:

**15% Complete**

Circular progress indicator.

CTA:

**View Today's Plan**

---

# Date Selector

Horizontal calendar:

```text
S   M   T   W   T   F   S
12  13  14  15  16  17  18
```

Current date should be highlighted with a blue circle/card.

User can swipe between dates.

---

# Medication Timeline

Group medicines by:

### Morning

Example:

**2 Medicines**

Medicine card:

**Metformin**

1 Capsule

7:00 AM

Before Breakfast

Status:

Taken

---

### Afternoon

**Vitamin C**

2:00 PM

After Lunch

Status:

Upcoming

---

### Evening

Medicine cards.

---

### Night

Medicine cards.

---

# Floating/Add Button

Bottom right:

**+ Add Medicine**

---

# SCREEN 08 — TODAY'S PLAN

A dedicated detailed schedule.

Header:

Back button

Title:

**Today's Plan**

Date

---

## Progress Card

Same medication progress card:

Total doses

Taken

Remaining

Completion %

---

## Morning

Example:

**Metformin**

1 Capsule

7:00 AM

Before Breakfast

Buttons:

**Taken**

**Snooze**

---

## Upcoming Dose

Show:

> Upcoming in 35 minutes

This makes the next medicine immediately visible.

---

# SCREEN 09 — MEDICINE REMINDER CARD

Every medication card must clearly show:

- Medicine name
- Dosage
- Scheduled time
- Meal instruction
- Frequency
- Status

### Status Types

#### Upcoming

Blue

#### Taken

Green

#### Missed

Red

#### Snoozed

Orange/yellow

---

# SCREEN 10 — ADD MEDICINE

This is one of the most important forms.

## Header

Back

**Add Medicine**

---

## Medicine Name

Text input:

> Enter medicine name

Optional:

Medicine search/autocomplete.

---

## Medicine Type

Dropdown:

- Tablet
- Capsule
- Syrup
- Injection
- Drops
- Cream
- Powder
- Other

---

## Dosage

Example:

**1**

Unit:

- Tablet
- Capsule
- ml
- Drop
- Spoon
- Other

---

## Quantity / Total Stock

Example:

30 tablets

---

## Start Date

Date picker.

---

## End Date

Date picker.

Option:

**Ongoing**

---

# Schedule

Frequency dropdown:

- Every day
- Specific days
- Every X days
- Once
- Custom

---

# Time

Allow multiple times.

Example:

7:00 AM

2:00 PM

8:00 PM

CTA:

**+ Add Another Time**

---

# Meal Relation

Three segmented options:

**Before Meal**

**During Meal**

**After Meal**

Optional:

**No Meal Relation**

---

# Notes

Optional:

> Take with water

> Do not take on empty stomach

The app should not automatically generate medical instructions unless explicitly entered/verified by the user or clinician.

---

# Medicine Image

Optional:

**Upload Image**

Useful for identifying the medicine visually.

---

# Save Button

Large primary button:

**Save Medicine**

---

# SCREEN 11 — EDIT MEDICINE

Same structure as Add Medicine.

Additional actions:

**Save Changes**

**Delete Medicine**

Delete requires confirmation.

---

# SCREEN 12 — MEDICINE DETAILS

Display:

Medicine image

Medicine name

Dosage

Schedule

Frequency

Start date

End date

Meal relation

Stock remaining

Adherence percentage

---

Actions:

**Edit**

**Refill**

**Delete**

---

# SCREEN 13 — INVENTORY

Bottom navigation → Inventory.

Header:

**Medicine Inventory**

Information banner:

> Get notified before your medicine runs out.

---

## Medicine Cards

Example:

### Amoxicillin

🟢 In Stock

18 Remaining

Button:

**Refill Now**

---

### Metformin

🔴 Low Stock

4 Remaining

Button:

**Refill Now**

---

### Ibuprofen

🔴 Out of Stock

0 Remaining

Button:

**Refill Now**

---

# SCREEN 14 — INVENTORY DETAILS

Display:

Medicine name

Current quantity

Original quantity

Average daily usage

Estimated remaining days

Example:

**4 tablets remaining**

**Estimated 2 days left**

---

## Refill Threshold

Example:

Notify me when:

**5 tablets remain**

---

CTA:

**Refill Reminder**

---

# SCREEN 15 — DOSE CONFIRMATION

When notification is opened:

Display:

> Time to take Metformin

**1 Capsule**

**7:00 AM**

**Before Breakfast**

Large buttons:

### Taken

### Snooze

### Skip

If Skip is selected:

Ask:

> Are you sure you want to mark this dose as skipped?

---

# SCREEN 16 — SNOOZE

Quick options:

- 10 minutes
- 30 minutes
- 1 hour
- Custom time

After selection:

> Reminder snoozed until 7:30 AM.

---

# SCREEN 17 — NOTIFICATION

Notification format:

**Medicine Reminder**

> Time to take Metformin — 1 capsule before breakfast.

Actions:

**Taken**

**Snooze**

Tapping notification opens the dose confirmation screen.

---

# SCREEN 18 — MISSED DOSE

If user doesn't interact with reminder:

Status changes to:

**Missed**

Home dashboard should show:

🔴 1 Missed Dose

User can still manually update the status.

---

# SCREEN 19 — PROGRESS DASHBOARD

Bottom navigation → Progress.

Header:

**Your Progress**

Dropdown:

Weekly / Monthly

---

## Main Progress Card

Example:

**85%**

Medication adherence

28

Total doses

25

Taken

3

Missed

---

# Medication Performance

Each medicine gets its own card.

Example:

### Metformin

12 / 16 doses

**75% Complete**

Progress bar.

---

### Insulin

5 / 6 doses

**90% Complete**

---

### Amoxicillin

18 / 18 doses

**100% Complete**

---

# SCREEN 20 — CALENDAR HISTORY

Calendar view showing adherence.

Example:

🟢 Full adherence

🟡 Partial adherence

🔴 Missed doses

⚪ No medication scheduled

Clicking a date opens:

**Medication History — 13 July**

---

# SCREEN 21 — DOSE HISTORY

Show chronological history.

Example:

### 13 July

7:00 AM

Metformin

Taken at 7:03 AM

---

2:00 PM

Vitamin C

Missed

---

8:00 PM

Omega-3

Taken

---

# SCREEN 22 — NOTIFICATION SETTINGS

Settings:

### Medicine Reminders

ON/OFF

### Missed Dose Reminder

ON/OFF

### Refill Reminder

ON/OFF

### Daily Summary

ON/OFF

### Sound

ON/OFF

### Vibration

ON/OFF

### Notification Tone

Selection

---

# SCREEN 23 — PROFILE

Header:

Profile image

Name

Email/mobile

---

## General

- Edit Profile
- Change Password
- Notifications
- Language

## Preferences

- Subscription
- Legal & Policies
- Privacy
- Terms

## Account

- Logout
- Delete Account

---

# SCREEN 24 — LANGUAGE

Initial supported languages:

- English
- Hindi

Future:

- Bengali
- Tamil
- Telugu
- Marathi
- Gujarati
- Kannada
- Malayalam

---

# SCREEN 25 — EMPTY HOME STATE

For users who haven't added medicine.

Illustration:

Medicine/pill graphic.

Title:

**No medicines added yet**

Description:

> Add your first medicine and we'll remind you when it's time.

CTA:

**+ Add Medicine**

---

# SCREEN 26 — EMPTY INVENTORY

Title:

**Your medicine cabinet is empty**

CTA:

**Add Medicine**

---

# SCREEN 27 — EMPTY PROGRESS

Title:

**Your progress will appear here**

Description:

> Take your medicines regularly to start building your medication history.

---

# 8. Reminder Engine

The reminder system is the heart of the application.

Every medicine schedule should generate reminders.

Example:

Medicine:

Metformin

Schedule:

7:00 AM

Meal:

Before Breakfast

Notification:

> Time to take Metformin — 1 capsule before breakfast.

---

# Reminder States

```text
Scheduled
   ↓
Notification Sent
   ↓
 ┌───────────┬───────────┬──────────┐
 ↓           ↓           ↓
Taken      Snoozed      Skipped
             ↓
          Reminder
             ↓
           Taken
```

If the user never interacts:

**Missed**

---

# 9. Recurring Schedule Engine

Support:

### Daily

Every day at 7:00 AM.

### Specific Days

Monday, Wednesday, Friday.

### Multiple Daily Doses

7 AM

2 PM

8 PM

### Date Range

Start:

01 Aug

End:

30 Aug

### Ongoing

No end date.

---

# 10. Local Notifications

The first MVP should use **local notifications** for medication reminders.

Advantages:

- Works offline
- Reliable
- Low backend dependency
- Immediate scheduling

Backend notifications can be added later for:

- Account sync
- Caregiver alerts
- Doctor dashboard
- Cross-device synchronization

---

# 11. Medication Adherence Calculation

Basic formula:

```text
Adherence % =
Taken Doses / Scheduled Doses × 100
```

Example:

Scheduled = 28

Taken = 25

Adherence = 89.28%

Display:

**89%**

---

# 12. Inventory Calculation

If user enters:

Total stock = 30

Daily dosage = 2

Remaining = 10

Estimated remaining days:

```text
10 / 2 = 5 days
```

The app should show:

> Approximately 5 days remaining.

---

# 13. Refill Reminder

User selects:

**Notify when 5 doses remain**

When inventory reaches threshold:

> Your Metformin supply is running low. Approximately 2 days remaining.

Important:

The MVP should only provide a reminder. It should not automatically recommend or purchase a medicine.

---

# 14. Monetization

The product can use the previously discussed freemium model.

## Free

- Medicine reminders
- Basic medicine management
- Basic history
- Inventory
- Limited progress
- Ads

## ₹99/month

- Ad-free
- Unlimited medicines
- Advanced history
- Advanced progress
- Custom reminder options
- Enhanced inventory tracking

## Future ₹199/month

Reserved for future features:

- Wearable integration
- Recovery monitoring
- AI insights
- Caregiver
- Doctor connectivity

These features should NOT be built into the current MVP.

---

# 15. Advertisement Placement

Ads should never appear:

- Inside a medication notification
- On dose confirmation
- During emergency/important alerts
- Between Taken and Snooze actions
- In a way that can cause accidental clicks

Recommended:

- Home bottom banner
- Inventory bottom banner
- Progress page
- Profile/settings

Premium users:

**No advertisements**

---

# 16. Data Model

Recommended database entities:

## User

```text
id
name
email
phone
password_hash
profile_photo
timezone
language
created_at
updated_at
```

## Medicine

```text
id
user_id
name
type
dosage
dosage_unit
total_quantity
remaining_quantity
start_date
end_date
is_ongoing
meal_relation
notes
image
status
created_at
updated_at
```

## Medicine Schedule

```text
id
medicine_id
time
frequency_type
days_of_week
created_at
updated_at
```

## Dose Record

```text
id
medicine_id
scheduled_at
status
taken_at
snoozed_until
notes
created_at
updated_at
```

Status:

```text
scheduled
taken
missed
skipped
snoozed
```

## Inventory

```text
id
medicine_id
current_quantity
low_stock_threshold
last_refill_date
created_at
updated_at
```

## Notification Settings

```text
id
user_id
medicine_reminder
missed_dose
refill_reminder
daily_summary
sound
vibration
```

---

# 17. Recommended Technical Architecture

## Mobile

**Flutter**

Reason:

- Android + iOS
- Single codebase
- Excellent notification support
- Easy UI consistency
- Future wearable integration possible

---

## State Management

Recommended:

**Riverpod**

Alternative:

**GetX**

Since the application will eventually grow into doctor dashboard, wearable data, AI and synchronization, Riverpod provides a cleaner long-term architecture.

---

## Local Database

For MVP:

**SQLite / Drift**

Store:

- Medicines
- Schedules
- Dose records
- Inventory
- Settings

The application should work even without internet.

---

## Backend

Future-ready backend:

**Laravel**

Responsibilities:

- Authentication
- Cloud synchronization
- User account
- Subscription
- Payment
- Backup
- Analytics
- Future doctor dashboard

---

## Database

**PostgreSQL**

---

## Cloud

Possible:

**AWS**

or

**Cloudflare + managed database**

For MVP, avoid over-engineering infrastructure.

---

# 18. Recommended Flutter Architecture

```text
lib/

├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   ├── notifications/
│   └── utilities/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── medicines/
│   ├── inventory/
│   ├── progress/
│   ├── profile/
│   └── notifications/
│
├── data/
│   ├── models/
│   ├── local/
│   ├── repositories/
│   └── remote/
│
└── main.dart
```

---

# 19. Core Flutter Packages

Potential package categories:

### State

Riverpod

### Local Database

Drift

### Notifications

flutter_local_notifications

### Permissions

permission_handler

### Secure Storage

flutter_secure_storage

### Image

image_picker

### Date/Time

timezone

### Networking

Dio

### Authentication

Firebase Auth or Laravel Sanctum depending on final architecture.

---

# 20. Important UX Rules

The application is intended for medication management, therefore simplicity is more important than visual complexity.

### Rule 1

User should be able to add a medicine in **under 60 seconds**.

### Rule 2

The next medicine should always be visible on Home.

### Rule 3

Taken button should require only **one tap**.

### Rule 4

Snooze should require maximum two taps.

### Rule 5

Missed medicine should be clearly visible.

### Rule 6

Never use confusing medical terminology.

### Rule 7

Use icons + text together.

---

# 21. Accessibility

Because elderly users are an important audience:

- Minimum touch target: approximately 44–48px
- Adjustable font scaling
- High readability
- Avoid tiny secondary text
- Don't rely only on color to indicate status
- Use icons alongside colors
- Support screen readers
- Avoid complex gestures
- Provide confirmation for destructive actions

---

# 22. Security & Privacy

Medication information is sensitive.

Required:

- HTTPS
- Secure authentication
- Secure local storage for sensitive credentials
- Encryption where appropriate
- User data deletion
- Privacy policy
- Account deletion
- Audit logging once backend synchronization is introduced

The application should not claim that a reminder or adherence score is a medical diagnosis.

---

# 23. Important Medical Safety Rules

The MVP is a **medication reminder and tracking tool**, not a medical decision engine.

The application should NOT automatically:

- Change dosage
- Recommend stopping medication
- Recommend doubling a missed dose
- Recommend starting a medicine
- Diagnose disease
- Modify doctor's instructions

If a dose is missed, the app should display something neutral such as:

> You marked this dose as missed. If you're unsure what to do next, follow your prescribed instructions or contact your healthcare professional.

---

# 24. Analytics

Track product usage events such as:

```text
app_opened
medicine_added
medicine_edited
medicine_deleted
reminder_received
dose_taken
dose_snoozed
dose_skipped
dose_missed
inventory_updated
refill_reminder_triggered
progress_viewed
subscription_started
subscription_cancelled
```

Do not collect unnecessary health information purely for analytics.

---

# 25. MVP Success Metrics

Initial targets:

### Activation

% of users who add at least one medicine.

Target:

**>70%**

### Reminder Engagement

% of reminders resulting in user action.

Target:

**>60%**

### Medication Tracking

% of active users recording doses regularly.

Target:

**>50%**

### 30-Day Retention

Target:

**>25–30% initially**

### Premium Conversion

Initial target:

**5–10%**

These are product targets, not guaranteed industry benchmarks.

---

# 26. MVP Development Phases

## Phase 1 — UI Foundation

- Splash
- Onboarding
- Login
- Profile
- Theme
- Navigation

## Phase 2 — Medicine Management

- Add medicine
- Edit medicine
- Delete medicine
- Medicine details
- Schedule

## Phase 3 — Reminder Engine

- Local notifications
- Taken
- Snooze
- Skip
- Missed
- Recurring schedules

## Phase 4 — Inventory

- Stock
- Low stock
- Refill reminder

## Phase 5 — Progress

- Daily adherence
- Weekly adherence
- Monthly history
- Medicine performance

## Phase 6 — Monetization

- Free tier
- Ads
- ₹99 subscription
- Ad removal
- Subscription state

## Phase 7 — Backend

- Account synchronization
- Cloud backup
- Multi-device support

---

# 27. Future Architecture — Do Not Build Yet

The database and code should leave room for:

```text
Medicine Reminder
       ↓
Post-Surgery Recovery
       ↓
Wearable Integration
       ↓
Health Monitoring
       ↓
Caregiver
       ↓
Doctor Dashboard
       ↓
Hospital Platform
```

Future modules may include:

- SpO₂
- Heart rate
- Sleep
- Steps
- Recovery score
- Diet
- Surgery recovery
- Doctor dashboard
- Caregiver
- AI assistant

But **none of these should be part of Version 1.0.**

---

# 28. Final MVP User Journey

```text
Install App
     ↓
Onboarding
     ↓
Create Account
     ↓
Set Profile
     ↓
Home
     ↓
+ Add Medicine
     ↓
Medicine Name
     ↓
Dosage
     ↓
Schedule
     ↓
Meal Relation
     ↓
Stock
     ↓
Save
     ↓
Reminder Scheduled
     ↓
Notification
     ↓
TAKEN / SNOOZE / SKIP
     ↓
Dose History
     ↓
Progress
     ↓
Inventory
     ↓
Refill Reminder
```

---

# 29. Visual Direction Summary

The provided screenshots should be treated as the primary visual inspiration.

### Keep

- Soft blue background
- Rounded cards
- Blue gradient progress cards
- Cyan highlights
- Pill illustrations
- Large medication cards
- Bottom navigation
- Circular progress indicator
- Clean white cards
- Minimal shadows
- Simple icons

### Improve

- Make typography slightly more readable for elderly users
- Increase contrast
- Make Taken/Snooze actions more obvious
- Reduce unnecessary decorative elements
- Keep medicine information visually prioritized
- Make today's next dose immediately obvious
- Use consistent spacing across every screen

---

# 30. Product Positioning

The MVP should not be marketed merely as:

> "A medicine alarm."

It should be positioned as:

> **Your personal medication companion.**

Core promise:

> **Remember every medicine. Track every dose. Stay on schedule.**

The first version should do this one thing exceptionally well before adding AI, surgery recovery, wearables or doctor connectivity.
