import os
import psycopg

from psycopg import sql
from typing import Optional

from models import MSFacility, User, SyncInput

db_conn = dsn = f"host={os.getenv("DB_HOST")} port={os.getenv("DB_PORT")} dbname={os.getenv("DB_NAME")} user={os.getenv("DB_USER")} password={os.getenv("DB_PASSWORD")}"

_q_fetch_all_facilities = sql.SQL("""
select f.*, jsonb_agg(json_build_object('code', s.code, 'name', s.name)) as services
from ms.facility f
join ms.facility_service fs on f.id=fs.facility_id
join ms.service s on fs.service_id=s.id
group by f.id;
""")

_q_fetch_user_for_auth = sql.SQL("""
SELECT u.*
FROM sigeca.user u
WHERE username=%s
""")

_sync_insert_template = sql.SQL("INSERT INTO {}({}) VALUES({})")
_sync_update_template = sql.SQL("UPDATE {} SET {} WHERE reference_id=%s")
_sync_delete_template = sql.SQL("DELETE FROM {} WHERE reference_id=%s")

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


def _generate_insert_template_args(line):
    columns = []
    values = []

    for k, v in line.row_data.items():
        if k == "id":
            columns.append(sql.Identifier("reference_id"))
        else:
            columns.append(sql.Identifier(k))
        values.append(v)

    return (sql.Identifier(line.table_name), sql.SQL(", ").join(columns), sql.SQL(", ".join(["%s"] * len(columns)))), values

def _generate_update_template_args(line):
    columns = []
    values = []

    for k, v in line.row_data.items():
        if k != "id":
            columns.append(sql.SQL("{} = %s").format(sql.Identifier(k)))
            values.append(v)

    values.append(line.row_data.get("id"))

    return (sql.Identifier(line.table_name), sql.SQL(", ").join(columns), sql.SQL(", ".join(["%s"] * len(columns)))), values


_templates = {
    "I": _sync_insert_template,
    "U": _sync_update_template,
    "D": _sync_delete_template
}

_template_args = {
    "I": _generate_insert_template_args,
    "U": _generate_update_template_args,
    "D": lambda l: ((sql.Identifier(l.table_name),), (l.row_data.get("id"),))
}


def _generate_statement_with_args(line: SyncInput):
    template = _templates[line.operation]
    format_args, statement_args = _template_args[line.operation](line)
    statement = template.format(*format_args)
    return statement, statement_args


def _execute_sync_input_line(cur: psycopg.Cursor, line: SyncInput) -> None:
    statement, args = _generate_statement_with_args(line)
    cur.execute(statement, args)


def execute_sync_input(data: list[SyncInput]) -> None:
    with psycopg.connect(db_conn) as con:
        with con.cursor() as cur:
            for sync_input in data:
                _execute_sync_input_line(cur, sync_input)
