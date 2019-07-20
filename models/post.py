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

class PostForPrinting:
    def __init__(self, author_name, date, content):
        self.author_name = author_name
        self.date = date
        self.content = content
   
    @classmethod
    def getAll(cls, cursor):
    
        @classmethod
    def getAll(cls, cursor):
      cursor.execute('''
          SELECT name, content timestamp 
          FROM posts
          JOIN users ON 
      ''')
      return [ User._from_row(row) for row in cursor.fetchall() ]