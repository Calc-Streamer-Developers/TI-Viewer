# TI-Viewer

Free viewer of your calculator's screen based on libticalcs2.

## Dependencies

```
sudo apt-get install cmake valac libgtk-3-dev libticables-dev libtifiles-dev libticalcs-dev
```

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