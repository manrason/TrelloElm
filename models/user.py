import flask_login
from werkzeug.security import generate_password_hash, check_password_hash

class User(flask_login.UserMixin):
    def __init__(self, name, email, password, id=None):
        self.name = name
        self.email = email
        self.set_password(password)
        self.id = id

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
        
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def save(self, cursor):
        if self.id is None:
            cursor.execute('''
              INSERT INTO users 
              ( id
              , name
              , email
              , password_hash
              )
              VALUES 
              (NULL, ?, ?, ?)
            ''', (self.name, self.email, self.password_hash)
            )
            self.id = cursor.lastrowid
        else:
            cursor.exectue('''
              UPDATE users
              SET name = ?, email = ?, password_hash = ?
              WHERE id = ?
            ''', (self.name, self.email, self.id, self.password_hash)
            )

    def __repr__(self):
        if self.id is None:
            return "[User %s<%s> - not in DB]"%(self.name, self.email)
        return "[User %s<%s> - id: %d]"%(self.name, self.email, self.id)
        
        
    @classmethod
    def getById(cls, cursor, id):
        cursor.execute('''
            SELECT * FROM users WHERE id = ?
        ''', id)

        res = cursor.fetchone()
        if res is None:
            return None
        
        return User(
          name=res['name'],
          email=res['email'],
          id=res['id'],
          password_hash=res['password_hash']
        )

    @classmethod
    def getById(cls, cursor, email):
        cursor.execute('''
            SELECT * FROM users WHERE email = ?
        ''', email)

        res = cursor.fetchone()
        if res is None:
            return None
        
        return User(
          name=res['name'],
          email=res['email'],
          id=res['id'],
          password_hash=res['password_hash']
        )

    @classmethod
    def create_table(cls, cursor):
        cursor.execute('DROP TABLE IF EXISTS users')

        cursor.execute('''
        CREATE TABLE users      
        ( id INT PRIMARY KEY
        , name TEXT NOT NULL
        , password_hash TEXT NOT NULL
        , email TEXT NOT NULL UNIQUE
        )''')

