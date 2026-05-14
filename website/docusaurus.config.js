// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

const baseUrl = process.env.DOCUSAURUS_BASE_URL ?? '/';
const siteUrl = process.env.DOCUSAURUS_URL ?? 'https://your-docusaurus-site.example.com';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Dutch Warnings',
  tagline: 'NL-Alert viewer documentatie',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: siteUrl,
  baseUrl: baseUrl,

  onBrokenLinks: 'warn',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'nl',
    locales: ['nl'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          path: '../docs',
          sidebarPath: './sidebars.js',
          exclude: ['**/screenshots/**'],
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Dutch Warnings',
        logo: {
          alt: 'Dutch Warnings logo',
          src: 'img/logo.png',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docsSidebar',
            position: 'left',
            label: 'Documentatie',
          },
        ],
      },
      footer: {
        style: 'dark',
        copyright: `Copyright © ${new Date().getFullYear()} Dutch Warnings`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;
