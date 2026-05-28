// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://whskee.github.io',
	base: '/scuba-pal-app',
	integrations: [
		starlight({
			title: 'ScubaPal Docs',
			customCss: ['./src/styles/custom.css'],
			components: {
				ThemeSelect: './src/components/ThemeToggle.astro',
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/whskee/scuba-pal'
				}

			],
			sidebar: [
				{
					label: 'Getting Started',
					items: [{ autogenerate: { directory: 'getting-started' } }],
				},
				{
					label: 'Architecture',
					items: [{ autogenerate: { directory: 'architecture' } }],
				},
				{
					label: 'Database',
					items: [{ autogenerate: { directory: 'database' } }],
				},
				{
					label: 'API',
					items: [{ autogenerate: { directory: 'api' } }],
				},
				{
					label: 'Development',
					items: [{ autogenerate: { directory: 'development' } }],
				},
				{
					label: 'Deployment',
					items: [{ autogenerate: { directory: 'deployment' } }],
				},
				{
					label: 'Guides',
					// items: [
					// 	// Each item here is one entry in the navigation menu.
					// 	{ label: 'Example Guide', slug: 'guides/example' },
					// ],
					items: [{ autogenerate: { directory: 'guides' } }],
				},
				{
					label: 'Reference',
					items: [{ autogenerate: { directory: 'reference' } }],
				},
			],
		}),
	],
});
