elm_build="elm make front/Register.elm --output static/elm.js"
launch_python="python3 server.py"


$elm_build && PYTHONUNBUFFERED=true $launch_python