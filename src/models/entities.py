from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    user_id = Column(String, primary_key=True)
    username = Column(String, nullable=False, unique=True)
    email = Column(String, nullable=False, unique=True)
    password_hash = Column(String, nullable=False)
    role = Column(String, nullable=False)
    phone_number = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime)
    is_active = Column(Boolean, nullable=False, default=True)
    traffic_managers = relationship("TrafficManager", back_populates="user")
    commuters = relationship("Commuter", back_populates="user")
    transport_operators = relationship("TransportOperator", back_populates="user")
    user_alerts = relationship("UserAlert", back_populates="user")
    maintenance_logs = relationship("MaintenanceLog", back_populates="technician")

class TrafficManager(Base):
    __tablename__ = 'traffic_managers'
    manager_id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey('users.user_id'), nullable=False)
    department = Column(String)
    authority_level = Column(String)
    assigned_at = Column(DateTime)
    user = relationship("User", back_populates="traffic_managers")
    alerts = relationship("Alert", back_populates="created_by")
    analytics_reports = relationship("AnalyticsReport", back_populates="generated_by")

class Commuter(Base):
    __tablename__ = 'commuters'
    commuter_id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey('users.user_id'), nullable=False)
    preferences = Column(Text)
    notification_settings = Column(Text)
    registered_at = Column(DateTime)
    user = relationship("User", back_populates="commuters")
    incidents = relationship("Incident", back_populates="reporter")

class TransportOperator(Base):
    __tablename__ = 'transport_operators'
    operator_id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey('users.user_id'), nullable=False)
    company_name = Column(String)
    license_number = Column(String, unique=True)
    vehicle_types = Column(Text)
    licensed_at = Column(DateTime)
    user = relationship("User", back_populates="transport_operators")
    vehicles = relationship("Vehicle", back_populates="operator")

class Camera(Base):
    __tablename__ = 'cameras'
    camera_id = Column(String, primary_key=True)
    location_name = Column(String)
    ip_address = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    camera_type = Column(String)
    is_active = Column(Boolean, default=True)
    installed_at = Column(DateTime)
    last_maintenance = Column(DateTime)
    status = Column(String)
    image_data = relationship("ImageData", back_populates="camera")
    traffic_data = relationship("TrafficData", back_populates="camera")
    maintenance_logs = relationship("MaintenanceLog", back_populates="camera")

class ImageData(Base):
    __tablename__ = 'image_data'
    image_id = Column(String, primary_key=True)
    camera_id = Column(String, ForeignKey('cameras.camera_id'), nullable=False)
    image_path = Column(String)
    file_size = Column(String)
    resolution = Column(String)
    captured_at = Column(DateTime)
    image_metadata = Column(Text)
    processed = Column(Boolean, default=False)
    camera = relationship("Camera", back_populates="image_data")
    traffic_data = relationship("TrafficData", back_populates="image")

class TrafficData(Base):
    __tablename__ = 'traffic_data'
    traffic_id = Column(String, primary_key=True)
    camera_id = Column(String, ForeignKey('cameras.camera_id'), nullable=False)
    image_id = Column(String, ForeignKey('image_data.image_id'))
    location_name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    congestion_level = Column(String)
    vehicle_count = Column(Integer)
    average_speed = Column(Float)
    recorded_at = Column(DateTime)
    weather_condition = Column(String)
    camera = relationship("Camera", back_populates="traffic_data")
    image = relationship("ImageData", back_populates="traffic_data")
    route_traffic_data = relationship("RouteTrafficData", back_populates="traffic_data")

class Vehicle(Base):
    __tablename__ = 'vehicles'
    vehicle_id = Column(String, primary_key=True)
    operator_id = Column(String, ForeignKey('transport_operators.operator_id'), nullable=False)
    plate_number = Column(String, unique=True)
    vehicle_type = Column(String)
    model = Column(String)
    capacity = Column(Integer)
    current_latitude = Column(Float)
    current_longitude = Column(Float)
    last_updated = Column(DateTime)
    status = Column(String)
    operator = relationship("TransportOperator", back_populates="vehicles")
    vehicle_routes = relationship("VehicleRoute", back_populates="vehicle")

