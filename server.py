from flask import Flask, render_template, send_from_directory, jsonify
from flask_socketio import SocketIO, emit

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)


@app.route("/")
def hello():
  return send_from_directory('static', 'index.html')

DREAMS = []

@socketio.on('dream')
def handle_dream(dream):
    DREAMS.append(dream)
    emit('dreams', DREAMS, broadcast=True)
    
@socketio.on('disconnect') 
def handle_disconnect():
    DREAMS.append('Déconnexion')
    emit('dreams', DREAMS, broadcast=True)
    

if __name__ == '__main__':
    socketio.run(app)
