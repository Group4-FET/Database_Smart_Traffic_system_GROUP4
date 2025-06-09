CREATE OR REPLACE FUNCTION check_vehicle_route_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_time < NEW.start_time THEN
        RAISE EXCEPTION 'End time cannot be earlier than start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vehicle_route_time_check
BEFORE INSERT OR UPDATE ON vehicle_routes
FOR EACH ROW EXECUTE FUNCTION check_vehicle_route_time();