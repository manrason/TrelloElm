import datetime

class Post:
    def __init__(self, content, author_id, timestamp, rowid):
        self.content = content
        self.author_id = author_id
        self.timestamp = timestamp
        
        self._rowid = rowid

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
        return "[Post by %s at %s: %s]"%(
            self.author_id, 
            str(datetime.datetime.fromtimestamp(self.timestamp)),
            self.content[:50]
        )
    
    @classmethod
    def new(cls, content, author_id):
        return cls(
            content=content,
            author_id=author_id,
            rowid=None,
            timestamp=datetime.datetime.now().timestamp(),
        )

    def _from_row(cls, row):
        return User(
          content=row['content'],
          author_id=row['author_id'],
          rowid=row['rowid'],
          timestamp=row['timestamp']
        )

    @classmethod
    def getAll(cls, cursor):
      cursor.execute('''
          SELECT * FROM posts
      ''')
      return [ User._from_row(row) for row in cursor.fetchall() ]

    

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

