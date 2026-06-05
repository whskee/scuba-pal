---
title: Fix Logo
description: Logo
tags: [todo]
---

The gap is coming from **two places**:

1. Your wrapper has `marginBottom: '1.5rem'`.
2. The logo image itself looks like it has empty vertical space inside the PNG, so even if the `<img>` is 210px tall, the actual manta is visually much higher.

Best clean fix: move styles into CSS and tighten the stack.

### Update JSX

```tsx
function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();

  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className={clsx('container', styles.heroContent)}>
        <img
          src="img/logo.png"
          alt="Scuba Pal logo"
          className={styles.heroLogo}
        />

        <Heading as="h1" className={clsx('hero__title', styles.heroTitle)}>
          {siteConfig.title}
        </Heading>

        <p className={clsx('hero__subtitle', styles.heroSubtitle)}>
          {siteConfig.tagline}
        </p>

        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            Onboarding - 30mins ⏱️
          </Link>
        </div>
      </div>
    </header>
  );
}
```

### Update `index.module.css`

```css
.heroBanner {
  padding: 4rem 0;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.heroContent {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.heroLogo {
  width: 210px;
  height: 210px;
  object-fit: contain;
  margin-bottom: -0.75rem;
}

.heroTitle {
  margin-top: 0;
  margin-bottom: 1.25rem;
}

.heroSubtitle {
  margin-top: 0;
  margin-bottom: 2.5rem;
}

.buttons {
  display: flex;
  align-items: center;
  justify-content: center;
}
```

The important line is:

```css
margin-bottom: -0.75rem;
```

Because your logo PNG likely has visual padding inside the image, a small negative margin is acceptable here.

For a cleaner long-term fix, crop `logo.png` so the manta fills the image bounds more tightly. Then you can avoid negative margins and use this instead:

```css
.heroLogo {
  width: 180px;
  height: auto;
  margin-bottom: 0.5rem;
}
```

Also, I would reduce the logo from `210px` to around `160px–180px`. Right now the logo feels like a huge invisible box above the title, even though the manta itself is visually smaller.
