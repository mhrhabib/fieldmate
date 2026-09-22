import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

export default defineConfig({
  site: "https://sitemate.example.com", // used to generate absolute URLs / sitemap / OG tags
  output: "static", // pure SSG: every page is plain HTML at build time — best for SEO & speed
  integrations: [tailwind({ applyBaseStyles: false })],

  // If you later add pages that must be rendered per-request (e.g. a logged-in
  // dashboard, or a page whose content depends on cookies), switch to:
  //   output: "hybrid"
  // and add an adapter, e.g.:
  //   import node from "@astrojs/node";
  //   adapter: node({ mode: "standalone" }),
  // then opt individual pages into SSR with `export const prerender = false;`.
});
