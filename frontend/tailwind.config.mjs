/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        ink: "#0b0f19",
        muted: "#5b6472",
        line: "#e5e8ef",
        accent: {
          DEFAULT: "#3560e0",
          soft: "#eef2fd",
          dark: "#274bbd",
        },
        surface: "#fafafb",
      },
      fontFamily: {
        sans: [
          "Inter",
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "Roboto",
          "sans-serif",
        ],
      },
      maxWidth: {
        wrap: "1200px",
      },
      boxShadow: {
        subtle: "0 1px 2px rgba(11,15,25,0.04), 0 8px 24px -12px rgba(11,15,25,0.08)",
        card: "0 1px 1px rgba(11,15,25,0.03), 0 12px 32px -16px rgba(11,15,25,0.12)",
      },
      borderRadius: {
        xl2: "1.25rem",
      },
      keyframes: {
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(16px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        "fade-up": "fade-up 0.6s ease-out both",
      },
    },
  },
  plugins: [],
};
