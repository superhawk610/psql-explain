# PSQL EXPLAIN

To have a query explained, use this syntax:

```sql
/* available formats include text, json, xml, and yaml */
explain (format text, verbose, analyze, buffers)
select
  p.id,
  p.title,
  u.username
from posts p
left join users u
on p.user_id = u.id;
```

To explain a query (stored in `query.sql`):

```bash
psql -d [database] -XqAt -f query.sql > explain.txt
```

This assumes that the query is using `explain (format text)`. If you're using
another format, write to the appropriate file type.

## Common Operations

When explaining queries, here are some terms you should be familiar with:

- `Seq Scan` (sequential scan) - this is the most basic approach PG can
    use to read rows from a table, row by row; it must traverse the entire table
    dataset, so this is generally the slowest operation
- `Index Scan` - unlike a sequential scan, this operation determines the
    location to read from using an index, then performs a much smaller read
    per-row (this is only possible when an index exists)
- `Index Only Scan` - if an index scan doesn't require reading any non-indexed
    column values, the 2nd memory access can be avoided entirely
- `Bitmap Scan` - the "happy medium" between a seq and index scan; preferred
    when the result set size is likely too large to outweigh the additional
    reads incurred by an index scan, but also not expected to select the full
    result set
- `Nested Loop Join` - this is the most basic approach PG can use to join rows
    from multiple tables together; you can think of it like a nested for loop;
    it will operate in `O(M*N)` time (quite slow), but will work in any situation
- `Hash Join` - generate a lookup for one half of the join, then query against
    it when processing rows from the other half (additional overhead to
    construct lookup outweighed by reducing nested iterations)
- `Merge Join` - (only available when both halves of the join are sorted and are
    joining on equality `=`) walk both halves of the join sequentially and emit
    pairs as they're encountered (like a nested loop, but avoids backtracking)

## What is an index?

Without going into too much detail, an **index** is an **ordered** mapping from one
or more table columns to rows in the table. For example, if a `posts` table had
an index on `user_id`, you can imagine the index as something like:

```plain
# table
+------+----+----------------------------+
| addr | id | user_id | title            |
+------+----+---------+------------------+
| 0x01 |  1 |       1 | 'Hello, world!'  |
| 0x02 |  3 |       2 | 'ABBPM'          |
| 0x03 |  1 |       1 | 'Elixir is cool' |
+------+----+---------+------------------+

# index on posts(user_id)
+---------+-------------+
| user_id | row_pointer |
+---------+-------------+
|       1 |       *0x01 |
|       1 |       *0x03 |
|       2 |       *0x02 |
+---------+-------------+
```

Instead of traversing the table row-by-row (where rows with the same `user_id`
may not be anywhere near each other), the index is kept sorted by `user_id` and
allows for quick random access, which can in turn be translated to row values by
following the `row_pointer`.

The key characteristics that make indices valuable is that they are **ordered**
(they can be trivially traversered in a deterministic order) and that they support
performant **random lookup** (values corresponding to a given key may be quickly
retrieved without performing a full traversal).

Bitmap scans work in a similar manner, though in two passes: first, the index is
traversed in memory-page based chunks, flipping a bit to indicate when a page is
found that contains a match. Then, any further indices are also traversed,
flipping bits in additional bitmaps. Once all indices have been processed, the
resulting bitmaps are AND'd together, and only then is the underlying memory
accessed to return rows. This avoids any unnecessary memory access.

For example:

```plain
0 1 2 3 4 5 6 7 8 9 a b c  memory page
-------------------------
1 _ _ _ _ 1 _ _ _ 1 _ _ 1  <-- Index 1
_ _ _ 1 _ 1 _ _ _ 1 1 _ 1  <-- Index 2

_ _ _ _ _ 1 _ _ _ 1 _ _ 1 (only these three memory pages need to be read)
```

## Visualizers

To run `pev2`, grab `pev2.tar.gz` from [this link][pev2], extract it, then open
it up in your favorite browser.

[pev2]: https://github.com/dalibo/pev2/releases/latest

## Database Structure

Here's a SQL script to set up the tables in the demo database:

```sql
create database explain_demo;

create table users (
  id bigserial not null primary key,
  username varchar(255) not null,
  email varchar(255) not null,
  first_name varchar(255),
  last_name varchar(255),
  inserted_at timestamp(0) without time zone not null,
  updated_at timestamp(0) without time zone not null,
);

create table posts (
  id bigserial not null primary key,
  user_id bigint not null references users(id),
  title varchar(150) not null,
  body text not null,
  inserted_at timestamp(0) without time zone not null,
  updated_at timestamp(0) without time zone not null,
);
```

## Queries

Here are some queries you'd expect to see during normal application usage (no no
particular order):

```sql
/* basic.sql */

select * from posts;
```

```sql
/* basic-filter.sql */

select * from posts p
where p.id > 100; /* switch from > to < and see what happens! */
```

```sql
/* join.sql */

select
  p.id,
  p.title,
  u.username
from posts p
left join users u
on p.user_id = u.id; /* would you expect this to use an index scan? */
```

```sql
/* limit.sql */

select
  p.id,
  p.title,
  u.first_name,
  u.last_name
from posts p
left join users u
on p.user_id = u.id
limit 5;
```

```sql
/* filter.sql */

select
  p.id,
  p.title,
  u.username
from posts p
left join users u
on p.user_id = u.id
where p.title ilike '%hello%'; /* what if no results are returned? */
```

This query makes use of parallelism on large record sets, splitting the sorting
across multiple workers and then collecting the results using a `Gather Merge`
node (contrast this with the `Gather` node, which is unordered and grabs results
from workers at random).

```sql
/* order_by.sql */

select * from posts
order by title desc;
```

```sql
/* group_by.sql */

select
  count(*),
  u.username
from posts p
left join users u
on p.user_id = u.id
group by u.username;
```

This query will select between a sequential scan, index scan, or bitmap scan
based on the expected result size.

```sql
/* scans.sql */

select
  p.id,
  p.title
from posts p
/* seq scan */
where p.id > 100;
/* index scan */
where p.id < 100;
/* bitmap scan */
where p.id > 10000;
```

## Other Goodies

The visualizer also supports some other neat features we don't have time to
explore today (such as visualizing parallel workers). If you load it up locally,
you can choose one of any of the provided example queries to quickly test drive
these additional features without spinning up a DB instance as well.

## Further Reading

Here are a few resources I found helpful:

- [EXPLAIN - PostgreSQL Documentation](https://www.postgresql.org/docs/9.1/sql-explain.html)
- [Using EXPLAIN - PostgreSQL Documentation](https://www.postgresql.org/docs/9.4/using-explain.html)
- [Query Planning](https://www.postgresql.org/docs/9.5/runtime-config-query.html)
- [Reading an EXPLAIN ANALYZE Query Plan](https://thoughtbot.com/blog/reading-an-explain-analyze-query-plan)
- [Understanding Bitmap Heap Scan and Bitmap Index Scan](https://dba.stackexchange.com/questions/119386/understanding-bitmap-heap-scan-and-bitmap-index-scan)
- [Various Auxiliary Plan Nodes in PostgreSQL](https://severalnines.com/database-blog/overview-various-auxiliary-plan-nodes-postgresql)
- [Join Methods in PostgreSQL](https://severalnines.com/database-blog/overview-join-methods-postgresql)
- [Various Scan Methods in PostgreSQL](https://severalnines.com/database-blog/overview-various-scan-methods-postgresql)

