# TI-Viewer

Free viewer of your calculator's screen based on libticalcs2.

## Compile
```
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
```

## Install
```
sudo make install
sudo gtk-update-icon-cache /usr/share/icons/hicolor
```