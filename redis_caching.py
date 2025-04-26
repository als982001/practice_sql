import redis
import sqlite3
import json

# decode_responses=True -> 문자열로 받음. 그래서 내가 보기 좋음
r = redis.Redis(host="localhost", port=6379, decode_responses=True)

conn = sqlite3.connect("movies.db")
cur = conn.cursor()

'''
r.set("hello", "world")
print(r.get("hello"))

r.hset("users:15", mapping={"name": "jm", "age": 5})
print(r.hgetall("users:15"))
'''

def make_expensive_query():
    redis_key = "director:movies"

    cached_results = r.get(redis_key)

    if cached_results:
        print("cache hit")
        return json.loads(cached_results)
    else:
        print("cache miss")

        res = cur.execute("SELECT COUNT(*), director FROM movies GROUP BY director;")
        
        all_rows = res.fetchall()

        r.set(redis_key, json.dumps(all_rows), ex=20)

        return all_rows


v = make_expensive_query()

conn.commit()
conn.close()
r.close()