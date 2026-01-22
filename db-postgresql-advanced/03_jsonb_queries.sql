-- Extract text and integers from JSONB
SELECT 
    title,
    metadata ->> 'environment' AS environment,
    (metadata ->> 'estimated_hours')::INT AS estimated_hours
FROM tasks;

-- Filter by JSON key/value (@>)
SELECT title, metadata 
FROM tasks 
WHERE metadata @> '{"environment": "docker"}';

-- Filter by key existence (?)
SELECT title, metadata 
FROM tasks 
WHERE metadata ? 'estimated_hours';

-- Update JSONB values
UPDATE tasks 
SET metadata = metadata || '{"sprint": 1}'::jsonb
WHERE id = '99999999-9999-4999-8999-999999999999';

UPDATE tasks
SET metadata = jsonb_set(metadata, '{estimated_hours}', '5'::jsonb)
WHERE id = '99999999-9999-4999-8999-999999999999';
