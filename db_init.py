import sqlite3

from user import User


def make_dicts(cursor, row):
    return dict((cursor.description[idx][0], value)
                for idx, value in enumerate(row))

  
db = sqlite3.connect(DATABASE)
db.row_factory = make_dicts

cur = db.cursor()

User.create_table(cur)

users = [
   User("Ford", "ford@betelgeuse.star"),
   User("Ford", "ford@betelgeuse.star"),
]
user2.save()