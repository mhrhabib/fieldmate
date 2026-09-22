# SiteMate starter: FastAPI + Astro

A minimal, working skeleton for a FastAPI backend paired with an Astro
frontend, wired together end to end so you can see the full request flow:
build-time data fetching (for SEO) + a small client-side island (for
interactivity).

## Why this split

- **FastAPI** is just a JSON API. It doesn't render any HTML. This same API
  can later serve your Flutter iOS/Android/desktop clients too — one backend,
  every client.
- **Astro** builds the marketing site to plain static HTML by default
  (`output: "static"` in `astro.config.mjs`). Search engines and social-link
  previews get real content immediately, with no JavaScript required to see
  the page. Only the pieces that need interactivity (like the waitlist form)
  ship JS, and only on the pages that use them — that's Astro's "islands"
  model.

## Run it

**Backend:**
```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload --port 8000
```

**Frontend** (in a second terminal):
```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```

Open http://localhost:4321. The homepage fetches `/api/stats` from FastAPI at
build time and the waitlist form posts to `/api/waitlist` from the browser.

## Where to go from here

- Swap the in-memory list in `backend/main.py` for SQLAlchemy/SQLModel +
  PostgreSQL, and add Alembic migrations.
- Add auth (you already know OAuth2/JWT) — issue a JWT from FastAPI, store it
  wherever your logged-in app lives.
- For pages that must be rendered per-request instead of at build time
  (anything personalized, or behind login), switch `output` to `"hybrid"` in
  `astro.config.mjs`, add a Node adapter, and mark that one page with
  `export const prerender = false;` — everything else stays static.
- Deploy: FastAPI to Fly.io/Railway/a container behind nginx; Astro's static
  output to Netlify/Vercel/Cloudflare Pages/any static host or CDN.
- Add `@astrojs/sitemap` for an auto-generated sitemap.xml once you have more
  pages — worth it for SEO once the site grows past a handful of routes.
# fieldmate
