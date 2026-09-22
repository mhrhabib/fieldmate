# Fieldmate — Field Service SaaS for Niche Home Service Businesses

This project is designed around a practical idea: build a field-service platform for a specific service niche instead of trying to compete with large generic platforms like Jobber or Housecall Pro.

The product direction is to serve small-to-medium service businesses with a focused, easy-to-use, mobile-first workflow. The strongest starting niche is appliance repair, with pet grooming as a second option for a parallel MVP.

This repo is already structured to support that direction:

- Astro frontend for the public website, SEO landing page, and customer booking flow
- FastAPI backend for business logic, scheduling, jobs, customers, invoices, and API services
- Flutter web/mobile path for the internal business app, so the product can later become a true mobile-first tool for technicians and dispatch teams

---

## 1. Product vision

Fieldmate is not a broad “all-in-one business management suite.”

It is a focused field service system built for businesses that:

- do in-home or on-site work
- need a fast booking flow
- need job history and customer records
- need status tracking and invoice generation
- struggle with messy spreadsheets, WhatsApp notes, and manual scheduling
- need a system that feels simple enough for a small business owner to use without training

This keeps the product narrow and saleable, while still being valuable enough to charge monthly subscriptions.

---

## 2. Why this direction is better than a Jobber clone

The generic market is crowded. The real opportunity is not to build a bigger version of Jobber. It is to build a better tool for a narrower audience.

The stronger wedge is domain depth, not feature count.

Examples:

- Appliance repair businesses need native fields for brand, model, serial number, symptom, and warranty status
- Pet grooming businesses need pet profiles, breed, temperament notes, and recurring rebooking flows
- Service businesses often do not need a giant ERP — they need a simple workflow that helps them complete jobs faster

This makes the product easier to sell, easier to explain, and far more differentiated.

---

## 3. Target customers

### Primary target: appliance repair shops

Ideal customer profile:

- 1–10 technicians
- local service area
- mostly repeat customers and repair jobs
- often working from spreadsheets or basic CRM tools
- frustrated with generic tools that do not match their workflow

### Secondary target: pet grooming businesses

Ideal customer profile:

- solo or small mobile groomer
- recurring appointments
- recurring booking patterns
- strong need for reminders, pet notes, and repeat scheduling

### Why these niches work

- clear pain points
- easier outbound and marketing
- narrow enough to become the obvious product for a specific audience
- specific features can be built without a huge ERP layer

---

## 4. Core product idea

Fieldmate should be a hybrid system with two main experiences:

### A. Customer-facing booking website

This is the public side of the product.

Features:

- service catalog with categories and pricing
- local search or category-based filtering
- booking form with date and time slot selection
- customer details capture
- service eligibility and local availability
- confirmation page with booking summary
- ability to see booking status later

This part is best suited to Astro because it is SEO-friendly, fast, and ideal for marketing pages and content-heavy landing pages.

### B. Business dashboard / internal operations

This is the internal operations layer.

Features:

- customer records
- job list
- status pipeline
- job assignment and technician view
- invoice generation
- parts waiting workflow
- callback/return visit tracking
- recurring appointment logic
- reminders and notifications

This part can start as a web app and later be extended into Flutter mobile/desktop apps or a PWA.

---

## 5. MVP feature set for appliance repair

This is the narrow MVP that best fits the project direction.

### Customer and job model

- Customer
  - name
  - phone
  - email
  - address
  - notes

- Job
  - appliance type
  - brand
  - model number
  - serial number
  - symptom or issue description
  - status
  - scheduled date/time
  - technician
  - customer
  - part required flag
  - warranty info
  - callback note

### Job statuses

A real status pipeline is essential:

- New
- Scheduled
- En route
- In progress
- Waiting on part
- Completed
- Callback
- Invoiced
- Paid

The key concept is `waiting_on_part` as a first-class status, not just a generic note or a custom label.

### Features that matter most

1. Native fields for appliance details
   - brand
   - model number
   - serial number
   - symptom
   - warranty data

2. Waiting on part flow
   - indicates a job is paused due to a missing part
   - stores ETA or notes
   - allows easier follow-up

3. Callback tracking
   - link return visits to the original job
   - helps measure first-time-fix rate

4. Photo capture
   - before/after job photos
   - serial tag or nameplate photo
   - warranty documentation

5. Invoice generation
   - labor fee
   - parts fee
   - taxes
   - payment status

6. Simple scheduler
   - list view of jobs by day
   - simple appointment booking
   - no complex route optimization needed at the beginning

---

## 6. MVP feature set for pet grooming

As a second niche, pet grooming follows a similar pattern.

### Customer and pet model

- Client
- Pet profile
  - name
  - age
  - breed
  - size
  - temperament notes
  - vaccination status
  - special instructions

### Core features

- recurring booking and rebooking suggestions
- pet-specific notes
- service packages and add-ons
- reminder SMS/email
- before/after photos
- invoice generation
- vaccination expiry tracking

This is a valid alternative if appliance repair feels too technical or too operationally complex.

---

## 7. Best stack for this app

### Frontend marketing site

- Astro
- Tailwind CSS
- static pages or SSG for SEO
- clean landing page and booking funnel

Why Astro:

- fast page loads
- SEO-friendly output
- good for marketing and public content pages
- works well with static/dynamic hybrids

### Backend API

