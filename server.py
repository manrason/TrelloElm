from flask import Flask, render_template, send_from_directory, request, session
from flask_socketio import SocketIO, emit

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)


@app.route("/")
def hello():
  return send_from_directory('static', 'index.html')

@app.route("/login", methods=['POST'])
def login():
    session['login'] = request.json['login']
    return "logged in as " + session['login']


@socketio.on('connect')
def handle_dream():
    print("hello")
    emit('dream', 'Connexion', broadcast=True)

print("oij")

@socketio.on('dream')
def handle_dream(dream):
    print("oi")
    emit('dream', dream, broadcast=True)
    
@socketio.on('disconnect') 
def handle_disconnect():
    emit('dream', 'Déconnexion!', broadcast=True)
    

if __name__ == '__main__':
    socketio.run(app)
