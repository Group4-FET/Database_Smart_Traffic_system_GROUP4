Traffic Management System
Overview
The Traffic Management System is a PostgreSQL-based database application designed to manage urban traffic data, user roles, incidents, and analytics. It features a normalized schema with 16 tables, secure user access control, audit logging, and data population via CSV files. The system uses environment variables (.env) for secure credential management and includes scripts for data operations, backup/restore, and query testing.
Features

Normalized Schema: 16 tables (USERS, TRAFFIC_MANAGERS, COMMUTERS, TRANSPORT_OPERATORS, CAMERAS, IMAGE_DATA, TRAFFIC_DATA, VEHICLES, ROUTES, VEHICLE_ROUTES, INCIDENTS, ALERTS, USER_ALERTS, ANALYTICS_REPORTS, MAINTENANCE_LOGS, ROUTE_TRAFFIC_DATA).
User Access Control: Role-based permissions (commuter_role, traffic_manager_role, operator_role, technician_role, admin_role) with audit logging.
Data Population: Imports data from CSV files, respecting foreign key constraints.
Secure Credentials: Database and user passwords managed via .env.
ORM Support: SQLAlchemy for Python-based database interactions.
Backup/Restore: Scripts for database backup and selective data recovery.
Query Operations: Test, search, addition, modification, deletion, and parameterized queries.
Optimization: Indexes, partitioning, and materialized views for performance.

Prerequisites

PostgreSQL: Version 15 or later.
Python: Version 3.8 or later.
Dependencies:pip install pandas psycopg2-binary python-dotenv sqlalchemy


Tools: psql, pg_dump for database operations.
CSV Files: Data for all 16 tables in src/database/data/csv/.

Project Structure
traffic_management_system/
├── .env                    # Environment variables (not tracked)
├── .gitignore              # Git ignore file
├── config/
│   └── database.py         # SQLAlchemy ORM configuration
├── src/
│   ├── database/
│   │   ├── backup/
│   │   │   ├── backup_restore.py        # Backup/restore script
│   │   │   └── restore_data.sql         # Selective restore queries
│   │   ├── data/
│   │   │   ├── csv/                     # CSV files for data import
│   │   │   └── import_csv.py            # CSV import script
│   │   ├── procedures/
│   │   │   ├── consistency_checks.sql   # Data consistency triggers
│   │   │   └── parameterized_queries.sql # PL/pgSQL functions
│   │   └── queries/
│   │       ├── add_data.sql             # Data addition queries
│   │       ├── delete_data.sql          # Data deletion queries
│   │       ├── modify_data.sql          # Data modification queries
│   │       ├── search_queries.sql       # Search queries
│   │       └── test_queries.sql         # Test queries
│   └── security/
│       ├── set_user_passwords.py        # Script to set PostgreSQL user passwords
│       ├── setup_roles_and_logging.sql  # Role and audit log setup
│       └── test_roles.sql               # Role permission tests
├── docs/
│   └── screenshots/                     # Screenshots for report
└── README.md                            # Project documentation

Setup Instructions
1. Configure Environment Variables
Create a .env file in the project root:
echo -e "DB_NAME=traffic_management\nDB_USER=postgres\nDB_PASSWORD=your_secure_password\nDB_HOST=localhost\nDB_PORT=5432\nCOMMUTER_USER_PASSWORD=secure_password1\nTRAFFIC_MANAGER_USER_PASSWORD=secret_key2\nOPERATOR_USER_PASSWORD=secret_key3\nTECHNICIAN_USER_PASSWORD=secret_key4\nADMIN_USER_PASSWORD=secret_key5" > .env


Replace your_secure_password with your PostgreSQL password.
Update user passwords as needed.
Update .gitignore:echo ".env" >> .gitignore



2. Install Dependencies
pip install pandas psycopg2-binary python-dotenv sqlalchemy

3. Create Database
Assuming you have the schema creation script (create_tables.sql):
psql -U postgres -c "CREATE DATABASE traffic_management;"
psql -U postgres -d traffic_management -f src/database/create_tables.sql

4. Initialize ORM
python -c "from config.database import init_db; init_db()"


Screenshot: docs/screenshots/orm_setup.png

