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
def login():
    session['login'] = request.json['login']
    return "logged in as " + session['login']



    

if __name__ == '__main__':
    app.run(debug=True)
