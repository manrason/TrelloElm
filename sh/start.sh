elm make src/Main.elm --output public/elm.js

PYTHONUNBUFFERED=true python3 server.py


#  let's start a basic webserver to stop Glitch from constantly restarting
source ${APP_TYPES_DIR}/utils.sh
export PATH="${PATH}:${DEFAULT_NODE_DIR}"
ws --port 3000 --log.format combined --directory . --blacklist '/.env' '/.data' '/.git' &
pid=$!

wait ${pid}