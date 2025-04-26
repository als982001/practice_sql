import sqlite3

# conn = sqlite3.connect("users.db")

# cur = conn.cursor()

'''
 def init_table():
    cur.execute("""
    CREATE TABLE users (
        user_id integer primary key autoincrement,
        username text not null,
        password text not null
    );
    """)
    cur.execute("""
    insert into users (username, password)
    values ('nico', 123), ('lynn', 321);
    """)

def print_all_users():
    res = cur.execute("select * from users")
    data = cur.fetchall()
    print(data)
    for user in data:
        print(user)


init_table()

conn.commit()

print_all_users()

conn.close()
'''

# sql injection 예시
# 안전하지 않은 방법
def i_change_password(username, new_password):
    cur.execute(
        f"UPDATE users SET password = '{new_password}' WHERE username = '{username}'"
    )

# 안전한 방법
def s_change_password(username, new_password):
    cur.execute(f"UPDATE users SET password = ? WHERE username = ?", (new_password, username))     
    

'''
i_change_password("lynn", "new password!!!")
s_change_password("nico", "hacked' --")

print_all_users()
'''

# ---


data = [
    ("lanna", 567),
    ("bora", 123),
    ("max", 123),
    ("jia", 890)
]

# cur.executemany("INSERT INTO users (username, password) VALUES (?, ?)", data)

data = [
    {"name": "lanna", "password": 567},
    {"name": "bora", "password": 123},
    {"name": "max", "password": 123},
    {"name": "jia", "password": 211212}
]

# cur.executemany("INSERT INTO users (username, password) VALUES (:name, :password)", data)
# print_all_users()

conn = sqlite3.connect("movies.db")

cur = conn.cursor()

res = cur.execute("SELECT * FROM movies")

all_movies = res.fetchall() # 커서를 끝까지 옮김
first_20 = res.fetchmany(20) # 커서를 20개 옮김
next_20 = res.fetchmany(20) # 커서를 20개 옮김
only_one = res.fetchone() # 커서를 1개 옮김

'''
이거는 의도한 대로 안됨
test_fetchall = res.fetchall() -> 커서를 끝까지 옮김
test_fetchmany = res.fetchmany(20) -> 커서에 옮길 게 없음
'''


conn.commit()
conn.close()