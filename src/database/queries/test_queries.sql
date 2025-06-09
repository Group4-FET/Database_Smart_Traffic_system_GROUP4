-- Check unique email constraint
SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

-- Join traffic_data and cameras to verify foreign key integrity
SELECT t.traffic_id, c.location_name
FROM traffic_data t
JOIN cameras c ON t.camera_id = c.camera_id
WHERE t.congestion_level = 'High' LIMIT 5;

-- Performance test with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT t.latitude, t.longitude, t.congestion_level
FROM traffic_data t
WHERE t.congestion_level = 'High' LIMIT 5;