- FastAPI
- PostgreSQL preferred for production
- SQLModel or SQLAlchemy for models
- Pydantic for schema validation

Why FastAPI:

- excellent API documentation via Swagger/OpenAPI
- fast development
- easy to integrate with Flutter or web frontends
- strong fit for a small business SaaS backend

### Internal business app

- Flutter Web first
- later Android/iOS app if needed

Why Flutter Web:

- same codebase can become a PWA or mobile app later
- better fit for a technician-first workflow than a heavy React app for a login-only dashboard
- you already have a Flutter background and can reuse your existing patterns

### Auth and cloud services

- Firebase Auth or custom JWT auth
- PostgreSQL for primary data
- Firebase Storage or Cloudflare R2 for photos
- Stripe for payments and subscriptions
- Twilio or email/SMS notifications

---

## 8. Recommended architecture

This project should follow a clean separation:

- `frontend/` = marketing + public website + customer booking experience
- `backend/` = FastAPI API + business rules + database access
- `frontend_flutter/` = optional internal app for technicians or dashboard users

The architecture should stay modular so each layer remains independent.

### Example flow

1. Customer visits public site
2. Customer browses services and books appointment
3. Frontend sends request to FastAPI API
4. FastAPI creates customer and job record
5. Job is assigned or scheduled on the business dashboard
6. Business owner sees job details in internal dashboard
7. Technician updates status as job progresses
8. Invoice is generated and linked to the job
9. Payment is processed through Stripe

---

## 9. UX and product philosophy

The product should feel simple and practical.

It should not feel like a giant enterprise ERP.

The user experience should be built around these principles:

- fast onboarding
- very little configuration required
- field-friendly mobile experience
- minimal jargon
- clear status tracking
- easy invoicing
- reliable reminders

A good field service product feels like the business owner’s operating system, not a generic admin panel.

---

## 10. Monetization strategy

### Recommended pricing model

Use monthly SaaS subscriptions, not one-time sales.

Why:

- ongoing hosting and support costs
- recurring software value
- buyer expectations in this market
- easier to reach $5k/month with smaller customer counts

### Starting pricing idea

- Starter: $29–$39/month
- Pro: $59–$99/month
- Team/dispatch: custom pricing

Keep pricing simple at first.

No per-user fees initially if the tool is meant for small businesses.

---

## 11. Suggested roadmap

### Phase 1: public website + booking demo

- landing page
- service listing
- booking form
- confirmation page
- simple customer booking flow

### Phase 2: internal business dashboard

- login and auth
- job list
- job detail
- customer records
- status updates
- invoice generation

### Phase 3: scheduling and operational workflow

- calendar or list-based scheduler
- assignment flow
- technician filters
- waiting on part tracking
- callback handling

### Phase 4: reminders and payment

- SMS/email reminders
- Stripe integration
- payment links
- subscriptions and billing

### Phase 5: mobile and offline support

- installable web app
- local caching for offline use
- technician app improvements
- photo capture

---

## 12. Risks and realities

This is a real market but it is not empty.

Competing head-on with Jobber or Housecall Pro would be difficult.

The smarter move is to stay niche and specific.

The product should solve a real pain point that generic tools ignore, such as:

- appliance-specific data fields
- callback tracking
- waiting on part workflow
- warranty documentation
- recurring pet care scheduling

That niche focus is the product’s competitive edge.

---

## 13. Current repo fit

This repository already has several of the right foundations:

- `backend/` → FastAPI app scaffold
- `frontend/` → Astro landing site scaffold
- `frontend_flutter/` → Flutter MVP path for technician-side workflows

This means the product idea can evolve without a full rewrite.

The project is aligned with the best path for this business idea:

- public browser experience for marketing and booking
- professional backend for actual business logic
- Flutter path for later mobile or field operations tools

---

## 14. Recommended next steps

1. Finalize the niche
   - appliance repair as the primary focus
   - pet grooming as secondary option

2. Define the first 5 core screens
   - booking page
   - home dashboard
   - jobs list
   - new job form
   - job detail page

3. Build the FastAPI models and routes
   - customer
   - job
   - invoice
   - status updates

4. Connect the Astro booking page to the API

5. Add the business dashboard

6. Validate with real small-business users

7. Add payments, reminders, and photo uploads only after the core workflow is stable

---

## 15. Final positioning statement

Fieldmate is a niche field service platform for service businesses that need a practical system for booking, job management, tracking, and invoicing without the complexity of enterprise software.

It is not meant to be a massive generic platform. It is meant to be the simplest, most relevant tool for a specific trade and a practical route to recurring revenue.

That is the right strategy for a bootstrapped SaaS built in the real world.

---

## 16. Quick summary

If the goal is to build something useful, professional, and realistically sellable, the best move is:

- choose one niche
- build a lightweight but real workflow
- keep the product simple and operational
- sell through direct outreach and niche communities
- use FastAPI + Astro + Flutter as the tech stack with a future mobile path

This is stronger than building a broad “Housecall Pro clone” without a real wedge.

---

## 17. Suggested product name

A strong fit for this product is:

- Fieldmate

This name is simple, memorable, clear, and not restricted to solo businesses. It works for a small one-person operator or a growing multi-tech business.

---

## 18. Development principle

The rule for this project is simple:

Do not build “all the features.”

Build the exact workflow that makes a real service business faster and more organized.

That is what creates product value.
