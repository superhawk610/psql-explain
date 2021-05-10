explain (format text, verbose, analyze, buffers)
select
  p.id,
  p.title,
  u.first_name,
  u.last_name
from posts p
left join users u
on p.user_id = u.id
limit 5;

