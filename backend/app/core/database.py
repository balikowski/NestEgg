from sqlalchemy import create_engine, text, URL
from dotenv import load_dotenv
import os

url = URL.create(
    drivername="postgresql+psycopg2",
    username=os.getenv("user"),
    password=os.getenv("password"),
    host=os.getenv("host"),
    port=int(os.getenv("port", "5432")),
    database=os.getenv("dbname"),
    query={"sslmode": "require"}
)

engine = create_engine(url)

try:
    with engine.connect() as conn:
        result = conn.execute(text("SELECT 1"))
        print("Connection successful!", result.scalar())

except Exception as e:
    print(f"Connection failed: {e}")


