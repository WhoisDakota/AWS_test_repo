from db import owner_id, query, resp


def handler(event, context):
    code = event["pathParameters"]["code"]
    #ownership is enforced in postgreSQL:can only delete my own links.
    rows = query("DELETE FROM links WHERE code = :c AND owner = CAST(:o AS uuid) RETURNING code",
                 c=code, o=owner_id(event))
    if not rows:
        return resp(404, {"error": "Link not found."})
    return resp(200, {"deleted": code})
