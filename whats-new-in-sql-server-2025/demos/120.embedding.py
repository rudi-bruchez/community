# import mssql_python # RuntimeError: Streaming parameters is not yet supported. Parameter size must be less than 8192
import pyodbc
import re
from dotenv import load_dotenv
import os
import time
# import openai
from sentence_transformers import SentenceTransformer, util 
import json

def store_verses_sqlserver(verses, embeddings, book_number, server, database, username, password):
    # Connection string for SQL Server
    conn_str = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={server};DATABASE={database};UID={username};PWD={password};"
        f"TrustServerCertificate=yes;"
        f"LongAsMax=yes" # pyodbc
    )
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    # Create table if it doesn't exist
    cursor.execute('''
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='verses' AND xtype='U')
        CREATE TABLE verses (
            id INT IDENTITY(1,1) PRIMARY KEY,
            book_number INT,
            verse NVARCHAR(MAX),
            verse_embedding VECTOR(384)
        )
    ''')
    # Truncate the verses table before inserting new data
    cursor.execute("TRUNCATE TABLE verses")
    for verse, embedding in zip(verses, embeddings):
        cursor.execute(
            "INSERT INTO verses (book_number, verse, verse_embedding) VALUES (?, ?, ?)",
            book_number, verse, json.dumps(embedding.tolist())
        )
    conn.commit()
    conn.close()

if __name__ == "__main__":
    # Load environment variables from .env file
    load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

    server = os.getenv('SQLSERVER_SERVER')
    database = os.getenv('SQLSERVER_DATABASE')
    username = os.getenv('SQLSERVER_USERNAME')
    password = os.getenv('SQLSERVER_PASSWORD')

    # Book number for this import
    book_number = 1

    verses = []

    # Regex to remove verse numbers at the end of the line (e.g., '   790')
    verse_number_pattern = re.compile(r'\s*\d+\s*$')

    # Read verses from the text file
    with open("pg24280-endymion-cleaned.txt", encoding="utf-8") as f:
        for line in f:
            line = verse_number_pattern.sub('', line).strip()
            if line:  # skip empty lines
                verses.append(line)

    model = SentenceTransformer('sentence-transformers/paraphrase-MiniLM-L3-v2')
    embeddings = model.encode(verses)

    start_time = time.time()
    store_verses_sqlserver(verses, embeddings, book_number, server, database, username, password)
    elapsed_time = time.time() - start_time
    print(f"Execution time: {elapsed_time:.2f} seconds")