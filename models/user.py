import flask_login

class User(flask_login.UserMixin):
    def __init__(self, name, email, id=None):
        self.name = name
        self.email = email
        self.id = id

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
            self.id = cursor.lastrowid
        else:
            cursor.exectue('''
              UPDATE users
              SET name = ?, email = ?
              WHERE id = ?
            ''', (self.name, self.email, self.id)
            )


    @classmethod
    def get(cls, cursor, id):
        cursor.execute('''
            SELECT * FROM users WHERE id = ?
        ''', id)
        res = cursor.fetchone()
        if res is None:
            return None
        
        return User(name=res['name'], email=res['email'], id=res['id'])

    @classmethod
    def create_table(cls, cursor):
        cursor.execute('DROP TABLE IF EXISTS shortcuts')

        cursor.execute('''
        CREATE TABLE users
        ( id INT PRIMARY KEY NOT NULL AUTO_INCREMENT
        , name TEXT NOT NULL
        , email TEXT NOT NULL
        )''')

