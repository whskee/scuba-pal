import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Scuba Pal',
  tagline: 'Connecting people to the ocean',
  favicon: 'img/favicon.ico',

  future: { v4: true, }, // Future flags to improve compatibility with the upcoming Docusaurus v4, see https://docusaurus.io/docs/api/docusaurus-config#future

  url: 'https://your-docusaurus-site.example.com', // Set the production url of your site here
  baseUrl: '/scuba-pal/',

  // GitHub Pages Deployment Config.
  organizationName: 'whskee',
  projectName: 'scuba-pal',

  onBrokenLinks: 'throw',

  i18n: { defaultLocale: 'en', locales: ['en'], }, // Even if you don't use internationalization, you can use this field to set useful metadata like html lang. For example, if your site is Chinese, you may want to replace "en" with "zh-Hans".

  presets: [
    [
      'classic',
      {
        docs: {
          path: './content',
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/whskee/scuba-pal/tree/main/docs/',
          tags: `tags.yaml`,
          onInlineTags: `warn`,
        },
        blog: {
          showReadingTime: true,
          feedOptions: { type: ['rss', 'atom'], xslt: true, },
          editUrl: 'https://github.com/whskee/scuba-pal/tree/main/docs/',
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        theme: { customCss: './src/css/custom.css', },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: { respectPrefersColorScheme: true, defaultMode: 'dark', },
    docs: {
      sidebar: { autoCollapseCategories: true, },
    },
    navbar: {
      title: 'Scuba Pal',
      logo: { alt: 'Scuba Pal Logo', src: 'img/logo.png', },
      items: [
        { type: 'docSidebar', sidebarId: 'tutorialSidebar', position: 'left', label: 'Tutorial', },
        { type: 'docSidebar', sidebarId: 'apiSidebar', position: 'left', label: 'API', },
        { type: 'docSidebar', sidebarId: 'databaseSidebar', position: 'left', label: 'Database', },
        { type: 'docSidebar', sidebarId: 'mobileSidebar', position: 'left', label: '📱', },
        // { to: '/blog', label: 'Blog', position: 'left' },
        { href: 'https://github.com/whskee/scuba-pal', label: 'GitHub', position: 'right', },
        {
          href: 'https://github.com/whskee/scuba-pal', 'aria-label': 'GitHub repository',
          html: `<svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor" style="display: block; vertical-align: middle;"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>`,
          position: 'right',
        },
      ],
    },

    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Tags', to: '/docs/tags', },
            { label: '✅ To do', to: '/docs/tags/todo', },
            { label: 'AWS', to: '/docs/tags/aws', },
            { label: 'Automation', to: '/docs/tags/automation', },
            { label: 'Diagram', to: '/docs/tags/diagram', },
          ],
        },
        {
          title: 'Community',
          items: [
            { label: 'Stack Overflow', href: 'https://stackoverflow.com/questions/tagged/docusaurus', },
            { label: 'Discord', href: 'https://discordapp.com/invite/docusaurus', },
            { label: 'X', href: 'https://x.com/docusaurus', },
          ],
        },
        {
          title: 'More',
          items: [
            { label: 'Blog', to: '/blog', },
            { label: 'GitHub', href: 'https://github.com/whskee/scuba-pal', },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Scuba Pal, Inc. Built with Docusaurus.`,
    },

    prism: { theme: prismThemes.github, darkTheme: prismThemes.dracula, },
  } satisfies Preset.ThemeConfig,
};

export default config;
