from flask import Flask, render_template, send_from_directory, request, session, jsonify
import flask_login

from models.user import User

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'

login_manager = flask_login.LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login_get'
login_manager.user_loader(User.get)

@app.route("/")
def hello():
  return send_from_directory('static', 'index.html')

@app.route("/login", methods=['POST'])
def login_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember_me')
    if not email or not password:
        flash("Please provide your email and your password.")
        return render_template('login.html', error_msg=("Please provide your email and your password." )


    user = User.query.get(email)
    if user is None or not user.check_password(password):

@app.route('/login', methods=['GET'])
def login_get():
    return flask.render_template('login.html')

    

if __name__ == '__main__':
    app.run(debug=True)
