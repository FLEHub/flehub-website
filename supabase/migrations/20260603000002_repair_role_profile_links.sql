/*
  One-time repair for registrations that inserted auth user id as role-table id
  instead of profile_id.
*/

UPDATE learners
SET profile_id = id
WHERE profile_id IS NULL
  AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = learners.id AND p.role = 'learner');

UPDATE teachers
SET profile_id = id
WHERE profile_id IS NULL
  AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = teachers.id AND p.role = 'teacher');

UPDATE schools
SET profile_id = id
WHERE profile_id IS NULL
  AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = schools.id AND p.role = 'school');
