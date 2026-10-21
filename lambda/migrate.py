"""Idempotent schema setup. Runs as DB admin; this creates the IAM-auth app user."""
import os

from db import connect


def handler(event, context):
    app = os.environ["DB_APP_USER"]
    assert app.isidentifier()
    conn = connect(os.environ["DB_ADMIN_USER"], os.environ["DB_ADMIN_PASSWORD"])
    statements = [
        f"DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{app}') "
        f"THEN CREATE ROLE {app} LOGIN; END IF; END $$",
        f"GRANT rds_iam TO {app}",
        """CREATE TABLE IF NOT EXISTS links (
               id         BIGSERIAL PRIMARY KEY,
               code       VARCHAR(10) UNIQUE NOT NULL,
               url        TEXT NOT NULL,
               owner      UUID NOT NULL,
               created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
               clicks     BIGINT NOT NULL DEFAULT 0)""",
        "CREATE INDEX IF NOT EXISTS idx_links_owner ON links (owner, created_at DESC)",
        f"GRANT SELECT, INSERT, UPDATE, DELETE ON links TO {app}",
        f"GRANT USAGE ON SEQUENCE links_id_seq TO {app}",
    ]
    for sql in statements:
        conn.run(sql)
    conn.close()
    return {"migrated": True}
