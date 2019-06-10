elm_bin_url="https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"


pip3 install --upgrade pip
pip3 install --user -r requirements.txt

if [! -f "/app/.local/bin/elm"]; then
   echo "Elm doesn't seem installed, I'm downloading it..."
   cd /app/.local/bin/
   
   curl --silent -L $elm_bin_url  | tar xz
   echo "Elm installed!"
else
   echo "Elm seems already installed!"
fi