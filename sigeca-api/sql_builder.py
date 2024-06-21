from psycopg import sql

from models import SyncInput

_sync_insert_template = sql.SQL("INSERT INTO {}({}) VALUES({})")
_sync_update_template = sql.SQL("UPDATE {} SET {} WHERE {}")
_sync_delete_template = sql.SQL("DELETE FROM {} WHERE {}")
_sync_upsert_template = sql.SQL("INSERT INTO {}({}) VALUES({}) ON CONFLICT ({}) DO UPDATE SET {}")


def _get_keys(line):
    keys = ['id', 'version_number'] if line.schema_name == "" and line.table_name == "product" else \
        ['facility_id', 'program_id'] if line.schema_name == "" and line.table_name == "supported_program" else \
            ['id']
    return keys


def _generate_insert_template_args(line):
    columns = []
    values = []

    for k, v in line.row_data.items():
        if k == "id":
            columns.append(sql.Identifier("reference_id"))
        else:
            columns.append(sql.Identifier(k))
        values.append(v)

    return (
        (
            sql.Identifier(line.table_name),
            sql.SQL(", ").join(columns),
            sql.SQL(", ").join(([sql.SQL("%s")] * len(columns)))
        ),
        values
    )


def _generate_update_template_args(line):
    key_columns = []
    columns = []
    values = []

    keys = _get_keys(line)

    for k, v in line.row_data.items():
        if k not in keys:
            columns.append(sql.SQL("{} = %s").format(sql.Identifier(k)))
            values.append(v)

    for key in keys:
        key_columns.append(sql.SQL("{} = %s").format(sql.Identifier(key if key != 'id' else 'reference_id')))
        values.append(line.row_data[key])

    return (
        (
            sql.Identifier(line.table_name),
            sql.SQL(", ").join(columns),
            sql.SQL(" AND ").join(key_columns),
        ),
        values
    )


def _generate_delete_template_args(line):
    key_columns = []
    values = []

    keys = _get_keys(line)

    for key in keys:
        key_columns.append(sql.SQL("{} = %s").format(sql.Identifier(key if key != 'id' else 'reference_id')))
        values.append(line.row_data[key])

    return (
        (
            sql.Identifier(line.table_name),
            sql.SQL(" AND ").join(key_columns),
        ),
        values,
    )


def _generate_upsert_template_args(line):
    insert_columns = []
    update_columns = []
    values = []

    for k, v in line.row_data.items():
        if k == "id":
            insert_columns.append(sql.Identifier("reference_id"))
        else:
            insert_columns.append(sql.Identifier(k))
        values.append(v)

    keys = _get_keys(line)

    for k, v in line.row_data.items():
        if k not in keys:
            update_columns.append(sql.SQL("{} = %s").format(sql.Identifier(k)))
            values.append(v)

    return (
        (
            sql.Identifier(line.table_name),
            sql.SQL(", ").join(insert_columns),
            sql.SQL(", ").join(([sql.SQL("%s")] * len(insert_columns))),
            sql.SQL(", ").join([sql.Identifier(k if k != 'id' else 'reference_id') for k in keys]),
            sql.SQL(", ").join(update_columns),

        ),
        values
    )


_templates = {
    "I": _sync_insert_template,
    "U": _sync_update_template,
    "D": _sync_delete_template,
    "S": _sync_upsert_template,
}

_template_args = {
    "I": _generate_insert_template_args,
    "U": _generate_update_template_args,
    "D": _generate_delete_template_args,
    "S": _generate_upsert_template_args,
}


def generate_statement_with_args(line: SyncInput):
    template = _templates[line.operation]
    format_args, statement_args = _template_args[line.operation](line)
    statement = template.format(*format_args)
    return statement, statement_args


if __name__ == "__main__":
    import psycopg
    from db import db_conn


    def print_statement(input):
        statement, args = generate_statement_with_args(input)
        with psycopg.connect(db_conn) as con:
            print(statement.as_string(con))
            print(args)


    print("test")

    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="I",
                  schema_name="", table_name="test", row_data={"id": "1", "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="U",
                  schema_name="", table_name="test", row_data={"id": "1", "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="D",
                  schema_name="", table_name="test", row_data={"id": "1", "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="S",
                  schema_name="", table_name="test", row_data={"id": "1", "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="I",
                  schema_name="", table_name="product", row_data={"id": "1", 'version_number': 3, "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="U",
                  schema_name="", table_name="product", row_data={"id": "1", 'version_number': 3, "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="D",
                  schema_name="", table_name="product", row_data={"id": "1", 'version_number': 3, "name": "test"})
    )
    print_statement(
        SyncInput(id="61e363f8-42b3-4ac2-a004-bc3a577ba7dc", change_time="2024-06-21T17:19:12+02:00", operation="S",
                  schema_name="", table_name="product", row_data={"id": "1", 'version_number': 3, "name": "test"})
    )
