---
title: ID
description: Gemini info on ID generation.
sidebar_position: 1
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

------------------------------
## Entity Implementation Examples
Here is how to write the code for your Spring Boot entities:
## The Sequence Approach (posts table)

```sql
@Entity
@Table(name = "posts")public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "post_seq")
    @SequenceGenerator(name = "post_seq", sequenceName = "posts_id_seq", allocationSize = 50)
    private Long id;
    
    // other fields...
}
```

Note: Setting allocationSize = 50 tells Hibernate to fetch 50 IDs at a time, maximizing performance.
## The UUID Approach (users table)

```sql
@Entity
@Table(name = "users")public class User {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "UUID")
    private UUID id;

    // other fields...
}
```

------------------------------
To help refine your architecture, let me know:

* What scale of traffic or users are you planning for initially?
* Do you plan to use sharding or multiple database instances in the near future?
* Are there any specific tables you are worried about regarding write performance?


---

In PostgreSQL, both Identity Columns and Standalone Sequences are used to generate numeric values (usually for primary keys). While identity columns are the modern standard, standalone sequences offer greater flexibility for complex scenarios. [1, 2, 3, 4, 5] 
## Key Differences

| Feature [2, 6, 7, 8, 9, 10, 11, 12] | Identity Column (GENERATED AS IDENTITY) | Standalone Sequence (CREATE SEQUENCE) |
|---|---|---|
| SQL Standard | Standard-compliant (SQL:2003+). | Non-standard/Proprietary. |
| Dependency | Implicitly tied to a specific table column. | Independent database object. |
| Management | Managed via ALTER TABLE. | Managed via ALTER SEQUENCE. |
| Sharing | Cannot be shared across multiple tables. | Can be used by multiple tables or columns. |
| Visibility | Part of the table definition in the schema. | Often hidden as a background object. |

------------------------------
## 1. Identity Columns (Recommended)
Introduced in PostgreSQL 10, Identity Columns are the preferred way to handle auto-incrementing values. They replace the older SERIAL type and offer better integration with standard SQL. [1, 13, 14, 15] 

* Cleaner Management: The sequence is automatically dropped if the table or column is deleted. [12, 16] 
* Two Generation Modes:
* GENERATED ALWAYS: Prevents manual insertion of values unless OVERRIDING SYSTEM VALUE is used.
   * GENERATED BY DEFAULT: Allows you to provide your own value, which overrides the sequence for that row. [17, 18] 
* Modern Support: Better compatibility with PostgreSQL Logical Replication. [2] 

## 2. Standalone Sequences
A Sequence is a separate object created manually using CREATE SEQUENCE. [8] 

* Manual Control: You must manually link it to a table column using the DEFAULT nextval('seq_name') expression.
* Global Use Case: Best used when you need a single counter shared across multiple tables (e.g., a "global ID" for Car, Hotel, and Flight bookings).
* Pre-fetching: You can fetch a value using SELECT nextval('my_seq') before performing an INSERT, which is useful for complex application logic. [8, 11, 19, 20, 21] 

## Which should you choose?

* Use Identity Columns for standard primary keys in almost all new database designs. They are safer, cleaner, and strictly tied to the table's lifecycle. [2, 4] 
* Use Standalone Sequences only if you need advanced features like sharing a sequence between tables or manually generating values outside of a table's context. [2, 9] 


