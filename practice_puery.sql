
--１個目のクエリ--
SELECT
  p.projectid,
  p.projectname,
  (
    SELECT COUNT(*)
    FROM tasks t1
    WHERE t1.projectid = p.projectid
  ) AS total_tasks,
  (
    SELECT COUNT(*)
    FROM tasks t2
    WHERE t2.projectid = p.projectid
      AND t2.status = 'done'
  ) AS done_tasks,
  (
    (
      SELECT COUNT(*)
      FROM tasks t3
      WHERE t3.projectid = p.projectid
        AND t3.status = 'done'
    )::numeric
    /
    NULLIF((
      SELECT COUNT(*)
      FROM tasks t4
      WHERE t4.projectid = p.projectid
    ), 0)
  ) * 100 AS done_ratio_percent
FROM
  projects p
ORDER BY
  p.projectid;


--２個目のクエリ--
  SELECT
  a.assigneeid,
  a.assigneename,
  COUNT(DISTINCT t.taskid) AS total_tasks,
  COUNT(*) AS raw_count,
  SUM(
    CASE
      WHEN t.status = 'done'
      THEN 1 ELSE 0
    END
  ) AS done_tasks
FROM
  assignees a,
  task_assignees ta,
  tasks t
WHERE
  a.assigneeid = ta.assigneeid
  AND ta.taskid = t.taskid
GROUP BY
  a.assigneeid,
  a.assigneename,
  a.assigneeid
ORDER BY
  total_tasks DESC;

  
--３個目のクエリ--
  SELECT
  t.taskid,
  t.taskname,
  p.projectname,
  a.assigneename,
  t.due_date,
  t.status
FROM
  tasks t
LEFT JOIN projects p
  ON t.projectid = p.projectid
LEFT JOIN task_assignees ta
  ON t.taskid = ta.taskid
LEFT JOIN assignees a
  ON ta.assigneeid = a.assigneeid
WHERE
  (t.status <> 'done' OR t.status IS NULL)
  AND (
    t.due_date < CURRENT_DATE
    OR t.due_date = CURRENT_DATE
    OR t.due_date IS NULL
  )
ORDER BY
  t.due_date DESC,
  p.projectname,
  a.assigneename;

  --４個目のクエリ--
SELECT
  CASE
    WHEN status IS NULL THEN '(unknown status)'
    ELSE status
  END AS status_label,
  COALESCE(priority, '(no priority)') AS priority_label,
  SUM(
    CASE
      WHEN taskid IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS task_count
FROM
  tasks
GROUP BY
  CASE
    WHEN status IS NULL THEN '(unknown status)'
    ELSE status
  END,
  COALESCE(priority, '(no priority)')
ORDER BY
  status_label,
  priority_label;
  
  
  --５個目のクエリ--
  SELECT
  t.taskid,
  t.taskname,
  p.projectname,
  t.status,
  t.priority,
  t.due_date,
  (
    SELECT
      CASE
        WHEN t2.due_date < CURRENT_DATE
             AND t2.status <> 'done'
        THEN TRUE
        ELSE FALSE
      END
    FROM tasks t2
    WHERE t2.taskid = t.taskid
  ) AS is_overdue
FROM
  tasks t
INNER JOIN task_assignees ta
  ON t.taskid = ta.taskid
INNER JOIN assignees a
  ON ta.assigneeid = a.assigneeid
INNER JOIN projects p
  ON t.projectid = p.projectid
WHERE
  a.assigneeid = :assignee_id
  AND t.due_date BETWEEN
    date_trunc('month', CURRENT_DATE)
    AND date_trunc('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day'
ORDER BY
  t.due_date,
  t.taskid;