CREATE ROLE commuter_role;
CREATE ROLE traffic_manager_role;
CREATE ROLE operator_role;
CREATE ROLE technician_role;
CREATE ROLE admin_role;

GRANT SELECT ON users, commuters, user_alerts, alerts TO commuter_role;
GRANT SELECT, INSERT, UPDATE ON traffic_data, incidents, alerts, analytics_reports TO traffic_manager_role;
GRANT SELECT, INSERT, UPDATE ON vehicles, vehicle_routes TO operator_role;
GRANT SELECT, INSERT, UPDATE ON cameras, maintenance_logs TO technician_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO admin_role;

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100),
    table_name VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (CURRENT_USER, TG_OP, TG_TABLE_NAME, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER traffic_data_audit
AFTER INSERT OR UPDATE OR DELETE ON traffic_data
FOR EACH ROW EXECUTE FUNCTION audit_trigger();