class Route(Base):
    __tablename__ = 'routes'
    route_id = Column(String, primary_key=True)
    route_name = Column(String)
    start_location = Column(String)
    end_location = Column(String)
    waypoints = Column(Text)
    distance_km = Column(Float)
    estimated_time_minutes = Column(Integer)
    created_at = Column(DateTime)
    is_active = Column(Boolean, default=True)
    vehicle_routes = relationship("VehicleRoute", back_populates="route")
    route_traffic_data = relationship("RouteTrafficData", back_populates="route")

class VehicleRoute(Base):
    __tablename__ = 'vehicle_routes'
    vehicle_id = Column(String, ForeignKey('vehicles.vehicle_id'), primary_key=True)
    route_id = Column(String, ForeignKey('routes.route_id'), primary_key=True)
    assigned_at = Column(DateTime)
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    status = Column(String)
    vehicle = relationship("Vehicle", back_populates="vehicle_routes")
    route = relationship("Route", back_populates="vehicle_routes")

class Incident(Base):
    __tablename__ = 'incidents'
    incident_id = Column(String, primary_key=True)
    reporter_id = Column(String, ForeignKey('commuters.commuter_id'), nullable=False)
    incident_type = Column(String)
    location_name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    description = Column(Text)
    severity = Column(String)
    reported_at = Column(DateTime)
    resolved_at = Column(DateTime)
    status = Column(String)
    assigned_officer = Column(String)
    reporter = relationship("Commuter", back_populates="incidents")

class Alert(Base):
    __tablename__ = 'alerts'
    alert_id = Column(String, primary_key=True)
    alert_type = Column(String)
    title = Column(String)
    message = Column(Text)
    severity = Column(String)
    target_audience = Column(String)
    created_at = Column(DateTime)
    expires_at = Column(DateTime)
    is_active = Column(Boolean, default=True)
    created_by_id = Column(String, ForeignKey('traffic_managers.manager_id'), nullable=False)
    created_by = relationship("TrafficManager", back_populates="alerts")
    user_alerts = relationship("UserAlert", back_populates="alert")

class UserAlert(Base):
    __tablename__ = 'user_alerts'
    user_id = Column(String, ForeignKey('users.user_id'), primary_key=True)
    alert_id = Column(String, ForeignKey('alerts.alert_id'), primary_key=True)
    sent_at = Column(DateTime)
    read_at = Column(DateTime)
    delivery_method = Column(String)
    is_read = Column(Boolean, default=False)
    user = relationship("User", back_populates="user_alerts")
    alert = relationship("Alert", back_populates="user_alerts")

class AnalyticsReport(Base):
    __tablename__ = 'analytics_reports'
    report_id = Column(String, primary_key=True)
    generated_by_id = Column(String, ForeignKey('traffic_managers.manager_id'), nullable=False)
    report_type = Column(String)
    title = Column(String)
    data_summary = Column(Text)
    generated_at = Column(DateTime)
    period_start = Column(DateTime)
    period_end = Column(DateTime)
    file_path = Column(String)
    generated_by = relationship("TrafficManager", back_populates="analytics_reports")

class MaintenanceLog(Base):
    __tablename__ = 'maintenance_logs'
    log_id = Column(String, primary_key=True)
    camera_id = Column(String, ForeignKey('cameras.camera_id'), nullable=False)
    technician_id = Column(String, ForeignKey('users.user_id'), nullable=False)
    maintenance_type = Column(String)
    description = Column(Text)
    scheduled_at = Column(DateTime)
    completed_at = Column(DateTime)
    status = Column(String)
    cost = Column(Float)
    camera = relationship("Camera", back_populates="maintenance_logs")
    technician = relationship("User", back_populates="maintenance_logs")

class RouteTrafficData(Base):
    __tablename__ = 'route_traffic_data'
    route_id = Column(String, ForeignKey('routes.route_id'), primary_key=True)
    traffic_id = Column(String, ForeignKey('traffic_data.traffic_id'), primary_key=True)
    analyzed_at = Column(DateTime)
    impact_score = Column(Float)
    route = relationship("Route", back_populates="route_traffic_data")
    traffic_data = relationship("TrafficData", back_populates="route_traffic_data")