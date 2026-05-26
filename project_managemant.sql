CREATE DATABASE it_project_management_db;

CREATE TABLE projects (
  projectid   integer PRIMARY KEY,
  projectname text NOT NULL
);

CREATE TABLE assignees (
  assigneeid   integer PRIMARY KEY,
  assigneename text NOT NULL
);

CREATE TABLE tasks (
  taskid     integer PRIMARY KEY,
  projectid  integer NOT NULL REFERENCES projects(projectid),
  taskname   text NOT NULL,
  status     text NOT NULL,
  priority   text,
  due_date   date
);

CREATE TABLE task_assignees (
  taskid     integer NOT NULL REFERENCES tasks(taskid),
  assigneeid integer NOT NULL REFERENCES assignees(assigneeid),
  PRIMARY KEY (taskid, assigneeid)
);

CREATE TABLE project_assignees (
  projectid  integer NOT NULL REFERENCES projects(projectid),
  assigneeid integer NOT NULL REFERENCES assignees(assigneeid),
  PRIMARY KEY (projectid, assigneeid)
);

CREATE INDEX idx_tasks_projectid ON tasks(projectid);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);