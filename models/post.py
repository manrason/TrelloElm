import flask_login
import datetime


class Post:
    def __init__(self, content, author_id):
        self.content = content
        self.author_id = author_id
        self.timestamp = datetime.datetime().now().timestamp()
        
        self._rowid = None

    def insert(self, cursor):
        cursor.execute('''
          INSERT INTO posts 
          ( content
          , author_id
          , timestamp
          )
          VALUES 
          ( ?, ?, ?)
        ''', (self.content, self.author_id, self.timestamp)
        )
        self._rowid = cursor.lastrowid
        
    def update(self, cursor):
        if self._rowid is None:
            raise ValueError("can not update a post which is not in the DB")
            
        cursor.exectue('''
          UPDATE posts
          SET content = ?
          WHERE email = ?
        ''', (self.content, self._rowid)
        )

    def __repr__(self):
        return "[Post Author%s: %s]"%(self.name, self.email)
        
        
    @classmethod
    def getAll(cls, cursor):
      cursor.execute('''
          SELECT * FROM users
      ''')
      return [
        User(
          name=row['name'],
          email=row['email'],
          password_hash=row['password_hash']
        )
        for row in cursor.fetchall()
      ]

    @classmethod
    def getByEmail(cls, cursor, email):
        cursor.execute('''
            SELECT * FROM users WHERE email = ?
        ''', (email,))

        row = cursor.fetchone()
        if row is None:
            return None
        
        return User(
          name=row['name'],
          email=row['email'],
          password_hash=row['password_hash']
        )

    @classmethod
    def create_table(cls, cursor):
        cursor.execute('DROP TABLE IF EXISTS users')

        cursor.execute('''
        CREATE TABLE users      
        ( name TEXT NOT NULL
        , password_hash TEXT NOT NULL
        , email TEXT NOT NULL PRIMARY KEY
        )''')

