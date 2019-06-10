elm_bin_url="https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"


pip3 install --upgrade pip
pip3 install --user -r requirements.txt


cd /app/.local/bin/
curl -L $elm_bin_url  | tar xz
