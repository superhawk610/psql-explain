explain (format text, verbose, analyze, buffers)
select
  p.id,
  p.title
from posts p
where p.id < 100;

