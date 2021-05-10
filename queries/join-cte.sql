explain (format text, verbose, analyze, buffers)
with recent_posts as (
  select *
  from posts
  order by id desc
  limit 50
)
select
  p.id,
  p.title,
  u.username
from recent_posts p
left join users u
on p.user_id = u.id;

/*
explain (format text, verbose, analyze, buffers)
select
  p.id,
  p.title,
  u.username
from posts p
left join users u
on p.user_id = u.id
order by id desc
limit 50;
*/

