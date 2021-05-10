explain (format text, verbose, analyze, buffers)
select
  count(*),
  u.username
from posts p
left join users u
on p.user_id = u.id
group by u.username;

