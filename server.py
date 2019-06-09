from flask import Flask, render_template, send_from_directory
from flask_socketio import SocketIO, emit

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)


@app.route("/")
def hello():
  return send_from_directory('static', 'index.html')

DREAMS = []

@socketio.on('dream')
def handle_dream(json):
    DREAMS.append(json['dream'])
    print(json)
    emit('dream', DREAMS)
    

if __name__ == '__main__':
    socketio.run(app)