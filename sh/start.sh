elm_build="elm make src/Main.elm --output static/elm.js"
launch_python="python3 server.py"
PYTHONUNBUFFERED=true

$elm_build && $launch_python