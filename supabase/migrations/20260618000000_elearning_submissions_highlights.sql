alter table elearning_submissions
  add column if not exists highlights jsonb default '[]'::jsonb;
