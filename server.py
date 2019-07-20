from flask import Flask, render_template, request, session, g, redirect, url_for
import flask_login
import sqlite3
from models.user import User

DATABASE = '.data/db.sqlite'
app = Flask(__name__)
app.secret_key = 'mysecret!'

##############################################################################
#                BOILERPLATE CODE (you can essentially ignore this)          #
##############################################################################

def get_db():
    """Boilerplate code to open a database
    connection with SQLite3 and Flask.
    Note that `g` is imported from the
    `flask` module."""
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = make_dicts
    return db

def make_dicts(cursor, row):
    return dict((cursor.description[idx][0], value)
                for idx, value in enumerate(row))

@app.teardown_appcontext
def close_connection(exception):
    """Boilerplate code: function called each time 
    the request is over."""
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()
        
##############################################################################
#                APPLICATION CODE (read from this point!)                    #
##############################################################################
login_manager = flask_login.LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login_get'

@login_manager.user_loader
def load_user(id):
    db = get_db()
    cur = db.cursor()
    return User.getById(cur, id)

@app.route("/")
@flask_login.login_required
def home():
  return send_from_directory('static', 'index.html')

@app.route("/login", methods=['POST'])
def login_post():
    print("hello")
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember_me')
    if not email or not password:
        print("pass")
        return render_template(
          'login.html',
          error_msg="Please provide your email and your password.",
        )

    db = get_db()
    cur = db.cursor()
    
    user = User.getByEmail(cur, email)
    if user is None or not user.check_password(password):
        print("hi")
        return render_template(
          'login.html',
          error_msg="Authentication failed",
        )
    print("logg in")
    flask_login.login_user(user, remember=remember)
    print(flask_login.current_user)
    return redirect(url_for('home'))

@app.route('/login', methods=['GET'])
def login_get():
    return render_template('login.html')

  
@app.route('/register', methods=['GET'])
def register_get():
    return render_template('register.html')

@app.route("/register", methods=['POST'])
def register_post():
    email = request.form.get('email')
    name = request.form.get('name')
    password1 = request.form.get('password1')
    password2 = request.form.get('password2')
    if not email or not name or not password1 or not password2:
        return render_template(
          'register.html',
          error_msg="Please provide your email, name and password.",
        )


    if password1 != password2:
        return render_template(
          'register.html',
          error_msg="The passwords do not match!",
        )
      
    user = User(name=name, email=email, password=password1)
    db = get_db()
    cur = db.cursor()
    try:
        user.save(cur)
    except sqlite.IntegrityError:
        return render_template(
          'register.html',
          error_msg="This is email is already registered.",
        )
    
    return redirect(url_for('login_get'))
    

if __name__ == '__main__':
    app.run(debug=True)