[1] [https://java-jedi.medium.com](https://java-jedi.medium.com/the-evolution-of-primary-keys-in-postgresql-from-serial-to-identity-and-beyond-f62662bc2595)
[2] [https://kb.combell-sre.net](https://kb.combell-sre.net/faq/postgresql_identity_sequence/)
[3] [https://sadalage.com](https://sadalage.com/post/id-generation/)
[4] [https://www.cybertec-postgresql.com](https://www.cybertec-postgresql.com/en/uuid-serial-or-identity-columns-for-postgresql-auto-generated-primary-keys/)
[5] [https://www.habilelabs.io](https://www.habilelabs.io/blog/sequences-in-postgresql)
[6] [https://neon.com](https://neon.com/postgresql/postgresql-tutorial/postgresql-identity-column)
[7] [https://pysql.tecladocode.com](https://pysql.tecladocode.com/section05/lectures/07_sequence_vs_serial_postgresql/)
[8] [https://docs.aws.amazon.com](https://docs.aws.amazon.com/dms/latest/sql-server-to-aurora-postgresql-migration-playbook/chap-sql-server-aurora-pg.tsql.sequences.html)
[9] [https://stackoverflow.com](https://stackoverflow.com/questions/10062328/sequence-vs-identity)
[10] [https://stackoverflow.com](https://stackoverflow.com/questions/49696724/should-we-use-sequences-or-identities-for-our-primary-keys)
[11] [https://www.red-gate.com](https://www.red-gate.com/simple-talk/databases/sql-server/identity-vs-sequence-in-sql-server-which-should-you-use/)
[12] [https://www.naiyerasif.com](https://www.naiyerasif.com/post/2024/09/04/stop-using-serial-in-postgres/)
[13] [https://www.bytebase.com](https://www.bytebase.com/reference/postgres/how-to/how-to-use-identity-column-postgres/)
[14] [https://www.bytebase.com](https://www.bytebase.com/reference/postgres/how-to/how-to-use-identity-column-postgres/)
[15] [https://www.npgsql.org](https://www.npgsql.org/efcore/modeling/generated-properties.html)
[16] [https://www.reddit.com](https://www.reddit.com/r/PostgreSQL/comments/1ffqsvw/stop_using_serial_in_postgres/)
[17] [https://www.reddit.com](https://www.reddit.com/r/PostgreSQL/comments/1ae4lee/create_sequence_and_table_in_one_transaction/)
[18] [https://www.youtube.com](https://www.youtube.com/watch?v=KZtWSgmwTaE&t=5)
[19] [https://www.youtube.com](https://www.youtube.com/watch?v=ZSzErySj3cI)
[20] [https://www.youtube.com](https://www.youtube.com/watch?v=hpL9C5FWIRk)
[21] [https://www.commandprompt.com](https://www.commandprompt.com/education/how-to-create-an-auto-increment-column-using-sequences-in-postgresql/)

---

Using an independent Standalone Sequence is the best choice when multiple entities (tables) need to share a single, unified ID counter.
Here is exactly how to set up and use a global sequence for multiple tables.
## The Setup: One Counter, Multiple Tables
This approach creates one sequence object. Two different tables then pull their primary keys from that same object.

-- 1. Create the global sequenceCREATE SEQUENCE global_id_seq START WITH 1000;
-- 2. Create the first entity table (e.g., Users)CREATE TABLE app_users (
    user_id BIGINT PRIMARY KEY DEFAULT nextval('global_id_seq'),
    username VARCHAR(50) NOT NULL
);
-- 3. Create the second entity table (e.g., Organizations)CREATE TABLE organizations (
    org_id BIGINT PRIMARY KEY DEFAULT nextval('global_id_seq'),
    org_name VARCHAR(100) NOT NULL
);

## How It Works In Practice
Because both tables share the same counter, their IDs will never overlap.

-- Insert into UsersINSERT INTO app_users (username) VALUES ('alice'), ('bob');
-- Insert into OrganizationsINSERT INTO organizations (org_name) VALUES ('Acme Corp');

Resulting Data:

* app_users
* 1000 | alice
   * 1001 | bob
* organizations
* 1002 | Acme Corp

## Important Consideration: Ownership
By default, if you drop app_users, the sequence stays alive because it is independent. If you want the sequence to delete automatically only when the entire database schema is wiped, leave it unlinked.
If you want it to delete when a specific "master" table is dropped, you can link it:

ALTER SEQUENCE global_id_seq OWNED BY app_users.user_id;

------------------------------
To help tailor this setup, what types of entities are you connecting, and do you need to track the entity type in a central table?

