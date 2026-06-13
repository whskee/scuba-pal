import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<'svg'>>;
  description: ReactNode;
};

// const FeatureList: FeatureItem[] = [
//   {
//     title: 'Dive into the community',
//     Svg: require('@site/static/img/undraw_docusaurus_mountain.svg').default,
//     description: (
//       <>
//         Docusaurus was designed from the ground up to be easily installed and
//         used to get your website up and running quickly.
//       </>
//     ),
//   },
//   {
//     title: 'Share your knowledge',
//     Svg: require('@site/static/img/undraw_docusaurus_tree.svg').default,
//     description: (
//       <>
//         Docusaurus lets you focus on your docs, and we&apos;ll do the chores. Go
//         ahead and move your docs into the <code>docs</code> directory.
//       </>
//     ),
//   },
//   {
//     title: 'Connect with others',
//     Svg: require('@site/static/img/undraw_docusaurus_react.svg').default,
//     description: (
//       <>
//         Extend or customize your website layout by reusing React. Docusaurus can
//         be extended while reusing the same header and footer.
//       </>
//     ),
//   },
// ];

const FeatureList: FeatureItem[] = [
  {
    title: 'Dive into the community',
    Svg: require('@site/static/img/dive-community.svg').default,
    description: (
      <>
        Discover divers, stories, dive spots, and shared underwater experiences
        in one ocean-focused community.
      </>
    ),
  },
  {
    title: 'Share your knowledge',
    Svg: require('@site/static/img/share-knowledge.svg').default,
    description: (
      <>
        Post dive logs, tips, gear notes, certifications, and local insight that
        help other divers learn faster and dive safer.
      </>
    ),
  },
  {
    title: 'Connect with others',
    Svg: require('@site/static/img/connect-divers.svg').default,
    description: (
      <>
        Follow divers, start conversations, plan trips, and build real
        connections around the places you love to dive.
      </>
    ),
  },
];

function Feature({title, Svg, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
