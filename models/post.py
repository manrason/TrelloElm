import datetime

class Post:
    def __init__(self, content, author_id):
        self.content = content
        self.author_id = author_id
        self.timestamp = datetime.datetime.now().timestamp()

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
        
    def __repr__(self):
        return "[Post by %s at %s: %s]"%(
            self.author_id, 
            str(datetime.datetime.fromtimestamp(self.timestamp)),
            self.content[:50]
        )

    @classmethod
    def create_table(cls, cursor):
        cursor.execute('DROP TABLE IF EXISTS posts')

        cursor.execute('''
        CREATE TABLE posts
        ( author_id TEXT NOT NULL
        , content TEXT
        , timestamp DOUBLE
        , FOREIGN KEY (author_id) REFERENCES users(email)
        )''')

class PostForDisplay:
    def __init__(self, row):
        self.author_name = row['author_name']
        self.date = datetime.datetime.fromtimestamp(row['timestamp'])
        self.content = row['content']
   
    
    @classmethod
    def getAll(cls, cursor):
      cursor.execute('''
          SELECT name AS author_name, content, timestamp 
          FROM posts
          JOIN users ON author_id=email
          ORDER BY timestamp DESC
      ''')
      return [ cls(row) for row in cursor.fetchall() ]