import flask_login

class User(flask_login.UserMixin):
    def __init__(self, name, email):
        self.name = name
        self.email = email
        self.id = None

    def save(self, cursor):
        if self.id is None:
            cursor.execute('''
              INSERT INTO users 
              ( name
              , email
              )
              VALUES 
              (?, ?)
            ''', (self.name, self.email)
            )
            
    @classmethod
    def create_table(cls, cursor):
        cursor.execute('DROP TABLE IF EXISTS shortcuts')

        cursor.execute('''
        CREATE TABLE users
        ( id INT PRIMARY KEY NOT NULL AUTO_INCREMENT
        , name TEXT NOT NULL
        , email TEXT NOT NULL
        )''')

