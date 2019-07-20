from flask import Flask, render_template, send_from_directory, request, session, jsonify
import flask_login

from models.user import User

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'

login_manager = flask_login.LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login_get'
login_manager.user_loader(User.getById)

@app.route("/")
@flask_login.login_required
def hello():
  return send_from_directory('static', 'index.html')

@app.route("/login", methods=['POST'])
def login_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember_me')
    if not email or not password:
        return render_template(
          'login.html',
          error_msg=("Please provide your email and your password."),
        )


    user = User.getByEmail(email)
    if user is None or not user.check_password(password):
          return render_template(
            'login.html',
            error_msg=("Authentication failed" ),
          )
    
    flask_login.login_user(user, remember=remember)
    return redirect(url_for('home'))

@app.route('/login', methods=['GET'])
def login_get():
    return render_template('login.html')

    

if __name__ == '__main__':
    app.run(debug=True)
