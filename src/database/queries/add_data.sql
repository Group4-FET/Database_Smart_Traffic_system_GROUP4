INSERT INTO users (user_id, username, email, password_hash, role, phone_number, first_name, last_name, created_at, updated_at, is_active)
VALUES ('USR101', 'alice_brown', 'alice.brown@example.com', 'hashed_password', 'Commuter', '237677000101', 'Alice', 'Brown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

INSERT INTO commuters (commuter_id, user_id, preferences, notification_settings, registered_at)
VALUES ('COM101', 'USR101', 'Public Transport', 'Email', CURRENT_TIMESTAMP);

INSERT INTO traffic_data (traffic_id, camera_id, image_id, location_name, latitude, longitude, congestion_level, vehicle_count, average_speed, recorded_at, weather_condition)
VALUES ('TRF101', 'CAM001', 'IMG101', 'Highway 1', 4.163, 9.178, 'Medium', 40, 30.0, CURRENT_TIMESTAMP, 'Clear');

INSERT INTO vehicles (vehicle_id, operator_id, plate_number, vehicle_type, model, capacity, current_latitude, current_longitude, last_updated, status)
VALUES ('VEH101', 'OPR001', 'TM5678CD', 'Bus', 'Volvo B8R', 40, 4.163, 9.178, CURRENT_TIMESTAMP, 'Active');

INSERT INTO incidents (incident_id, reporter_id, incident_type, location_name, latitude, longitude, description, severity, reported_at, status, assigned_officer)
VALUES ('INC101', 'COM101', 'Roadblock', 'Highway 1', 4.165, 9.180, 'Tree fallen on road', 'Medium', CURRENT_TIMESTAMP, 'Open', 'MGR001');