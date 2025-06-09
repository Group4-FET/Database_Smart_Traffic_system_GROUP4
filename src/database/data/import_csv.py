import pandas as pd
import psycopg2
from dotenv import load_dotenv
from psycopg2.extras import execute_values
import os

load_dotenv()

# Database connection parameters
DB_PARAMS = {
    'dbname': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT')
}

# CSV directory
CSV_DIR = 'src/database/data/'

# Table order respecting foreign key dependencies
TABLES = [
    'users',
    'traffic_managers',
    'commuters',
    'transport_operators',
    'cameras',
    'image_data',
    'traffic_data',
    'vehicles',
    'routes',
    'vehicle_routes',
    'incidents',
    'alerts',
    'user_alerts',
    'analytics_reports',
    'maintenance_logs',
    'route_traffic_data'
]

def connect_db():
    """Establish database connection."""
    return psycopg2.connect(**DB_PARAMS)

def get_table_columns(cursor, table_name):
    """Retrieve column names for a table."""
    cursor.execute("""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = %s
        ORDER BY ordinal_position;
    """, (table_name,))
    return [row[0] for row in cursor.fetchall()]

def import_csv_to_table(cursor, table_name, csv_file):
    """Import CSV data into a table."""
    if not os.path.exists(csv_file):
        print(f"CSV file {csv_file} not found. Skipping...")
        return

    # Read CSV
    df = pd.read_csv(csv_file)
    if df.empty:
        print(f"No data in {csv_file}. Skipping...")
        return

    # Get table columns
    columns = get_table_columns(cursor, table_name)
    if not columns:
        print(f"No columns found for table {table_name}. Skipping...")
        return

    # Ensure CSV has only valid columns
    df = df[columns] if all(col in df.columns for col in columns) else df
    df = df.where(pd.notnull(df), None)  # Replace NaN with None for SQL

    # Prepare data
    values = [tuple(row) for row in df.to_numpy()]
    cols_str = ', '.join(columns)

    # Corrected query for execute_values
    query = f"INSERT INTO {table_name} ({cols_str}) VALUES %s"

    try:
        execute_values(cursor, query, values)
        print(f"Successfully imported {len(values)} rows into {table_name}")
    except Exception as e:
        print(f"Error importing into {table_name}: {e}")
        cursor.connection.rollback()
        return
    cursor.connection.commit()

def main():
    """Main function to import all CSVs."""
    conn = connect_db()
    cursor = conn.cursor()

    for table in TABLES:
        csv_file = os.path.join(CSV_DIR, f"{table}.csv")
        import_csv_to_table(cursor, table, csv_file)

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()
