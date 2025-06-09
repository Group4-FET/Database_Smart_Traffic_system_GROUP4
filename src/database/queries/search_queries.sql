-- Query 1: High congestion traffic data
-- Algebraic Tree: σ(congestion_level='High')(traffic_data)
SELECT traffic_id, congestion_level
FROM traffic_data
WHERE congestion_level = 'High';

-- Query 2: Vehicles by type
-- Algebraic Tree: σ(vehicle_type='Bus')(vehicles)
SELECT vehicle_id, vehicle_type
FROM vehicles
WHERE vehicle_type = 'Bus';

-- Query 3: Unread alerts
-- Algebraic Tree: σ(is_read=false)(user_alerts)
SELECT user_id, alert_id
FROM user_alerts
WHERE is_read = FALSE;

-- Query 4: Active incidents
-- Algebraic Tree: σ(status='Open')(incidents)
SELECT incident_id, status
FROM incidents
WHERE status = 'Open';

-- Query 5: Active routes
-- Algebraic Tree: σ(is_active=true)(routes)
SELECT route_id, route_name
FROM routes
WHERE is_active = TRUE;