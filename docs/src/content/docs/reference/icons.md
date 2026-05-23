---
title: Icons
description: All links to download icons.
---


1. [AWS](https://aws.amazon.com/architecture/icons/)




# Resources
1. [Flat Icon](https://www.flaticon.com)
2. [Simple Icons](https://simpleicons.org)
3. [devicon](https://devicon.dev/?utm_source=chatgpt.com)

---

Yes — use your own local SVG icons. For README icons, I would **not** rely only on `skillicons.dev` long term.

**Progress: 20%**
You already have the README structure. Next goal: create a stable local icon system for anything missing from `skillicons.dev`.

## Best approach

Keep `skillicons.dev` for common tech:

```html
<img src="https://skillicons.dev/icons?i=java,spring,postgresql,postman,typescript,javascript,html,css,docker,aws&theme=light" />
```

Then add a second row of **your own local icons** for things like:

* Vaadin
* AWS S3
* AWS RDS
* Flyway
* OpenAPI
* Swagger
* Thymeleaf
* Expo
* Mailpit
* pgAdmin

Use this structure:

```text
scuba-pal/
├── README.md
├── assets/
│   └── icons/
│       └── stack/
│           ├── vaadin.svg
│           ├── aws-s3.svg
│           ├── aws-rds.svg
│           ├── flyway.svg
│           ├── openapi.svg
│           └── thymeleaf.svg
```

I would use `assets/icons/stack`, not `assets/images`, because these are not general images. They are part of your project branding/docs system.

## README snippet

Replace your current stack section with something like this:

```md
<h3 align="center">
  Stack
</h3>

<p align="center">
  <a href="https://skillicons.dev">
    <img 
      src="https://skillicons.dev/icons?i=java,spring,postgresql,postman,typescript,javascript,html,css,docker,aws&theme=light" 
      alt="Java, Spring, PostgreSQL, Postman, TypeScript, JavaScript, HTML, CSS, Docker, AWS"
    />
  </a>
</p>

<p align="center">
  <img src="./assets/icons/stack/flyway.svg" width="48" height="48" alt="Flyway" title="Flyway" />
  <img src="./assets/icons/stack/openapi.svg" width="48" height="48" alt="OpenAPI" title="OpenAPI" />
  <img src="./assets/icons/stack/swagger.svg" width="48" height="48" alt="Swagger" title="Swagger" />
  <img src="./assets/icons/stack/vaadin.svg" width="48" height="48" alt="Vaadin" title="Vaadin" />
  <img src="./assets/icons/stack/aws-s3.svg" width="48" height="48" alt="AWS S3" title="AWS S3" />
  <img src="./assets/icons/stack/aws-rds.svg" width="48" height="48" alt="AWS RDS" title="AWS RDS" />
  <img src="./assets/icons/stack/thymeleaf.svg" width="48" height="48" alt="Thymeleaf" title="Thymeleaf" />
</p>
```

## How to make them look like Skill Icons

Do **not** try to style them with CSS in the README. GitHub strips or limits a lot of styling.

Instead, bake the style directly into each SVG.

Example `assets/icons/stack/flyway.svg`:

```xml
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="48" rx="10" fill="#F3F4F6"/>
  <rect x="1" y="1" width="46" height="46" rx="9" stroke="#E5E7EB" stroke-width="2"/>
  <text
    x="24"
    y="29"
    text-anchor="middle"
    font-family="Arial, Helvetica, sans-serif"
    font-size="13"
    font-weight="700"
    fill="#CC0200">
    Fly
  </text>
</svg>
```

That gives you a Skill Icons–style tile: fixed size, rounded corners, light background, centered logo/text.

For real logos, use the actual SVG path inside the same tile wrapper:

```xml
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="48" rx="10" fill="#F3F4F6"/>
  <rect x="1" y="1" width="46" height="46" rx="9" stroke="#E5E7EB" stroke-width="2"/>

  <!-- Put logo path here -->
  <g transform="translate(10 10) scale(0.58)">
    <!-- logo svg path -->
  </g>
</svg>
```

## Terminal setup

From your repo root:

```bash
mkdir -p assets/icons/stack
```

What it does:

* `mkdir` creates directories.
* `-p` creates parent folders if they do not exist and does not error if they already exist.
* `assets/icons/stack` is the folder path for your custom stack icons.

Then add your SVG files there.

## My recommended convention

Use lowercase kebab-case names:

```text
aws-s3.svg
aws-rds.svg
flyway.svg
openapi.svg
swagger.svg
vaadin.svg
thymeleaf.svg
mailpit.svg
pgadmin.svg
expo.svg
```

Avoid spaces, uppercase names, or random vendor casing in filenames.

## Should you use PNG or SVG?

Use **SVG**.

Reasons:

* sharp at every size
* tiny file size
* easy to theme
* works well in GitHub README
* can include the rounded background directly

Use PNG only for screenshots or complicated logos you cannot get as SVG.

## Long-term clean README direction

Your stack section should eventually become:

```md
## Stack

<p align="center">
  common skillicons row
</p>

<p align="center">
  custom local icons row
</p>

- Backend: Java 17, Spring Boot 3.3, Spring Security, Spring Data JPA
- Database: PostgreSQL, Flyway
- Web: Thymeleaf
- API: REST, OpenAPI, Swagger UI
- Mobile-ready: TypeScript OpenAPI client generation
- Local infra: Docker, pgAdmin, Mailpit
- Cloud target: AWS S3, RDS, EC2
```

That gives you both the visual polish and the serious engineering overview.

**Next goal: 30%** — create `assets/icons/stack`, add 3 custom SVGs first: `flyway.svg`, `aws-s3.svg`, and `aws-rds.svg`, then wire them into the README before expanding the full icon set.

---

Use this order:

## Best places to find icons

| Need                                                                   | Best source                                            | Why                                                                                                                                            |
| ---------------------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Java, Spring, PostgreSQL, Docker, AWS, TypeScript, etc.                | **Skill Icons**                                        | Already matches your README style.                                                                                                             |
| Missing brand icons like Flyway, OpenAPI, Swagger, Postman, Expo, etc. | **Simple Icons**                                       | Large SVG brand catalog, easy to download. Simple Icons lists 3,400+ brand SVGs. ([simpleicons.org][1])                                        |
| Developer/framework icons                                              | **Devicon**                                            | Good for programming languages, frameworks, databases, and dev tools. ([devicon.dev][2])                                                       |
| AWS S3, RDS, EC2, ECS, Lambda, etc.                                    | **Official AWS Architecture Icons**                    | Best source for individual AWS service icons. AWS provides product icons/resources for architecture diagrams. ([Amazon Web Services, Inc.][3]) |
| Vaadin logo                                                            | **Vaadin Brand Toolkit**                               | Official Vaadin logo/brand assets. ([Vaadin Brand Toolkit][4])                                                                                 |
| Vaadin UI icons                                                        | **Vaadin Icons**                                       | Separate from the Vaadin logo; useful for app UI icons, not stack logos. ([Vaadin][5])                                                         |
| Random missing SVGs                                                    | **SVG Repo / Iconbuddy / Dashboard Icons / TechIcons** | Useful fallback, but check license/source before committing. SVG Repo has a large open SVG catalog. ([SVG Repo][6])                            |

## For your README specifically

Use these sources:

| Icon         | Where to get it                                                |
| ------------ | -------------------------------------------------------------- |
| Java         | Skill Icons / Devicon                                          |
| Spring       | Skill Icons / Devicon                                          |
| PostgreSQL   | Skill Icons / Devicon                                          |
| Docker       | Skill Icons / Devicon                                          |
| AWS generic  | Skill Icons                                                    |
| AWS S3       | AWS Architecture Icons                                         |
| AWS RDS      | AWS Architecture Icons                                         |
| AWS EC2      | AWS Architecture Icons                                         |
| Flyway       | Simple Icons or Wikimedia fallback                             |
| OpenAPI      | Simple Icons                                                   |
| Swagger      | Simple Icons / TechIcons                                       |
| Vaadin       | Vaadin Brand Toolkit                                           |
| Thymeleaf    | Thymeleaf official site / fallback SVG source                  |
| Expo         | Simple Icons                                                   |
| React Native | Skill Icons / Devicon                                          |
| Postman      | Skill Icons / Simple Icons                                     |
| pgAdmin      | Simple Icons or fallback SVG source                            |
| Mailpit      | Usually no polished official icon; make a custom tile yourself |

## Where to put them

Since your repo root is `scuba-pal`, with backend under `app` and mobile under `mobile`, I would keep README icons at the **repo root**, not inside the Spring Boot static folder. 

Use:

```text
scuba-pal/
├── README.md
├── assets/
│   └── icons/
│       └── stack/
│           ├── aws-s3.svg
│           ├── aws-rds.svg
│           ├── flyway.svg
│           ├── openapi.svg
│           ├── swagger.svg
│           ├── vaadin.svg
│           ├── thymeleaf.svg
│           └── mailpit.svg
```

Create it with:

```bash
mkdir -p assets/icons/stack
```

What it does:

* `mkdir` creates folders.
* `-p` creates parent folders automatically and does not fail if they already exist.
* `assets/icons/stack` keeps README technology icons separate from app images.

## My recommended workflow

1. Keep using `skillicons.dev` for common icons.
2. Download missing icons as SVG.
3. Wrap each SVG inside your own `48x48` rounded tile so they visually match Skill Icons.
4. Commit them into `assets/icons/stack`.
5. Reference them from README using relative paths:

```html
<p align="center">
  <img src="./assets/icons/stack/flyway.svg" width="48" height="48" alt="Flyway" title="Flyway" />
  <img src="./assets/icons/stack/aws-s3.svg" width="48" height="48" alt="AWS S3" title="AWS S3" />
  <img src="./assets/icons/stack/aws-rds.svg" width="48" height="48" alt="AWS RDS" title="AWS RDS" />
  <img src="./assets/icons/stack/vaadin.svg" width="48" height="48" alt="Vaadin" title="Vaadin" />
</p>
```

## Important rule

Do **not** hotlink random icon URLs directly in your README, except for Skill Icons.

Better:

```html
<img src="./assets/icons/stack/flyway.svg" width="48" height="48" alt="Flyway" />
```

Worse:

```html
<img src="https://some-random-site.com/flyway.svg" />
```

Local SVGs are stable, versioned, and will not randomly disappear.

**Progress: 45%**
Next goal: collect `flyway.svg`, `aws-s3.svg`, `aws-rds.svg`, `openapi.svg`, and `vaadin.svg`, then normalize all of them into the same 48×48 tile style.

[1]: https://simpleicons.org/?utm_source=chatgpt.com "Simple Icons"
[2]: https://devicon.dev/?utm_source=chatgpt.com "DEVICON | All programming languages and development ..."
[3]: https://aws.amazon.com/architecture/icons/?utm_source=chatgpt.com "AWS Architecture Icons"
[4]: https://brand.vaadin.com/?utm_source=chatgpt.com "Vaadin Brand Toolkit"
[5]: https://vaadin.com/docs/latest/components/icons/default-icons?utm_source=chatgpt.com "Default Icons | Vaadin components"
[6]: https://www.svgrepo.com/?utm_source=chatgpt.com "SVG Repo - Free SVG Vectors and Icons"
