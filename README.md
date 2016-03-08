# TI-Viewer

Free viewer of your calculator's screen based on libticalcs2.

## How to install
.deb-packages are very handy for sharing the application. If you're running an Ubuntu based distribution you probably should use our ppa `ppa:l-admin-3/apps-daily` to not need to worry about updates. Else you might need to build your own Package for the platform you're running.

### Installing using PPA
```
sudo add-apt-repository ppa:l-admin-3/apps-daily
sudo apt-get update
sudo apt-get install ti-viewer
```

### Build your own .deb-package
To do this you need to clone this repository and open it's root directory in a terminal. Then type `debuild -us -uc` and a new .deb-package will be stored in the parent folder.

## Manual compiling
### Dependencies

```
sudo apt-get install cmake valac libgtk-3-dev libticables-dev libtifiles-dev libticalcs-dev libavahi-client-dev libavahi-gobject-dev
```

### Compile
```
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
```

### Install
```
sudo make install
sudo gtk-update-icon-cache /usr/share/icons/hicolor
```
