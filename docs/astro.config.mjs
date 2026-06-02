// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

// https://astro.build/config
export default defineConfig({
	site: 'https://whskee.github.io',
	base: '/scuba-pal',
	integrations: [
		mermaid({
			theme: 'default', // You can change to 'dark', 'forest', 'neutral', etc.
			autoTheme: true,  // Adapts theme based on data-theme attributes
		}),
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
					label: 'To Do',
					collapsed: false,
					items: [{ autogenerate: { directory: 'todo' } }],
				},
				{
					label: 'Getting Started',
					collapsed: true,
					items: [{ autogenerate: { directory: 'getting-started' } }],
				},
				{
					label: 'Architecture',
					collapsed: true,
					items: [{ autogenerate: { directory: 'architecture' } }],
				},
				{
					label: 'Database',
					collapsed: true,
					items: [{ autogenerate: { directory: 'database' } }],
				},
				{
					label: 'API',
					collapsed: true,
					items: [{ autogenerate: { directory: 'api' } }],
				},
				{
					label: 'Development',
					collapsed: true,
					items: [{ autogenerate: { directory: 'development' } }],
				},
				{
					label: 'Deployment',
					collapsed: true,
					items: [{ autogenerate: { directory: 'deployment' } }],
				},
				{
					label: 'Database',
					collapsed: true,
					items: [{ autogenerate: { directory: 'database' } }],
				},
				{
					label: 'Development',
					collapsed: true,
					items: [{ autogenerate: { directory: 'development' } }],
				},
				{
					label: 'Deployment',
					collapsed: true,
					items: [{ autogenerate: { directory: 'deployment' } }],
				},
				{
					label: 'Guides',
					collapsed: true,
					// items: [
					// 	// Each item here is one entry in the navigation menu.
					// 	{ label: 'Example Guide', slug: 'guides/example' },
					// ],
					items: [{ autogenerate: { directory: 'guides' } }],
				},
				{
					label: 'Reference',
					collapsed: true,
					items: [{ autogenerate: { directory: 'reference' } }],
				},
			],
		}),
	],
});
