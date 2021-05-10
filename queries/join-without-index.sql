explain (format text, verbose, analyze, buffers)
select
  p.id,
  p.title,
  u.username
from posts p
left join users u
on p.title = u.first_name;

