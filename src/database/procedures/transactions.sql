CREATE OR REPLACE PROCEDURE update_vehicle_incident(
    p_vehicle_id VARCHAR,
    p_route_id VARCHAR,
    p_incident_id VARCHAR,
    p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        UPDATE vehicle_routes
        SET status = p_status, end_time = CURRENT_TIMESTAMP
        WHERE vehicle_id = p_vehicle_id AND route_id = p_route_id;

        UPDATE incidents
        SET status = p_status, resolved_at = CURRENT_TIMESTAMP
        WHERE incident_id = p_incident_id;

        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
    END;
END;
$$;