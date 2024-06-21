import os
import sys
import psycopg

from passlib.context import CryptContext

sql = """
INSERT INTO sigeca."user" (username, password_hash)
VALUES (%s, %s)
ON CONFLICT (username) DO UPDATE
SET password_hash = excluded.password_hash, is_deleted = FALSE, last_updated = NOW();
"""


def main():
    if not len(sys.argv) == 3:
        print("Usage: python3 add_api_user.py <username> <password>", file=sys.stderr)
        exit(1)

    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    db_conn = dsn = f"host={os.getenv("DB_HOST")} port={os.getenv("DB_PORT")} dbname={os.getenv("DB_NAME")} user={os.getenv("DB_USER")} password={os.getenv("DB_PASSWORD")}"
        
    username = sys.argv[1]
    password = sys.argv[2]
    password_hash = pwd_context.hash(password)

    # Connect to the database
    with psycopg.connect(db_conn) as con:
        with con.cursor() as cur:
            cur.execute(sql, (username, password_hash))

if __name__ == "__main__":
    main()