5. Set Up User Roles and Audit Logging
psql -U postgres -d traffic_management -f src/security/setup_roles_and_logging.sql
python src/security/set_user_passwords.py


Screenshots: docs/screenshots/role_setup.png, docs/screenshots/password_setting.png

6. Import CSV Data
Place CSV files in src/database/data/csv/ (e.g., users.csv, traffic_data.csv). Run:
python src/database/data/import_csv.py


Verify tables:psql -U postgres -d traffic_management -c "\dt+"


Screenshots: docs/screenshots/csv_import.png, docs/screenshots/table_verification.png

7. Run Database Operations

Test Queries:psql -U postgres -d traffic_management -f src/database/queries/test_queries.sql


Screenshot: docs/screenshots/test_queries.png


Consistency Checks:psql -U postgres -d traffic_management -f src/database/procedures/consistency_checks.sql


Screenshot: docs/screenshots/consistency_checks.png


Search Queries:psql -U postgres -d traffic_management -f src/database/queries/search_queries.sql


Screenshot: docs/screenshots/search_queries.png


Add Data:psql -U postgres -d traffic_management -f src/database/queries/add_data.sql


Screenshot: docs/screenshots/add_data.png


Modify Data:psql -U postgres -d traffic_management -f src/database/queries/modify_data.sql


Screenshot: docs/screenshots/modify_data.png


Delete Data:psql -U postgres -d traffic_management -f src/database/queries/delete_data.sql


Screenshot: docs/screenshots/delete_data.png


Restore Data:python src/database/backup/backup_restore.py
psql -U postgres -d traffic_management -f src/database/backup/restore_data.sql


Screenshot: docs/screenshots/backup_restore.png


Parameterized Queries:psql -U postgres -d traffic_management -f src/database/procedures/parameterized_queries.sql
psql -U postgres -d traffic_management -c "SELECT * FROM get_traffic_by_level('High');"


Screenshot: docs/screenshots/parameterized_queries.png


Test Roles:psql -U postgres -d traffic_management -f src/security/test_roles.sql


Screenshot: docs/screenshots/role_testing.png



8. Apply Optimizations
psql -U postgres -d traffic_management -c "CREATE INDEX idx_traffic_data_congestion_level ON traffic_data(congestion_level);"
psql -U postgres -d traffic_management -c "CREATE INDEX idx_user_alerts_user_id ON user_alerts(user_id);"


Screenshot: docs/screenshots/index_creation.png

CSV File Format

Each CSV must match its table schema (e.g., users.csv needs user_id,username,email,...).
Example users.csv:user_id,username,email,password_hash,role,phone_number,first_name,last_name,created_at,updated_at,is_active
USR001,john_doe,john.doe@example.com,hashed_password,Commuter,237677000001,John,Doe,2025-06-06 14:30:00,,TRUE


Ensure foreign keys reference valid primary keys.
Use NULL for nullable fields; dates in YYYY-MM-DD HH:MM:SS.

Security Notes

Credentials: Stored in .env, not tracked by Git.
User Passwords: Managed via set_user_passwords.py or psql commands. For production, use a secrets manager.
Audit Logging: Tracks actions on users, traffic_data, and incidents in audit_log table.
Permissions: Granular role-based access control ensures data security.

Troubleshooting

CSV Import Errors: Check CSV headers and foreign keys. Share sample headers for debugging.
Database Connection: Verify .env credentials and PostgreSQL service.
Permission Issues: Ensure roles are set up and passwords applied correctly.
Schema Missing: Run create_tables.sql if tables are not created.

Screenshots
All screenshots are stored in docs/screenshots/ for report documentation:

env_setup.png
orm_setup.png
role_setup.png
password_setting.png
csv_import.png
table_verification.png
test_queries.png
consistency_checks.png
search_queries.png
add_data.png
modify_data.png
delete_data.png
backup_restore.png
parameterized_queries.png
role_testing.png
index_creation.png

Future Improvements

Integrate a REST API for web-based access.
Implement real-time traffic data processing.
Enhance audit logging with detailed change tracking.
Deploy to a cloud provider with automated backups.

License
This project is licensed under the MIT License.
Contact
For issues or questions, contact the project maintainer at [your_email@example.com].
