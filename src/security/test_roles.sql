-- Test commuter_role
SET ROLE commuter_user;
SELECT user_id, username FROM users LIMIT 1; -- Should succeed
SELECT alert_id, message FROM alerts LIMIT 1; -- Should succeed
INSERT INTO traffic_data (traffic_id, camera_id, location_name, congestion_level, recorded_at) 
VALUES ('TRF_TEST', 'CAM001', 'Test Location', 'Low', CURRENT_TIMESTAMP); -- Should fail (no INSERT permission)
RESET ROLE;

-- Test traffic_manager_role
SET ROLE traffic_manager_user;
SELECT traffic_id, congestion_level FROM traffic_data LIMIT 1; -- Should succeed
INSERT INTO incidents (incident_id, reporter_id, incident_type, location_name, severity, reported_at, status)
VALUES ('INC_TEST', 'CMT001', 'Test Incident', 'Test Location', 'Low', CURRENT_TIMESTAMP, 'Open'); -- Should succeed
SELECT plate_number FROM vehicles LIMIT 1; -- Should fail (no SELECT permission)
RESET ROLE;

-- Test operator_role
SET ROLE operator_user;
SELECT vehicle_id, plate_number FROM vehicles LIMIT 1; -- Should succeed
UPDATE vehicle_routes SET status = 'Completed' WHERE vehicle_id = 'VEH001' AND route_id = 'RTE001'; -- Should succeed
SELECT congestion_level FROM traffic_data LIMIT 1; -- Should fail (no SELECT permission)
RESET ROLE;

-- Test technician_role
SET ROLE technician_user;
SELECT camera_id, status FROM cameras LIMIT 1; -- Should succeed
INSERT INTO maintenance_logs (log_id, camera_id, technician_id, maintenance_type, scheduled_at, status)
VALUES ('LOG_TEST', 'CAM001', 'USR004', 'Test Maintenance', CURRENT_TIMESTAMP, 'Scheduled'); -- Should succeed
SELECT message FROM alerts LIMIT 1; -- Should fail (no SELECT permission)
RESET ROLE;

-- Test admin_role
SET ROLE admin_user;
SELECT * FROM users LIMIT 1; -- Should succeed
INSERT INTO routes (route_id, route_name, start_location, end_location, created_at, is_active)
VALUES ('RTE_TEST', 'Test Route', 'Start', 'End', CURRENT_TIMESTAMP, TRUE); -- Should succeed
DELETE FROM cameras WHERE camera_id = 'CAM001'; -- Should succeed
RESET ROLE;

-- Check audit logs
SELECT log_id, user_id, action, table_name, timestamp FROM audit_log ORDER BY timestamp DESC LIMIT 10;