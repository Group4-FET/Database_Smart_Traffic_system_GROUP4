CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Commuter', 'TrafficManager', 'Operator', 'Technician')),
    phone_number VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE traffic_managers (
    manager_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES users(user_id) ON DELETE CASCADE,
    department VARCHAR(100),
    authority_level VARCHAR(50),
    assigned_at TIMESTAMP
);

CREATE TABLE commuters (
    commuter_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES users(user_id) ON DELETE CASCADE,
    preferences TEXT,
    notification_settings TEXT,
    registered_at TIMESTAMP
);

CREATE TABLE transport_operators (
    operator_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES users(user_id) ON DELETE CASCADE,
    company_name VARCHAR(100),
    license_number VARCHAR(50) UNIQUE,
    vehicle_types TEXT,
    licensed_at TIMESTAMP
);

CREATE TABLE cameras (
    camera_id VARCHAR(50) PRIMARY KEY,
    location_name VARCHAR(100),
    ip_address VARCHAR(45),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    camera_type VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    installed_at TIMESTAMP,
    last_maintenance TIMESTAMP,
    status VARCHAR(50)
);

CREATE TABLE image_data (
    image_id VARCHAR(50) PRIMARY KEY,
    camera_id VARCHAR(50) REFERENCES cameras(camera_id) ON DELETE CASCADE,
    image_path VARCHAR(255),
    file_size VARCHAR(50),
    resolution VARCHAR(50),
    captured_at TIMESTAMP,
    image_metadata VARCHAR(255),
    processed BOOLEAN DEFAULT FALSE
);

CREATE TABLE traffic_data (
    traffic_id VARCHAR(50) PRIMARY KEY,
    camera_id VARCHAR(50) REFERENCES cameras(camera_id) ON DELETE CASCADE,
    image_id VARCHAR(50) REFERENCES image_data(image_id) ON DELETE SET NULL,
    location_name VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    congestion_level VARCHAR(50),
    vehicle_count INTEGER CHECK (vehicle_count >= 0),
    average_speed DECIMAL(5,2) CHECK (average_speed >= 0),
    recorded_at TIMESTAMP,
    weather_condition VARCHAR(50)
);

CREATE TABLE vehicles (
    vehicle_id VARCHAR(50) PRIMARY KEY,
    operator_id VARCHAR(50) REFERENCES transport_operators(operator_id) ON DELETE CASCADE,
    plate_number VARCHAR(50) UNIQUE,
    vehicle_type VARCHAR(50),
    model VARCHAR(100),
    capacity INTEGER CHECK (capacity > 0),
    current_latitude DECIMAL(9,6),
    current_longitude DECIMAL(9,6),
    last_updated TIMESTAMP,
    status VARCHAR(50)
);

CREATE TABLE routes (
    route_id VARCHAR(50) PRIMARY KEY,
    route_name VARCHAR(100),
    start_location VARCHAR(100),
    end_location VARCHAR(100),
    waypoints TEXT,
    distance_km DECIMAL(7,2),
    estimated_time_minutes INTEGER,
    created_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE vehicle_routes (
    vehicle_id VARCHAR(50) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    route_id VARCHAR(50) REFERENCES routes(route_id) ON DELETE CASCADE,
    assigned_at TIMESTAMP,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50),
    PRIMARY KEY (vehicle_id, route_id)
);

CREATE TABLE incidents (
    incident_id VARCHAR(50) PRIMARY KEY,
    reporter_id VARCHAR(50) REFERENCES commuters(commuter_id) ON DELETE CASCADE,
    incident_type VARCHAR(50),
    location_name VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    description TEXT,
    severity VARCHAR(50),
    reported_at TIMESTAMP,
    resolved_at TIMESTAMP,
    status VARCHAR(50),
    assigned_officer VARCHAR(50)
);

CREATE TABLE alerts (
    alert_id VARCHAR(50) PRIMARY KEY,
    alert_type VARCHAR(50),
    title VARCHAR(100),
    message TEXT,
    severity VARCHAR(50),
    target_audience VARCHAR(100),
    created_at TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_by_id VARCHAR(50) REFERENCES traffic_managers(manager_id) ON DELETE CASCADE
);

CREATE TABLE user_alerts (
    user_id VARCHAR(50) REFERENCES users(user_id) ON DELETE CASCADE,
    alert_id VARCHAR(50) REFERENCES alerts(alert_id) ON DELETE CASCADE,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    delivery_method VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, alert_id)
);

CREATE TABLE analytics_reports (
    report_id VARCHAR(50) PRIMARY KEY,
    generated_by_id VARCHAR(50) REFERENCES traffic_managers(manager_id) ON DELETE CASCADE,
    report_type VARCHAR(50),
    title VARCHAR(100),
    data_summary TEXT,
    generated_at TIMESTAMP,
    period_start TIMESTAMP,
    period_end TIMESTAMP,
    file_path VARCHAR(255)
);

CREATE TABLE maintenance_logs (
    log_id VARCHAR(50) PRIMARY KEY,
    camera_id VARCHAR(50) REFERENCES cameras(camera_id) ON DELETE CASCADE,
    technician_id VARCHAR(50) REFERENCES users(user_id) ON DELETE CASCADE,
    maintenance_type VARCHAR(50),
    description TEXT,
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    status VARCHAR(50),
    cost DECIMAL(10,2)
);

CREATE TABLE route_traffic_data (
    route_id VARCHAR(50) REFERENCES routes(route_id) ON DELETE CASCADE,
    traffic_id VARCHAR(50) REFERENCES traffic_data(traffic_id) ON DELETE CASCADE,
    analyzed_at TIMESTAMP,
    impact_score DECIMAL(5,2),
    PRIMARY KEY (route_id, traffic_id)
);