---
title: Optimization
description: A reference page in my new Starlight docs site.
---

1. `TIMESTAMPTZ` over `TIMESTAMP`

---

Using GenerationType.AUTO is generally considered bad practice for production-grade applications. While it is convenient for quick prototyping, its unpredictability and potential performance issues make it a liability in complex environments. [1, 2] 
## Why It Is Avoided

* Unpredictability: It allows the persistence provider (like Hibernate) to choose the strategy based on the database. This can lead to different behaviors in development versus production if different databases are used. [3, 4, 5, 6, 7] 
* Performance Penalties: In some versions of Hibernate (e.g., version 5 with MySQL), AUTO defaults to the TABLE strategy. This strategy uses a separate database table to track IDs, which involves frequent locking and extra updates, significantly slowing down performance. [8, 9] 
* Single Sequence Bottlenecks: By default, AUTO often uses a single global sequence (like hibernate_sequence) for all tables. This can cause gaps in IDs and creates a central point of contention in high-concurrency systems. [10, 11, 12] 
* Lack of Portability Control: While intended to be portable, it often forces the use of a strategy that might not be optimal for a specific database, such as preventing the use of high-performance batch inserts when IDENTITY is selected. [13] 

## Better Alternatives

| Strategy [1, 8, 14, 15, 16] | Best Use Case | Benefits |
|---|---|---|
| IDENTITY | MySQL, SQL Server | Simple, uses database-native auto-incrementing columns. |
| SEQUENCE | PostgreSQL, Oracle[](https://www.oracle.com/) | Highly efficient; supports batching and is more scalable than IDENTITY. |
| UUID | Distributed Systems | Globally unique IDs that don't require database coordination, preventing collisions across multiple instances. |

## When is it OK to use?

* Prototyping: For small, local projects where you want to get up and running quickly without worrying about database-specific configurations. [17, 18] 
* Strictly Portable Apps: In rare multi-tenant SaaS products where customers bring their own (unknown) database types, and you need a "safe" default. [17] 


[1] [https://medium.com](https://medium.com/javarevisited/what-can-go-wrong-with-generatedvalue-in-multiinstance-environment-5ffb2d714960)
[2] [https://stackoverflow.com](https://stackoverflow.com/questions/74162316/is-there-a-limitation-to-jpa-generated-id)
[3] [https://stackoverflow.com](https://stackoverflow.com/questions/13062759/can-i-change-default-auto-value-for-generationtype-in-generatedvalue-for-pers)
[4] [https://stackoverflow.com](https://stackoverflow.com/questions/43648696/generationtype-auto-not-picking-appropriate-strategy)
[5] [https://docs.hibernate.org](https://docs.hibernate.org/jpa/2.1/api/javax/persistence/GenerationType.html)
[6] [https://stackoverflow.com](https://stackoverflow.com/questions/25047226/jpa-generationtype-auto-not-considering-column-with-auto-increment)
[7] [https://ctofraction.com](https://ctofraction.com/blog/why-your-test-environment-must-be-identical-to-production/)
[8] [https://www.linkedin.com](https://www.linkedin.com/pulse/why-how-avoid-auto-generator-type-hibernate-5-mysql-prateek-ashtikar)
[9] [https://medium.com](https://medium.com/@sybrenbolandit/hibernate-id-generation-strategies-d359f3809049)
[10] [https://stackoverflow.com](https://stackoverflow.com/questions/5676636/why-most-hibernate-applications-are-using-sequence-for-id-generation)
[11] [https://stackoverflow.com](https://stackoverflow.com/questions/33096466/generationtype-auto-vs-generationtype-identity-in-hibernate)
[12] [https://learn.microsoft.com](https://learn.microsoft.com/en-us/answers/questions/1239209/how-to-avoid-or-disable-sql-local-db-id-jump)
[13] [https://stackoverflow.com](https://stackoverflow.com/questions/51778862/when-is-data-persisted-to-the-database-when-using-generationtype-identity-vs-gen)
[14] [https://www.youtube.com](https://www.youtube.com/watch?v=T3SbQGWpyGo)
[15] [https://blog.cloudneutral.se](https://blog.cloudneutral.se/jpa-best-practices-identity-generators)
[16] [https://www.reddit.com](https://www.reddit.com/r/javahelp/comments/16yxvmt/database_auto_id_generation/)
[17] [https://medium.com](https://medium.com/@gaddamnaveen192/complete-guide-to-jpa-id-generation-auto-identity-sequence-and-table-3044891e88af)
[18] [https://wolverinefx.net](https://wolverinefx.net/guide/codegen)


---

For a social app using Spring Boot and PostgreSQL, you should use a hybrid approach tailored to the specific type of data each table holds.
## Recommended Strategy by Table Type## 1. Use GenerationType.SEQUENCE (For Core Data & High-Volume Content)
PostgreSQL handles sequences exceptionally well. This is your default choice for most tables because it supports efficient batch inserts (unlike IDENTITY).

* Best for: posts, comments, likes, follows, notifications.
* Why: Social apps require high-write throughput. Sequences allow Hibernate to pre-allocate blocks of IDs in memory, reducing database round-trips when a user creates content or likes a post.
* Implementation: Use a unique sequence per table to avoid a global bottleneck.

## 2. Use UUID (For Public-Facing Entities)
Exposing sequential integer IDs (like /users/1 or /posts/42) in your API URLs creates security risks (enumeration attacks) and leaks business growth metrics to competitors.

* Best for: users, accounts, or public posts/stories if you want unguessable URLs.
* Why: Prevents users from guessing other users' IDs, secures API endpoints, and simplifies merging databases if you scale to multiple regions later.
* Implementation: Use PostgreSQL's native uuid data type.

---

## Entity Implementation Examples
Here is how to write the code for your Spring Boot entities:

## The Sequence Approach (posts table)

@Entity
@Table(name = "posts")public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "post_seq")
    @SequenceGenerator(name = "post_seq", sequenceName = "posts_id_seq", allocationSize = 50)
    private Long id;
    
    // other fields...
}

Note: Setting allocationSize = 50 tells Hibernate to fetch 50 IDs at a time, maximizing performance.
## The UUID Approach (users table)

```java
@Entity
@Table(name = "users")public class User {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "UUID")
    private UUID id;

    // other fields...
}
```


To help refine your architecture, let me know:

* What scale of traffic or users are you planning for initially?
* Do you plan to use sharding or multiple database instances in the near future?
* Are there any specific tables you are worried about regarding write performance?


