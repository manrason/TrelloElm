elm_bin_url="https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"


echo "Grab all python dependencies..."
pip3 install --user --upgrade pip >/dev/null
pip3 install --user  -r requirements.txt > /dev/null
echo "Python deps grabbed!"

echo ""
if [ ! -f "/app/.local/bin/elm" ]; then
   echo "Elm doesn't seem installed, I'm downloading it..."
   cd /app/.local/bin/
   
   curl --silent -L $elm_bin_url  | tar xz
   echo "Elm installed!"
else
   echo "Elm seems already installed!"
fi