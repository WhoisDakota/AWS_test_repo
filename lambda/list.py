from db import owner_id, query, resp


def handler(event, context):
    rows = query(
        "SELECT code, url, created_at, clicks FROM links "
        "WHERE owner = CAST(:o AS uuid) ORDER BY created_at DESC LIMIT 100",
        o=owner_id(event),
    ) or []
    return resp(200, {"links": [
        {"code": c, "url": u, "createdAt": t, "clicks": n} for c, u, t, n in rows
    ]})
