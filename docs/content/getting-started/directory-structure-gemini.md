---
title: Gemini Directory Structure
description: A reference for folder structure Gemini gave me.
---

In a large Spring Boot project, assets are placed in different locations depending on whether they are runtime assets (needed by the app when it’s running) or development assets (documentation, diagrams, and project references). [1] 
## 1. Runtime Assets (Images, Icons, CSS)
If these images or assets are part of the application’s UI (e.g., website logos, icons for a dashboard), they must be in the classpath to be served by the web server.

* Location: src/main/resources/static/.
* Subfolders: It is best practice to group them, such as static/images/, static/css/, and static/js/.
* Note: Anything here is public. If you put an image at src/main/resources/static/images/logo.png, it is accessible at http://localhost:8080/images/logo.png. [2, 3, 4, 5, 6] 

## 2. Development Assets (Diagrams, Docs, Architecture)
Internal project documentation, architectural diagrams, and reference resources should not be in the src folder. Placing them in src/main/resources would bundle them into your final JAR/WAR file, unnecessarily increasing its size. [7] 

* Location: Project Root (parallel to src/).
* Folder Name: Typically named /docs, /documentation, or /architecture.
* Why? This keeps them in version control (Git) for the team to see, but keeps them out of the production build. [7] 

## Summary Table for a Large Project

| Asset Type [3, 4, 5, 7, 8, 9] | Best Folder Location | Purpose |
|---|---|---|
| App Images/Logos | src/main/resources/static/images/ | Publicly accessible website assets. |
| Email Templates | src/main/resources/templates/ | Internal templates (e.g., Thymeleaf). |
| Architecture Diagrams | /docs/diagrams/ (Root) | Documentation for developers. |
| API Specs (Swagger) | src/main/resources/static/ | Shared API documentation files. |
| DB Migrations | src/main/resources/db/migration/ | SQL scripts for Flyway/Liquibase. |

Is it in the root?
Only development-only assets (like .drawio files, PDFs, or Markdown docs) belong in a /docs folder at the project root. Any asset the application needs to "see" or serve while running must be under src/main/resources. [7, 10, 11] 
Would you like to see a sample README.md structure for your /docs folder to help organize those diagrams and reference resources?

