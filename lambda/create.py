import json
import secrets
import string

import pg8000.exceptions
from db import is_unique_violation, owner_id, query, resp

ALPHABET = string.ascii_letters + string.digits


def handler(event, context):
    try:
        url = (json.loads(event.get("body") or "{}").get("url") or "").strip()
    except json.JSONDecodeError:
        return resp(400, {"error": "Body must be JSON."})
    if not url.startswith(("http://", "https://")) or len(url) > 2048:
        return resp(400, {"error": "Enter a URL starting with http:// or https:// (max 2048 characters)."})

    for _ in range(5):  #retry on the rare code collision
        code = "".join(secrets.choice(ALPHABET) for _ in range(6))
        try:
            query("INSERT INTO links (code, url, owner) VALUES (:c, :u, CAST(:o AS uuid))",
                  c=code, u=url, o=owner_id(event))
            return resp(201, {"code": code, "url": url})
        except pg8000.exceptions.DatabaseError as e:
            if not is_unique_violation(e):
                raise
    return resp(500, {"error": "Could not generate a unique code. Try again."})
