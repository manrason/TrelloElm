elm_bin_url="https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"

echo "Grab all python dependencies..."
pip3 install --user --upgrade pip >/dev/null
pip3 install --user  -r requirements.txt > /dev/null
echo "Python deps grabbed!"

mkdir -p .data
python3 init_db.py

echo ""
if [ ! -f "/app/.local/bin/elm" ]; then
   echo "Elm doesn't seem installed, I'm downloading it..."
   cd /app/.local/bin/
   
   curl --silent -L $elm_bin_url  | tar xz
   echo "Elm installed!"
else
   echo "Elm seems already installed!"
fi

# experiment for using elm-format but it does not play well with glitch (need to "refresh" after each elm-format...)
#elmformat_bin_url="https://github.com/avh4/elm-format/releases/download/0.8.1/elm-format-0.8.1-linux-x64.tgz"
#echo ""
#if [ ! -f "/app/.local/bin/elm-format" ]; then
#   echo "Elm-form doesn't seem installed, I'm downloading it..."
#   cd /app/.local/bin/
#   
#   curl --silent -L $elmformat_bin_url  | tar xz
#   echo "elm-format installed!"
#else
#   echo "elm-format seems already installed!"
#fi
