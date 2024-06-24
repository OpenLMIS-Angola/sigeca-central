import os
import psycopg

from psycopg import sql
from typing import Optional

from models import MSFacility, User, SyncInput
from sql_builder import generate_statement_with_args

db_conn = dsn = f"host={os.getenv("DB_HOST")} port={os.getenv("DB_PORT")} dbname={os.getenv("DB_NAME")} user={os.getenv("DB_USER")} password={os.getenv("DB_PASSWORD")}"

_q_fetch_all_facilities = sql.SQL("""
select f.*, coalesce(jsonb_agg(json_build_object('code', s.code, 'name', s.name)) filter (where s.id is not null), '[]') as services
from ms.facility f
left join ms.facility_service fs on f.id=fs.facility_id
left join ms.service s on fs.service_id=s.id
group by f.id;
""")

_q_fetch_user_for_auth = sql.SQL("""
SELECT u.*
FROM sigeca.user u
WHERE username=%s
""")



def fetch_user_for_auth(username: str) -> Optional[User]:
    with psycopg.connect(db_conn) as con:
        with con.cursor(row_factory=psycopg.rows.class_row(User)) as cur:
            cur.execute(_q_fetch_user_for_auth, (username,))
            return cur.fetchone()


def fetch_all_facilities() -> list[MSFacility]:
    with psycopg.connect(db_conn) as con:
        with con.cursor(row_factory=psycopg.rows.class_row(MSFacility)) as cur:
            cur.execute(_q_fetch_all_facilities)
            return cur.fetchall()




def _execute_sync_input_line(cur: psycopg.Cursor, line: SyncInput) -> None:
    statement, args = generate_statement_with_args(line)
    cur.execute(statement, args)


def execute_sync_input(data: list[SyncInput]) -> None:
    with psycopg.connect(db_conn) as con:
        with con.cursor() as cur:
            for sync_input in data:
                _execute_sync_input_line(cur, sync_input)