[1] [https://medium.com](https://medium.com/javarevisited/how-to-add-your-property-file-in-spring-boot-and-what-is-the-benefit-of-it-cb7f4dc43be7)
[2] [https://medium.com](https://medium.com/@AlexanderObregon/frontend-build-hosting-with-spring-boot-static-mapping-a736b2f54027)
[3] [https://medium.com](https://medium.com/@danilkashalindadsd/uncover-spring-boot-best-folder-structures-for-optimal-coding-1a09b4292763)
[4] [https://rifaiio.medium.com](https://rifaiio.medium.com/spring-boot-project-structure-best-practices-layer-based-vs-feature-based-explained-simply-4a9002f3cff0)
[5] [https://stackoverflow.com](https://stackoverflow.com/questions/42157244/spring-boot-mapping-resource-of-a-sub-folder)
[6] [https://medium.com](https://medium.com/@danilkashalindadsd/uncover-spring-boot-best-folder-structures-for-optimal-coding-1a09b4292763)
[7] [https://stackoverflow.com](https://stackoverflow.com/questions/9135477/where-should-project-documentation-be-stored-in-a-typical-maven-project)
[8] [https://medium.com](https://medium.com/@jagritisrvstv/spring-boot-folder-structure-fa22c1ee3624)
[9] [https://medium.com](https://medium.com/@anandjeyaseelan10/spring-boot-project-structure-explained-best-practices-c2ba46ea57eb)
[10] [https://www.ibm.com](https://www.ibm.com/docs/en/wm-application-platform/10.7.0?topic=projects-folder-structure-java)
[11] [https://codesignal.com](https://codesignal.com/learn/courses/introduction-to-spring-boot-and-spring-core/lessons/understanding-project-structure)


---

For a large Spring Boot project, keeping your documentation organized is key for team onboarding and long-term maintenance. Placing a /docs folder at your project root is the industry standard. [1] 
Below is a recommended structure for your /docs/README.md to help you organize diagrams and reference resources effectively.
## Documentation Root Structure

```
project-root/
├── docs/
│   ├── README.md            <-- Main entry point for docs
│   ├── architecture/        <-- System-level diagrams (.png, .drawio)
│   ├── api/                 <-- Swagger/OpenAPI specs, Postman collections
│   ├── setup/               <-- Local dev environment guides
│   └── reference/           <-- Links to external libs, company wikis
├── src/                     <-- Code and runtime resources
└── README.md                <-- Project overview (links to /docs/README.md)
```

## Sample /docs/README.md Template
You can copy and adapt this Markdown content for your internal documentation: [2] 
------------------------------
## 📚 Project Documentation Hub
Welcome to the internal documentation for [Project Name]. This directory contains all non-code resources required to understand, build, and maintain the system.
## 🗺️ 1. Architecture & Design
High-level overview of how the system is built.

* System Overview Diagram: Visual flow of data from Frontend to DB.
* Database Schema: ER diagrams and key entity relationships.
* Sequence Diagrams: Detailed logic for complex flows like Authentication or Payment. [2] 

## 🔌 2. API Documentation

* REST API Reference: OpenAPI/Swagger definition file.
* Postman Collection: Import this to test endpoints locally.

## 🛠️ 3. Developer Setup
Everything a new engineer needs to get the app running.

* Environment Variables: List of required keys for your local .env.
* Docker/Database Setup: How to spin up required local services.

## 📖 4. External References

* Spring Boot Docs: Primary framework reference.
* Company Wiki: Internal business requirements and HR policies.

------------------------------
## Pro-Tip: Using Mermaid for Diagrams
Instead of uploading static .png files, you can use Mermaid.js directly in your Markdown files. Many IDEs and platforms like GitHub/GitLab render these automatically, making diagrams searchable and version-controlled. [3] 
Example Mermaid Flow (add to your .md):

graph TD;
    A[Client] -->|REST| B(Spring Boot App);
    B --> C{Database};
    B --> D[External API];

Would you like a sample setup guide specifically for configuring local Docker containers (PostgreSQL/Redis) for this project?

[1] [https://github.com](https://github.com/orgs/community/discussions/173482)
[2] [https://www.youtube.com](https://www.youtube.com/watch?v=AFFHh1Xq6Qc&t=22)
[3] [https://docs.github.com](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)


---

It is completely normal to feel buried when a project grows into two repos with mixed assets. The rule of thumb is: Production code stays in src, everything else stays in the root.
Since you have a Spring Boot/Thymeleaf repo and an Expo repo, here is how to clean up the chaos:
## 1. The Spring Boot Repo (Backend & Web)
Keep this focused on the server logic and the Thymeleaf frontend.

* docs/ (Root): Move your architecture diagrams, UI screenshots of the web version, and reference links here.
* scripts/ or build/ (Root): Put those makefiles and any automation scripts here.
* src/main/resources/static/: Only store the logos actually used by your Thymeleaf pages.
* .github/ (Root): If you are using GitHub Pages for project documentation (like a Javadoc site), it usually lives here or in a dedicated gh-pages branch.

## 2. The Expo Repo (Mobile)

* assets/: Keep your mobile-specific logos and splash screens here (Expo looks here by default).
* screenshots/ (Root): Move those mobile UI screenshots here. This is great for the README or app store submissions but doesn't need to be bundled in the app.
* .copilot/ (Root): If you have specific Copilot configuration files (like .github/copilot-instructions.md), keep them in the root so they guide the AI for just the mobile context.

## 3. The "Junk" Drawer (Safety First)
For the zip files of past versions and old temporary files:

* Do not put these in either Git repository. They bloat the repo size and make cloning slow.
* Action: Move them to a folder outside your project folders (e.g., ~/Archive/ProjectName_Old).
* If you must keep them in the folder: Add them to your .gitignore file so they stay on your hard drive but never get uploaded to GitHub.

## 4. Cross-Project References
If you have a "bunch of references" that apply to both mobile and backend:

* Pick one repo to be the "Source of Truth" (usually the Backend) and put a references.md in that docs/ folder.
* In the Mobile repo's README.md, simply link to the Backend repo's documentation.

I can help you write a .gitignore file to automatically hide those zips and temporary makefiles from your GitHub—would that help clear the clutter?



---

Keep your Main Makefile in the project root (next to pom.xml or build.gradle).
In software development, the root is the "standard" home for project-wide entry points. If a teammate (or you, six months from now) wants to build the project, the first thing they’ll do is run ls in the root. If the Makefile is buried in /scripts, they might not find it.
Here is the breakdown of where to put each type of file you mentioned:
## 1. The Root (Project Dashboard)

* Makefile (Main): Keep the primary one here. It acts as the "remote control" for your project.
* .gitignore: Crucial! Add *.zip and *.tmp here immediately so your old project backups don't get pushed to GitHub.
* docs/ folder: Put your Mobile UI screenshots, Logos, and Architectural Diagrams here.

## 2. The /scripts Folder (The Toolbox)

* Temporary .sh files: Any helper scripts for database migrations, cleaning caches, or one-off tasks.
* Makefile copies: If you have specialized makefiles (e.g., Makefile.docker, Makefile.deploy), put them here. Your Main Makefile in the root can actually call these if they get too complex.

## 3. The /assets or src/main/resources/static

* Live Logos: Only the images actually rendered by your Thymeleaf frontend.
* Note: If a logo is just for a presentation or a GitHub README, move it to /docs/branding.

## 4. What to do with the "Zip Files" and "Copilot Stuff"

* Zips: Move these out of the project entirely. Storing a zip of a project inside the project is like putting a photo of a suitcase inside that same suitcase—it just adds weight.
* Copilot/AI context: If you have custom prompt files or instruction sets, a hidden .copilot/ folder in the root is becoming a common standard.

Summary Recommendation:
Move the temporary scripts and makefile variants to /scripts, but leave the Main Makefile exactly where it is in the root for easy access.
Do you want a quick snippet for your .gitignore to make sure those zips and temporary files stop cluttering your Git history?



---

For [GitHub Pages](https://pages.github.com/), you typically configure your repository settings to serve the website from the /docs folder on your main branch. To keep this professional and functional, follow a structure that separates content (Markdown) from assets (images, CSS). [1, 2, 3, 4, 5] 
## Recommended /docs Structure for GitHub Pages
This structure works whether you use a simple theme or a documentation generator like MkDocs. [6] 

```
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
```

## Folder Breakdown & Usage

* index.md: This is your "Home" page. GitHub Pages converts this into index.html automatically.
```
<!-- * assets/images/: Place your Mobile Expo screenshots here. By keeping them in /docs/assets, you can reference them in your mobile-preview.md using standard Markdown: ![App Login](../setup/assets/images/mobile-ui/login.png). -->
```

* .nojekyll: If you are not using GitHub's built-in Jekyll engine (e.g., you are uploading a pre-built static site or using files with underscores), adding this empty file prevents GitHub from ignoring those files.
* architecture.md: Best place for your system diagrams. If you use Mermaid.js, you can even write the diagrams in plain text within this Markdown file. [2, 7] 

## Summary of Relocations

| Item | Old/Confusing Location | New /docs Path |
|---|---|---|
| Mobile UI Screenshots | Project Root | /docs/assets/images/mobile-ui/ |
| Project Logos | Scattered | /docs/assets/images/logos/ |
| Architecture Diagrams | src/resources | /docs/assets/images/diagrams/ |
| Ref Resources/Links | Memory/Slack | /docs/references.md |

Next Step: Would you like me to provide a starter .nojekyll and _config.yml so your GitHub Pages site renders correctly with a clean theme?

[1] [https://tomcam.github.io](https://tomcam.github.io/least-github-pages/adding-assets-directory-github-pages.html)
[2] [https://github.blog](https://github.blog/developer-skills/github/publish-your-project-documentation-with-github-pages/)
[3] [https://github.com](https://github.com/tomcam/least-github-pages/blob/master/docs/adding-assets-directory-github-pages.md)
[4] [https://github.com](https://github.com/orgs/community/discussions/147721)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=VDOyjwWPKs4)
[6] [https://www.youtube.com](https://www.youtube.com/watch?v=Q-YA_dA8C20)
[7] [https://github.com](https://github.com/sphinx-doc/sphinx/issues/3382)



---


Architecture diagrams belong in the docs/assets/images/diagrams/ folder of your repository. This ensures they are version-controlled alongside your code and easily accessible for your GitHub Pages website. [1, 2, 3] 

[Mastering Software Architecture Documentation: Detailed ...](https://radixweb.com/blog/software-architecture-documentation-guide)
[🧠 How to Generate Architecture Diagrams and Documentation ...](https://elbruno.com/2025/07/14/%F0%9F%A7%A0-how-to-generate-architecture-diagrams-and-documentation-from-net-aspire-host-definitions-using-github-copilot/)

## Where Architecture Diagrams Live

* Primary Location: /docs/assets/images/diagrams/.
* Exports: Keep your final .png, .jpg, or .svg files here.
   * Source Files: If you use draw.io or Excalidraw, you can keep the editable .drawio or .excalidraw source files here as well, so you never lose the ability to edit them. [2, 4, 5, 6] 
* Documentation Page: Create a file named /docs/architecture.md.

```
<!-- * This page should describe your system and embed the images from the assets folder using: ![Architecture Diagram](../setup/assets/images/diagrams/system-overview.png). [7, 8]  -->
```

## Alternative: "Diagrams as Code"
Many teams now prefer Mermaid.js, which allows you to write diagrams directly in text within your Markdown files. This avoids the need for separate image files entirely for many simple flows. [9, 10] 
Example Mermaid in /docs/architecture.md:

graph TD;
    MobileApp(Expo Mobile App) -->|REST API| SpringBoot(Spring Boot Backend);
    SpringBoot --> Database[(PostgreSQL)];
    SpringBoot --> Thymeleaf(Thymeleaf UI);

## Why This Structure?

   1. Version Control: When you update your backend code, you can update the diagram in the same Git commit.
   2. Clean Builds: Keeping them in /docs instead of src/main/resources prevents these large files from bloating your production Spring Boot JAR.
   3. GitHub Pages Ready: GitHub Pages automatically serves everything in the /docs folder, so your diagrams will appear instantly on your live documentation site. [1, 3, 11, 12, 13] 

Would you like me to help you write a Mermaid.js diagram for your specific Spring Boot and Expo setup to get you started?

[1] [https://medium.com](https://medium.com/software-architecture-foundations/documenting-software-architecture-in-code-repository-74716412b0a2)
[2] [https://docs.github.com](https://docs.github.com/en/enterprise-server@3.20/contributing/writing-for-github-docs/creating-diagrams-for-github-docs)
[3] [https://medium.com](https://medium.com/code-factory-berlin/github-repository-structure-best-practices-248e6effc405)
[4] [https://github.com](https://github.com/interTwin-eu/architecture-diagrams)
[5] [https://infrasketch.net](https://infrasketch.net/blog/architecture-diagram-best-practices)
[6] [https://www.freecodecamp.org](https://www.freecodecamp.org/news/system-architecture-documentation-best-practices-and-tools/)
[7] [https://github.com](https://github.com/orgs/community/discussions/191247)
[8] [https://github.com](https://github.com/MicrosoftDocs/well-architected/blob/main/well-architected/architect-role/design-diagrams.md)
[9] [https://www.youtube.com](https://www.youtube.com/watch?v=oiVy7NDm-WM)
[10] [https://stackoverflow.com](https://stackoverflow.com/questions/53883747/how-to-make-github-pages-markdown-support-mermaid-diagram)
[11] [https://docs.github.com](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams)
[12] [https://stackoverflow.com](https://stackoverflow.com/questions/76754563/where-to-place-summary-uml-diagrams-in-a-github-repository)
[13] [https://gibinfrancis.medium.com](https://gibinfrancis.medium.com/creating-structured-multi-page-documentation-with-github-pages-794b100a4941)



---


To get your documentation and GitHub Pages live, follow these steps. This setup assumes you want to turn that /docs folder into a clean, readable website.
## 1. The GitHub Pages Trigger
To make sure GitHub knows your /docs folder is a website, you need to enable it in your repository:

   1. Go to your repository on GitHub.com.
   2. Click Settings > Pages (on the left sidebar).
   3. Under Build and deployment > Branch, select main (or your primary branch).
   4. Change the folder dropdown from / (root) to /docs.
   5. Click Save.

## 2. Create the Essential Files
In your project root, run these commands (or create the files manually) to set up the structure we discussed:

# Create the directory structure
mkdir -p docs/assets/images/diagrams docs/assets/images/mobile-ui docs/setup
# Create the homepage
touch docs/index.md
# Create the 'No Jekyll' flag (crucial if you have folders starting with underscores)
touch docs/.nojekyll

## 3. Add a Theme (Optional but Recommended)
To make it look like a real website instead of a plain text file, create docs/_config.yml and add a theme:

theme: jekyll-theme-minimaltitle: [Project Name] Documentationdescription: Backend (Spring Boot) and Mobile (Expo) integration guide.

Other popular themes you can type there: jekyll-theme-cayman, jekyll-theme-architect.
## 4. How to link your Diagrams and Screenshots
Inside your docs/index.md (or a specific architecture.md), use this syntax to pull in those files you moved:

```
<!-- # Project Overview## Mobile App ScreenshotsHere is the latest UI from the Expo build:![Login Screen](../setup/assets/images/mobile-ui/login-v1.png)
## System ArchitectureThis diagram explains how the Spring Boot backend connects to the database:![Architecture Diagram](../setup/assets/images/diagrams/backend-flow.png) -->
```

## 5. Cleaning up the "Chaos" (The Move)
Now, physically move your files:

* Screenshots & Logos: Drag from root/downloads into docs/assets/images/.
* References: Copy those links/notes into a new file: docs/setup/references.md.
* The "Past Zips": Move them completely out of this folder to a local backup or cloud drive.

## 6. The "How-To" for your Makefile
Since you have a Main Makefile in the root, add a "help" command so anyone can see what it does. Open your Makefile and add:

help:
	@echo "Usage:"
	@echo "  make build    - Build the Spring Boot JAR"
	@echo "  make run      - Run the application locally"
	@echo "  make docs     - Open local documentation preview"

build:
	./mvnw clean package

run:
	./mvnw spring-boot:run

Would you like me to generate a .gitignore specifically tailored to hide those temporary .sh copies and zip files so they don't accidentally end up on GitHub?



---

In a professional project, setup/ and how-to/ actually serve two different purposes. You can pick one or use both depending on how much "mess" you're trying to organize.
## 1. The setup/ Folder
Focus: The environment.
This is for the "one-time" tasks a developer does to get the project running.

* Database Config: How to set up PostgreSQL or Docker.
* Environment Variables: A list of all the .env keys needed for Spring Boot and Expo.
* Tooling: Links to install the right versions of Java, Node, or the Expo CLI.
* Reference: This is where those reference resources you mentioned belong (links to documentation for libraries you use).

## 2. The how-to/ Folder (or guides/)
Focus: The workflow.
This is for "repeatable" tasks or specific "recipes" for your project.

* How to add a new API endpoint: A step-by-step guide for your Spring Boot layers.
* How to build the mobile APK: Instructions for the Expo build process.
* How to run migrations: Steps for Flyway/Liquibase or database updates.
* GitHub Pages deployment: How to update the site itself.

------------------------------
## Where to put your specific "mess":

* The References: Put these in docs/setup/references.md.
* The Mobile UI Screenshots: Even though they are "how-to" visual aids, keep the actual image files in docs/assets/images/mobile-ui/ and then link to them inside a file like docs/how-to/mobile-usage.md.
* Temporary Makefiles/Scripts: If you have a script that is confusing, write a quick docs/how-to/automation.md explaining what those .sh files in your /scripts folder actually do.

## Summary of the "Final" Structure:
```
docs/
├── setup/
│   ├── installation.md
│   ├── database.md
│   └── references.md        <-- Put your "bunch of references" here
├── how-to/
│   ├── deployment.md
│   ├── mobile-builds.md     <-- Explain the Expo screenshots here
│   └── coding-standards.md
└── assets/                  <-- All your images/logos go here
```

Pro-Tip: If you feel you have too many folders, just use docs/guides/ and put everything in there. It’s better to have one organized folder than three empty ones.
Which of your references are you most worried about losing track of—API docs, styling guides, or third-party library links?




---

Based on your project requirements for a large Spring Boot backend and an Expo mobile frontend, here is the complete directory structure. This organization follows standard conventions for large GitHub repositories while specifically accommodating your use of GitHub Pages for documentation. [1, 2, 3] 
## 1. Spring Boot Backend Repository Structure
This structure uses feature-based packaging for better scalability. [4] 

* / (Root): Contains primary entry points and configuration.
* Makefile: The main "remote control" for the project.
   * .gitignore: Essential for hiding zips, .tmp files, and local IDE settings.
   * pom.xml / build.gradle: Project build configuration.
   * src/main/java/com/yourname/project/: Core source code.
   * /feature-name/: Feature-based subfolders containing their own controllers, services, and repositories.
      * /config/: Global configuration (e.g., Security, Swagger).
      * /shared/: Common DTOs and utilities used across features.
   * src/main/resources/: Non-Java application resources.
   * application.yml: Main application configuration.
      * /static/: Live assets for your Thymeleaf pages (logos, CSS, JS).
      * /templates/: Thymeleaf HTML templates.
      * /db/migration/: Database versioning scripts (e.g., Flyway).
   * src/test/: Mirror of the source structure for automated tests.
   * scripts/: Home for temporary .sh scripts and specialized Makefile copies.
   * docs/: Source for your GitHub Pages website (see Section 3 for subfolders). [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12] 

## 2. Expo Mobile Frontend Repository Structure

* / (Root)
* App.js: Main entry point.
   * package.json: Dependencies and scripts.
   * assets/: Standard Expo folder for live mobile assets (icons, splash screens).
   * src/: Your components, hooks, and navigation logic.
   * docs/: Mobile-specific documentation (or link back to the main repo's docs).

## 3. Complete /docs Subfolders (GitHub Pages)
This folder is what renders as your public website. [2] 

* docs/
* index.md: The homepage of your documentation site.
   * .nojekyll: A blank file that tells GitHub Pages to treat the folder as a static site.
   * _config.yml: Theme and site metadata configuration.
   * setup/: Environment and installation guides.
   * database.md: Instructions for PostgreSQL/Docker.
      * env-vars.md: Required .env or YAML keys.
      * references.md: Your collection of external resource links and research materials.
   * how-to/: Workflow and "recipe" guides.
   * api-usage.md: Guide for adding new endpoints.
      * mobile-builds.md: Guide for Expo builds and publishing.
      * deployment.md: Instructions for your CI/CD pipeline.
   * assets/: Non-markdown files.
   * /images/:
      * /diagrams/: Final architecture exports (PNG, SVG) and source files (Draw.io).
         * /mobile-ui/: Screenshots of your Expo app.
         * /branding/: Logos and other project-related graphics.
      * /pdf/: Any downloadable documentation or posters. [2, 6, 11, 13, 14] 
   
## 4. What to Keep Out (Cleanliness)

* Zip files: These should be stored in an external "Archive" folder on your local machine or a cloud drive (e.g., Time Machine backups) rather than inside the repo.
* Generated files: Folders like /target, /build, or /node_modules should always be in your .gitignore. [7, 15] 

Does this structure help you visualize where to move your current "mess" of files?

[1] [https://github.com](https://github.com/orgs/community/discussions/189311)
[2] [https://tomcam.github.io](https://tomcam.github.io/least-github-pages/adding-assets-directory-github-pages.html)
[3] [https://appliedtechnology.github.io](https://appliedtechnology.github.io/protips/folderstructure.html)
[4] [https://rifaiio.medium.com](https://rifaiio.medium.com/spring-boot-project-structure-best-practices-layer-based-vs-feature-based-explained-simply-4a9002f3cff0)
[5] [https://www.reddit.com](https://www.reddit.com/r/learnprogramming/comments/8u8rrv/what_should_a_github_repo_include_what_is_the/)
[6] [https://github.com](https://github.com/orgs/community/discussions/173482)
[7] [https://www.eevblog.com](https://www.eevblog.com/forum/microcontrollers/github-folder-structure-for-embedded-projects/)
[8] [https://medium.com](https://medium.com/@danilkashalindadsd/uncover-spring-boot-best-folder-structures-for-optimal-coding-1a09b4292763)
[9] [https://www.reddit.com](https://www.reddit.com/r/SpringBoot/comments/1p6m74v/whats_the_cleanest_way_to_structure_a_spring_boot/)
[10] [https://github.com](https://github.com/arsy786/springboot-best-practices)
[11] [https://www.themikeburke.com](https://www.themikeburke.com/purposeful-project-folder-structure/)
[12] [https://worldbank.github.io](https://worldbank.github.io/template/docs/folders-and-naming.html)
[13] [https://github.com](https://github.com/orgs/community/discussions/39667)
[14] [https://github.com](https://github.com/structuredscience/ProjectDirectoryTemplate)
[15] [https://www.youtube.com](https://www.youtube.com/watch?v=NgWd51KfyOY)
