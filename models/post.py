import flask_login

class Post:
    def __init__(self, content):
        self.name = name
        self.email = email
        if password_hash is None:
            if password is None:
                raise ValueError('password and password_hash can not both be None')
            self.set_password(password)
        else:
            self.password_hash = password_hash

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
        
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def get_id(self):
        return self.email

    def insert(self, cursor):
        cursor.execute('''
          INSERT INTO users 
          ( name
          , email
          , password_hash
          )
          VALUES 
          ( ?, ?, ?)
        ''', (self.name, self.email, self.password_hash)
        )
        
    def update(self, cursor):
        cursor.exectue('''
          UPDATE users
          SET name = ?, password_hash = ?
          WHERE email = ?
        ''', (self.name, self.password_hash, self.email)
        )

    def __repr__(self):
        return "[User %s<%s>]"%(self.name, self.email)
        
        
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

