// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import sitemap from "@astrojs/sitemap";
import remarkSmartypants from "remark-smartypants";

// https://astro.build/config
export default defineConfig({
  site: "https://workaround.org",
  redirects: {
    "/ispmail-trxie/imap/": "/ispmail-trixie/imap/",
    "/ispmail-trxie/anti-spoofing-dkim-spf": "/ispmail-trixie/anti-spoofing-dkim-spf",
    "/ispmail-trxie/catch-all": "/ispmail-trixie/catch-all",
    "/ispmail-trxie/quotas": "/ispmail-trixie/quotas",
    "/ispmail-trxie/going-live": "/ispmail-trixie/going-live",
  },
  integrations: [
    starlight({
      head: [
        {
          tag: "script",
          attrs: {
            src: "https://rybbit.workaround.org/api/script.js",
            "data-site-id": "1",
            async: true,
            defer: true,
          },
        },
      ],
      expressiveCode: {
        frames: {
          removeCommentsWhenCopyingTerminalFrames: false, // keep the commented lines when copying shell snippets
        },
      },
      lastUpdated: true,
      title: "ISPmail Guide",
      social: [
        { icon: "github", label: "GitHub", href: "https://github.com/Signum/ispmail-workaround-org/" },
        { icon: "matrix", label: "Matrix", href: "https://riot.im/app/#/room/#ispmail:matrix.org" },
        {
          icon: "rss",
          label: "Feed",
          href: "https://comentario.workaround.org/api/rss/comments?domain=0f111a27-fbfa-48af-8beb-ab12e612d92f",
        },
      ],
      // https://expressive-code.com/key-features/word-wrap/#configuration
      components: {
        Footer: "./src/components/Footer.astro",
        Banner: "./src/components/Banner.astro",
      },
      customCss: ["./src/styles/custom.css"],
      sidebar: [
        {
          label: "ISPmail for Debian 13",
          // slug: "ispmail-trixie",
          autogenerate: { directory: "ispmail-trixie" },
        },
        {
          label: "ISPmail for Debian 12",
          // slug: "ispmail-bookworm",
          autogenerate: { directory: "ispmail-bookworm" },
        },
        {
          label: "Misc articles",
          autogenerate: { directory: "articles" },
        },
      ],
      logo: {
        light: "./src/assets/logo.svg",
        dark: "./src/assets/logo-dark.svg",
        replacesTitle: true,
      },
    }),
    sitemap(),
  ],

  markdown: {
    remarkPlugins: [
      // remove the substitution of -- to –
      // @ts-ignore
      [remarkSmartypants, { dashes: false }],
    ],
  },
});
