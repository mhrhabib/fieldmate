# Copilot Instructions for Repairmate

## Project intent
This repository is for a niche field-service SaaS product focused on real-world service workflows and operational efficiency. The product is not meant to be a generic ERP clone.

## Mandatory rules

### 1. SEO-first marketing frontend
- The Astro site is the public-facing marketing and customer-booking layer.
- Pages should be semantic, content-rich, fast, and indexable.
- Prefer static generation and server-rendered output when practical.
- Avoid unnecessary client-side JavaScript in marketing sections.
- Use metadata and clean page structure to support SEO and conversion.

### 2. Backend clean architecture
- Build the backend with a layered architecture from the start.
- Keep business logic separated from HTTP and database concerns.
- Use domain entities and use cases, with repositories and infrastructure adapters behind interfaces.
- Design for future scale and feature growth, not only the MVP.

### 3. Mobile-first Flutter design
- Design for mobile phones first and foremost.
- Optimize for touch, compact workflows, and field usability.
- Keep the PWA experience polished and installable.
- Do not build a desktop-first dashboard that is awkward on a phone.

### 4. Bloc/Cubit architecture in Flutter
- Use Bloc or Cubit for state management.
- Keep widgets thin and UI-focused.
- Push business logic into domain/application layers.
- Structure the app so it can later-scale into larger features without state sprawl.

### 5. Platform expansion ready
- Keep core logic platform-independent and service-oriented.
- This repo should allow future native iOS, Android, macOS, and watchOS work without rethinking the main domain architecture.
- Leave room for Swift integration later through clean interfaces and domain boundaries.

## Naming and product choice
- Keep the product identity aligned with an operational field-service SaaS.
- Prefer clear, practical names that reflect field work, scheduling, and service operations.
- Avoid branding that suggests a generic business suite or broad ERP.

## Development philosophy
- Prefer specific value over broad feature count.
- Solve real trade workflows, not vague admin complexity.
- Keep architecture maintainable and extensible.
- Do not accept shortcuts that create technical debt early.

## Default stack
- Astro for marketing/SEO/public booking pages
- FastAPI for backend API and business logic
- Flutter Web/PWA as the first client experience
- Bloc/Cubit for Flutter state management
- Clean Architecture across backend and Flutter layers

## Quality expectations
- Every feature should map to an actual service business workflow.
- The public web experience should feel fast and professional.
- The internal app should feel mobile-first and field-ready.
- The overall system should be designed so later expansion remains straightforward.
