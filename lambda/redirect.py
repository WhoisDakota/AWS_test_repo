import re

from db import query, resp


def handler(event, context):
    code = (event.get("pathParameters") or {}).get("code", "")
    if not re.fullmatch(r"[A-Za-z0-9]{1,10}", code):
        return resp(404, {"error": "Link not found."})
    #one atomic statement counts the click and fetches the target.
    rows = query("UPDATE links SET clicks = clicks + 1 WHERE code = :c RETURNING url", c=code)
    if not rows:
        return resp(404, {"error": "Link not found."})
    return {"statusCode": 302, "headers": {"Location": rows[0][0], "Cache-Control": "no-store"}, "body": ""}
