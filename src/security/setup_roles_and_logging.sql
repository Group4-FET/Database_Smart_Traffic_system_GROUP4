-- Create roles
CREATE ROLE commuter_role;
CREATE ROLE traffic_manager_role;
CREATE ROLE operator_role;
CREATE ROLE technician_role;
CREATE ROLE admin_role;

-- Grant permissions to roles based on use cases
GRANT SELECT ON users, commuters, user_alerts, alerts TO commuter_role;
GRANT SELECT, INSERT, UPDATE ON traffic_data, incidents, alerts, analytics_reports TO traffic_manager_role;
GRANT SELECT, INSERT, UPDATE ON vehicles, vehicle_routes TO operator_role;
GRANT SELECT, INSERT, UPDATE ON cameras, maintenance_logs TO technician_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO admin_role;

-- Create user accounts and assign roles
CREATE USER commuter_user WITH PASSWORD 'secure_password1';
CREATE USER traffic_manager_user WITH PASSWORD 'secure_password2';
CREATE USER operator_user WITH PASSWORD 'secure_password3';
CREATE USER technician_user WITH PASSWORD 'secure_password4';
CREATE USER admin_user WITH PASSWORD 'secure_password5';

GRANT commuter_role TO commuter_user;
GRANT traffic_manager_role TO traffic_manager_user;
GRANT operator_role TO operator_user;
GRANT technician_role TO technician_user;
GRANT admin_role TO admin_user;

-- Create audit log table
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100),
    table_name VARCHAR(100),
    record_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, timestamp)
    VALUES (
        CURRENT_USER,
        TG_OP,
        TG_TABLE_NAME,
        CASE
            WHEN TG_OP = 'INSERT' THEN NEW.*::text
            WHEN TG_OP = 'UPDATE' THEN NEW.*::text
            WHEN TG_OP = 'DELETE' THEN OLD.*::text
        END,
        CURRENT_TIMESTAMP
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers to critical tables
CREATE TRIGGER user_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER traffic_data_audit
AFTER INSERT OR UPDATE OR DELETE ON traffic_data
FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER incidents_audit
AFTER INSERT OR UPDATE OR DELETE ON incidents
FOR EACH ROW EXECUTE FUNCTION audit_trigger();