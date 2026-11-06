from sqlalchemy import text
from ..database import engine

def get_all():
    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT * FROM nestegg.wallets")
        )
        return [dict(row) for row in result.mappings()]