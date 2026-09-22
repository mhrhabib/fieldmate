# Repairmate Agent Rules

## Mission
Build a niche field-service SaaS for service businesses with a strong focus on practical workflow, not generic enterprise bloat.

## Product direction
- Prioritize one clear niche first, starting with appliance repair.
- Keep the product useful and simple for small and medium businesses.
- Do not build a generic all-in-one ERP unless absolutely required for a specific feature.
- Aim for clear operational value: booking, job tracking, scheduling, invoicing, follow-up, and reminders.

## Architecture rules
### 1. Astro frontend must stay SEO-first
- Treat the public marketing site as a search-optimized product page, not just a JS app.
- Prefer semantic HTML, metadata, strong headings, and structured content.
- Use static generation and server-rendered output where possible.
- Keep JavaScript minimal on landing pages.
- Do not add heavy client-side rendering to pages that should rank and be indexable.
- Focus on fast initial page load, strong content hierarchy, and clear conversion paths.

### 2. Backend must use clean architecture from day one
- Separate domain logic from infrastructure logic.
- Use layered design: domain, application/use cases, interface adapters, infrastructure.
- Keep business rules independent from database, HTTP, and external services.
- Design repositories and service interfaces before concrete implementations.
- Prefer dependency inversion so external systems are replaceable.
- Keep the backend scalable enough to support future growth without a rewrite.

Expected structure:
- domain/
- application/
- infrastructure/
- interfaces/
- shared/

### 3. Flutter must be designed mobile-first and PWA-friendly
- Design for phone screens first, then expand for tablet and desktop.
- Optimize for touch interactions and thumb-friendly layout.
- Keep layouts simple, fast, and practical for field use.
- Prioritize offline resilience, good mobile data handling, and realistic service workflows.
- Build the web app as a progressive web app, not as a desktop-oriented admin panel.
- Do not make the app feel like a generic dashboard-first ERP.

### 4. Flutter state management must use Bloc/Cubit clean architecture
- Use Bloc or Cubit as the default state management pattern.
- Keep business logic in use cases and repositories, not inside widgets.
- Use feature-based organization for screens and flows.
- Keep UI widgets dumb and presentation-focused.
- Maintain clean separation between data layer, domain layer, and presentation layer.
- Prefer repository abstractions over direct service calls inside UI logic.

### 5. Leave room for future multi-platform expansion
- Keep business logic and API contracts portable for future app expansion.
- Prepare the architecture for eventual iOS and Android native apps.
- Keep a clean shared domain model that can later support macOS and watchOS.
- Design service boundaries so Swift/WatchOS integration remains possible without rewriting the core system.
- Do not hardcode assumptions that block future native or wearable experiences.

## Implementation preferences
- Use FastAPI for backend APIs and business services.
- Use Astro for the public marketing site and booking funnel.
- Use Flutter Web first as a PWA and mobile-first interface.
- Keep structure modular and scalable for eventual growth.
- Prefer explicit contracts, type-safe models, and maintainable boundaries.
- Avoid premature optimization but avoid architectural shortcuts that block scale.

## Quality bar
- Make every feature solve a real service-business workflow problem.
- Prefer specific, high-value functionality over broad but shallow features.
- Keep the UX understandable to a non-technical field business owner.
- Favor maintainability and future extensibility over quick hacks.
