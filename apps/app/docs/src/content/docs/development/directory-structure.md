---
title: Directory Structure
description: A reference page in my new Starlight docs site.
---

Java full-stack implementation of Scuba Pal using Spring Boot + Thymeleaf + PostgreSQL.

project-root/
├── docs/                      <-- GitHub Pages source folder
│   ├── index.md               <-- Main homepage (displays at your-url.io)
│   ├── architecture.md        <-- High-level system design
│   ├── api-reference.md       <-- API endpoints and specs
│   ├── setup-guide.md         <-- Local dev environment instructions
│   ├── mobile-preview.md      <-- Mobile Expo UI screenshots & walkthroughs
│   ├── assets/                <-- Static files (non-Markdown)
│   │   ├── css/               <-- Custom styles (e.g., style.scss)
│   │   ├── images/            <-- ALL branding and UI screenshots
│   │   │   ├── logos/         <-- Product branding
│   │   │   ├── mobile-ui/     <-- Expo app screenshots
│   │   │   └── diagrams/      <-- PNG/SVG architecture exports
│   │   └── pdf/               <-- Downloadable guides or whitepapers
│   ├── .nojekyll              <-- Empty file to disable Jekyll (if using custom static files)
│   └── _config.yml            <-- Jekyll configuration (themes, baseurl)
├── src/                       <-- Spring Boot source code
├── scripts/                   <-- Helper .sh and temporary Makefiles
└── Makefile                   <-- Main project build/control file

