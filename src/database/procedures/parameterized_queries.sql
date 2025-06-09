-- Get traffic records by congestion level
CREATE OR REPLACE FUNCTION get_traffic_by_level(p_congestion_level VARCHAR)
RETURNS TABLE (
    traffic_id VARCHAR,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.traffic_id, t.latitude, t.longitude
    FROM traffic_data t
    WHERE t.congestion_level = p_congestion_level;
END;
$$ LANGUAGE plpgsql;


-- Get vehicles by type
CREATE OR REPLACE FUNCTION get_vehicles_by_type(p_vehicle_type VARCHAR)
RETURNS TABLE (vehicle_id VARCHAR, plate_number VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT v.vehicle_id, v.plate_number
    FROM vehicles v
    WHERE v.vehicle_type = p_vehicle_type;
END;
$$ LANGUAGE plpgsql;

-- Get unread alerts for a user
CREATE OR REPLACE FUNCTION get_unread_alerts(p_user_id VARCHAR)
RETURNS TABLE (alert_id VARCHAR, sent_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT ua.alert_id, ua.sent_at
    FROM user_alerts ua
    WHERE ua.user_id = p_user_id AND ua.is_read = FALSE;
END;
$$ LANGUAGE plpgsql;

-- Get incidents filtered by severity
CREATE OR REPLACE FUNCTION get_incidents_by_severity(p_severity VARCHAR)
RETURNS TABLE (incident_id VARCHAR, description TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT i.incident_id, i.description
    FROM incidents i
    WHERE i.severity = p_severity;
END;
$$ LANGUAGE plpgsql;

-- Get all active routes
CREATE OR REPLACE FUNCTION get_active_routes()
RETURNS TABLE (route_id VARCHAR, route_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT r.route_id, r.route_name
    FROM routes r
    WHERE r.is_active = TRUE;
END;
$$ LANGUAGE plpgsql;
