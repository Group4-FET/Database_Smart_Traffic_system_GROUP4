--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: audit_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    INSERT INTO audit_log (user_id, action, table_name, timestamp)

    VALUES (CURRENT_USER, TG_OP, TG_TABLE_NAME, CURRENT_TIMESTAMP);

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.audit_trigger() OWNER TO postgres;

--
-- Name: update_vehicle_incident(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_vehicle_incident(IN p_vehicle_id character varying, IN p_route_id character varying, IN p_incident_id character varying, IN p_status character varying)
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


ALTER PROCEDURE public.update_vehicle_incident(IN p_vehicle_id character varying, IN p_route_id character varying, IN p_incident_id character varying, IN p_status character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alerts (
    alert_id character varying(50) NOT NULL,
    alert_type character varying(50),
    title character varying(100),
    message text,
    severity character varying(50),
    target_audience character varying(100),
    created_at timestamp without time zone,
    expires_at timestamp without time zone,
    is_active boolean DEFAULT true,
    created_by_id character varying(50)
);


ALTER TABLE public.alerts OWNER TO postgres;

--
-- Name: analytics_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analytics_reports (
    report_id character varying(50) NOT NULL,
    generated_by_id character varying(50),
    report_type character varying(50),
    title character varying(100),
    data_summary text,
    generated_at timestamp without time zone,
    period_start timestamp without time zone,
    period_end timestamp without time zone,
    file_path character varying(255)
);


ALTER TABLE public.analytics_reports OWNER TO postgres;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    log_id integer NOT NULL,
    user_id character varying(50),
    action character varying(100),
    table_name character varying(100),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_log_id_seq OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_log_log_id_seq OWNED BY public.audit_log.log_id;


--
-- Name: cameras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cameras (
    camera_id character varying(50) NOT NULL,
    location_name character varying(100),
    ip_address character varying(45),
    latitude numeric(9,6),
    longitude numeric(9,6),
    camera_type character varying(50),
    is_active boolean DEFAULT true,
    installed_at timestamp without time zone,
    last_maintenance timestamp without time zone,
    status character varying(50)
);


ALTER TABLE public.cameras OWNER TO postgres;

--
-- Name: commuters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commuters (
    commuter_id character varying(50) NOT NULL,
    user_id character varying(50),
    preferences text,
    notification_settings text,
    registered_at timestamp without time zone
);


ALTER TABLE public.commuters OWNER TO postgres;

--
-- Name: image_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_data (
    image_id character varying(50) NOT NULL,
    camera_id character varying(50),
    image_path character varying(255),
    file_size character varying(50),
    resolution character varying(50),
    captured_at timestamp without time zone,
    metadata text,
    processed boolean DEFAULT false
);


ALTER TABLE public.image_data OWNER TO postgres;

--
-- Name: incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidents (
    incident_id character varying(50) NOT NULL,
    reporter_id character varying(50),
    incident_type character varying(50),
    location_name character varying(100),
    latitude numeric(9,6),
    longitude numeric(9,6),
    description text,
    severity character varying(50),
    reported_at timestamp without time zone,
    resolved_at timestamp without time zone,
    status character varying(50),
    assigned_officer character varying(50)
);


ALTER TABLE public.incidents OWNER TO postgres;

--
-- Name: maintenance_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance_logs (
    log_id character varying(50) NOT NULL,
    camera_id character varying(50),
    technician_id character varying(50),
    maintenance_type character varying(50),
    description text,
    scheduled_at timestamp without time zone,
    completed_at timestamp without time zone,
    status character varying(50),
    cost numeric(10,2)
);


ALTER TABLE public.maintenance_logs OWNER TO postgres;

--
-- Name: route_traffic_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.route_traffic_data (
    route_id character varying(50) NOT NULL,
    traffic_id character varying(50) NOT NULL,
    analyzed_at timestamp without time zone,
    impact_score numeric(5,2)
);


ALTER TABLE public.route_traffic_data OWNER TO postgres;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    route_id character varying(50) NOT NULL,
    route_name character varying(100),
    start_location character varying(100),
    end_location character varying(100),
    waypoints text,
    distance_km numeric(7,2),
    estimated_time_minutes integer,
    created_at timestamp without time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: traffic_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.traffic_data (
    traffic_id character varying(50) NOT NULL,
    camera_id character varying(50),
    image_id character varying(50),
    location_name character varying(100),
    latitude numeric(9,6),
    longitude numeric(9,6),
    congestion_level character varying(50),
    vehicle_count integer,
    average_speed numeric(5,2),
    recorded_at timestamp without time zone,
    weather_condition character varying(50),
    CONSTRAINT traffic_data_average_speed_check CHECK ((average_speed >= (0)::numeric)),
    CONSTRAINT traffic_data_vehicle_count_check CHECK ((vehicle_count >= 0))
);


ALTER TABLE public.traffic_data OWNER TO postgres;

--
-- Name: traffic_managers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.traffic_managers (
    manager_id character varying(50) NOT NULL,
    user_id character varying(50),
    department character varying(100),
    authority_level character varying(50),
    assigned_at timestamp without time zone
);


ALTER TABLE public.traffic_managers OWNER TO postgres;

--
-- Name: transport_operators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transport_operators (
    operator_id character varying(50) NOT NULL,
    user_id character varying(50),
    company_name character varying(100),
    license_number character varying(50),
    vehicle_types text,
    licensed_at timestamp without time zone
);


ALTER TABLE public.transport_operators OWNER TO postgres;

--
-- Name: user_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_alerts (
    user_id character varying(50) NOT NULL,
    alert_id character varying(50) NOT NULL,
    sent_at timestamp without time zone,
    read_at timestamp without time zone,
    delivery_method character varying(50),
    is_read boolean DEFAULT false
);


ALTER TABLE public.user_alerts OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id character varying(50) NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    phone_number character varying(20),
    first_name character varying(50),
    last_name character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['Commuter'::character varying, 'TrafficManager'::character varying, 'Operator'::character varying, 'Technician'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: vehicle_routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicle_routes (
    vehicle_id character varying(50) NOT NULL,
    route_id character varying(50) NOT NULL,
    assigned_at timestamp without time zone,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    status character varying(50)
);


ALTER TABLE public.vehicle_routes OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    vehicle_id character varying(50) NOT NULL,
    operator_id character varying(50),
    plate_number character varying(50),
    vehicle_type character varying(50),
    model character varying(100),
    capacity integer,
    current_latitude numeric(9,6),
    current_longitude numeric(9,6),
    last_updated timestamp without time zone,
    status character varying(50),
    CONSTRAINT vehicles_capacity_check CHECK ((capacity > 0))
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: audit_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN log_id SET DEFAULT nextval('public.audit_log_log_id_seq'::regclass);


--
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts (alert_id, alert_type, title, message, severity, target_audience, created_at, expires_at, is_active, created_by_id) FROM stdin;
\.


--
-- Data for Name: analytics_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analytics_reports (report_id, generated_by_id, report_type, title, data_summary, generated_at, period_start, period_end, file_path) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (log_id, user_id, action, table_name, "timestamp") FROM stdin;
\.


--
-- Data for Name: cameras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cameras (camera_id, location_name, ip_address, latitude, longitude, camera_type, is_active, installed_at, last_maintenance, status) FROM stdin;
\.


--
-- Data for Name: commuters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commuters (commuter_id, user_id, preferences, notification_settings, registered_at) FROM stdin;
\.


--
-- Data for Name: image_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.image_data (image_id, camera_id, image_path, file_size, resolution, captured_at, metadata, processed) FROM stdin;
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidents (incident_id, reporter_id, incident_type, location_name, latitude, longitude, description, severity, reported_at, resolved_at, status, assigned_officer) FROM stdin;
\.


--
-- Data for Name: maintenance_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_logs (log_id, camera_id, technician_id, maintenance_type, description, scheduled_at, completed_at, status, cost) FROM stdin;
\.


--
-- Data for Name: route_traffic_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.route_traffic_data (route_id, traffic_id, analyzed_at, impact_score) FROM stdin;
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (route_id, route_name, start_location, end_location, waypoints, distance_km, estimated_time_minutes, created_at, is_active) FROM stdin;
\.


--
-- Data for Name: traffic_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.traffic_data (traffic_id, camera_id, image_id, location_name, latitude, longitude, congestion_level, vehicle_count, average_speed, recorded_at, weather_condition) FROM stdin;
\.


--
-- Data for Name: traffic_managers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.traffic_managers (manager_id, user_id, department, authority_level, assigned_at) FROM stdin;
\.


--
-- Data for Name: transport_operators; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transport_operators (operator_id, user_id, company_name, license_number, vehicle_types, licensed_at) FROM stdin;
\.


--
-- Data for Name: user_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_alerts (user_id, alert_id, sent_at, read_at, delivery_method, is_read) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, email, password_hash, role, phone_number, first_name, last_name, created_at, updated_at, is_active) FROM stdin;
\.


--
-- Data for Name: vehicle_routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicle_routes (vehicle_id, route_id, assigned_at, start_time, end_time, status) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (vehicle_id, operator_id, plate_number, vehicle_type, model, capacity, current_latitude, current_longitude, last_updated, status) FROM stdin;
\.


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_log_id_seq', 1, false);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (alert_id);


--
-- Name: analytics_reports analytics_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_reports
    ADD CONSTRAINT analytics_reports_pkey PRIMARY KEY (report_id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: cameras cameras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_pkey PRIMARY KEY (camera_id);


--
-- Name: commuters commuters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commuters
    ADD CONSTRAINT commuters_pkey PRIMARY KEY (commuter_id);


--
-- Name: image_data image_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_data
    ADD CONSTRAINT image_data_pkey PRIMARY KEY (image_id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (incident_id);


--
-- Name: maintenance_logs maintenance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs
    ADD CONSTRAINT maintenance_logs_pkey PRIMARY KEY (log_id);


--
-- Name: route_traffic_data route_traffic_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_traffic_data
    ADD CONSTRAINT route_traffic_data_pkey PRIMARY KEY (route_id, traffic_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (route_id);


--
-- Name: traffic_data traffic_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_data
    ADD CONSTRAINT traffic_data_pkey PRIMARY KEY (traffic_id);


--
-- Name: traffic_managers traffic_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_managers
    ADD CONSTRAINT traffic_managers_pkey PRIMARY KEY (manager_id);


--
-- Name: transport_operators transport_operators_license_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transport_operators
    ADD CONSTRAINT transport_operators_license_number_key UNIQUE (license_number);


--
-- Name: transport_operators transport_operators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transport_operators
    ADD CONSTRAINT transport_operators_pkey PRIMARY KEY (operator_id);


--
-- Name: user_alerts user_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_alerts
    ADD CONSTRAINT user_alerts_pkey PRIMARY KEY (user_id, alert_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: vehicle_routes vehicle_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_routes
    ADD CONSTRAINT vehicle_routes_pkey PRIMARY KEY (vehicle_id, route_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_plate_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_plate_number_key UNIQUE (plate_number);


--
-- Name: traffic_data traffic_data_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER traffic_data_audit AFTER INSERT OR DELETE OR UPDATE ON public.traffic_data FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: users user_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER user_audit AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: alerts alerts_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.traffic_managers(manager_id) ON DELETE CASCADE;


--
-- Name: analytics_reports analytics_reports_generated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_reports
    ADD CONSTRAINT analytics_reports_generated_by_id_fkey FOREIGN KEY (generated_by_id) REFERENCES public.traffic_managers(manager_id) ON DELETE CASCADE;


--
-- Name: commuters commuters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commuters
    ADD CONSTRAINT commuters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: image_data image_data_camera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_data
    ADD CONSTRAINT image_data_camera_id_fkey FOREIGN KEY (camera_id) REFERENCES public.cameras(camera_id) ON DELETE CASCADE;


--
-- Name: incidents incidents_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.commuters(commuter_id) ON DELETE CASCADE;


--
-- Name: maintenance_logs maintenance_logs_camera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs
    ADD CONSTRAINT maintenance_logs_camera_id_fkey FOREIGN KEY (camera_id) REFERENCES public.cameras(camera_id) ON DELETE CASCADE;


--
-- Name: maintenance_logs maintenance_logs_technician_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs
    ADD CONSTRAINT maintenance_logs_technician_id_fkey FOREIGN KEY (technician_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: route_traffic_data route_traffic_data_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_traffic_data
    ADD CONSTRAINT route_traffic_data_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(route_id) ON DELETE CASCADE;


--
-- Name: route_traffic_data route_traffic_data_traffic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_traffic_data
    ADD CONSTRAINT route_traffic_data_traffic_id_fkey FOREIGN KEY (traffic_id) REFERENCES public.traffic_data(traffic_id) ON DELETE CASCADE;


--
-- Name: traffic_data traffic_data_camera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_data
    ADD CONSTRAINT traffic_data_camera_id_fkey FOREIGN KEY (camera_id) REFERENCES public.cameras(camera_id) ON DELETE CASCADE;


--
-- Name: traffic_data traffic_data_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_data
    ADD CONSTRAINT traffic_data_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image_data(image_id) ON DELETE SET NULL;


--
-- Name: traffic_managers traffic_managers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_managers
    ADD CONSTRAINT traffic_managers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: transport_operators transport_operators_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transport_operators
    ADD CONSTRAINT transport_operators_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: user_alerts user_alerts_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_alerts
    ADD CONSTRAINT user_alerts_alert_id_fkey FOREIGN KEY (alert_id) REFERENCES public.alerts(alert_id) ON DELETE CASCADE;


--
-- Name: user_alerts user_alerts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_alerts
    ADD CONSTRAINT user_alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: vehicle_routes vehicle_routes_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_routes
    ADD CONSTRAINT vehicle_routes_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(route_id) ON DELETE CASCADE;


--
-- Name: vehicle_routes vehicle_routes_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_routes
    ADD CONSTRAINT vehicle_routes_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: vehicles vehicles_operator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_operator_id_fkey FOREIGN KEY (operator_id) REFERENCES public.transport_operators(operator_id) ON DELETE CASCADE;


--
-- Name: TABLE alerts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.alerts TO commuter_role;
GRANT SELECT,INSERT,UPDATE ON TABLE public.alerts TO traffic_manager_role;
GRANT ALL ON TABLE public.alerts TO admin_role;


--
-- Name: TABLE analytics_reports; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.analytics_reports TO traffic_manager_role;
GRANT ALL ON TABLE public.analytics_reports TO admin_role;


--
-- Name: TABLE cameras; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.cameras TO technician_role;
GRANT ALL ON TABLE public.cameras TO admin_role;


--
-- Name: TABLE commuters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.commuters TO commuter_role;
GRANT ALL ON TABLE public.commuters TO admin_role;


--
-- Name: TABLE image_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.image_data TO admin_role;


--
-- Name: TABLE incidents; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.incidents TO traffic_manager_role;
GRANT ALL ON TABLE public.incidents TO admin_role;


--
-- Name: TABLE maintenance_logs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.maintenance_logs TO technician_role;
GRANT ALL ON TABLE public.maintenance_logs TO admin_role;


--
-- Name: TABLE route_traffic_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.route_traffic_data TO admin_role;


--
-- Name: TABLE routes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.routes TO admin_role;


--
-- Name: TABLE traffic_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.traffic_data TO traffic_manager_role;
GRANT ALL ON TABLE public.traffic_data TO admin_role;


--
-- Name: TABLE traffic_managers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.traffic_managers TO admin_role;


--
-- Name: TABLE transport_operators; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transport_operators TO admin_role;


--
-- Name: TABLE user_alerts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.user_alerts TO commuter_role;
GRANT ALL ON TABLE public.user_alerts TO admin_role;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.users TO commuter_role;
GRANT ALL ON TABLE public.users TO admin_role;


--
-- Name: TABLE vehicle_routes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.vehicle_routes TO operator_role;
GRANT ALL ON TABLE public.vehicle_routes TO admin_role;


--
-- Name: TABLE vehicles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.vehicles TO operator_role;
GRANT ALL ON TABLE public.vehicles TO admin_role;


--
-- PostgreSQL database dump complete
--

