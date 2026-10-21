import json
import os
import ssl

import boto3
import pg8000.exceptions
import pg8000.native

#RDS certificates are not in Lambda's trust store, so I ship the AWS bundle.
_ctx = ssl.create_default_context(cafile=os.path.join(os.path.dirname(__file__), "rds-ca.pem"))
_conn = None  #reused across warm invocations


def connect(user, password):
    return pg8000.native.Connection(
        user=user, password=password, host=os.environ["DB_HOST"], port=5432,
        database=os.environ["DB_NAME"], ssl_context=_ctx, timeout=5,
    )


def _get_conn():
    global _conn
    if _conn is None:
        #signs a 15-minute token locally; no network call, so no NAT needed.
        token = boto3.client("rds").generate_db_auth_token(
            DBHostname=os.environ["DB_HOST"], Port=5432, DBUsername=os.environ["DB_USER"]
        )
        _conn = connect(os.environ["DB_USER"], token)
    return _conn


def query(sql, **params):
    """Run one statement. If the cached connection went stale, reconnect once."""
    global _conn
    for attempt in (1, 2):
        try:
            return _get_conn().run(sql, **params)
        except (pg8000.exceptions.InterfaceError, OSError):
            _conn = None
            if attempt == 2:
                raise


def is_unique_violation(err):
    info = err.args[0] if err.args else {}
    return isinstance(info, dict) and info.get("C") == "23505"


def owner_id(event):
    return event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]


def resp(status, body=None, headers=None):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json", **(headers or {})},
        "body": json.dumps(body if body is not None else {}, default=str),
    }
