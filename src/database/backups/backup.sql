-- Full backup
pg_dump -U postgres -d traffic_management > backup_full_$(date +%F).sql

-- Enable WAL
ALTER SYSTEM SET wal_level = logical;
SELECT pg_create_physical_replication_slot('traffic_slot');

-- Recovery procedure
CREATE OR REPLACE PROCEDURE recover_database(p_backup_file VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP DATABASE IF EXISTS traffic_management;
    CREATE DATABASE traffic_management;
    \! psql -U postgres -d traffic_management -f p_backup_file
END;
$$;