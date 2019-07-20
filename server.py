from flask import Flask, render_template, send_from_directory, request, session, jsonify
import flask_login

import models.user

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'

login_manager = flask_login.LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login_get'


@app.route("/")
def hello():
  return send_from_directory('static', 'index.html')

@app.route("/login", methods=['POST'])
def login():
    session['login'] = request.json['login']
    return "logged in as " + session['login']

@app.route("/logout", methods=['POST'])
def logout():
    try:
        login = session.pop('login')
        socketio.emit('event', {
          "tag": "logout",
          "login": session['login'],
        }, broadcast=True)
        return "logged out"
    except KeyError:
        return "not logged in", 400
        

@socketio.on('connect')
def handle_dream():
    if 'login' not in session :
        raise ConnectionRefusedError('unauthorized!')

    emit('event', {
      "tag": "login",
      "login": session['login'],
    }, broadcast=True)


@socketio.on('dream')
def handle_dream(dream):
    emit('event', {
      "tag": "dream",
      "from" : session['login'],
      "content": dream,
    },
    broadcast=True)
    
@socketio.on('disconnect') 
def handle_disconnect():
    emit('event', {
      "tag": "loggout",
      "login": session['login'],
    }, broadcast=True)

    

if __name__ == '__main__':
    socketio.run(app, debug=True)
