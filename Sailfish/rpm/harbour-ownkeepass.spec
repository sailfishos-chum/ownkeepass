Name:       harbour-ownkeepass

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    A password safe application
Version:    2.1.0
Release:    1
Group:      Qt/Qt
License:    GPL v2
URL:        https://github.com/jobe-m/ownkeepass
Source0:    %{name}-%{version}.tar.bz2

Source2:    qfutureinterface.h
Source3:    qtconcurrentthreadengine.h

Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 0.0.10
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Concurrent)
#BuildRequires:  libargon2-devel
BuildRequires:  pkgconfig(libsodium)
BuildRequires:  pkgconfig(libgcrypt)
BuildRequires:  qt5-qttools-linguist

Patch25:        keepassxc-2.5.4-fixes.patch
Patch26:        keepassxc-2.6.6-fixes.patch

%description
ownKeepass is a password safe application for the Sailfish OS platform.
You can use it to store your passwords for webpages, PINs, TANs and any
other data that should be kept secret on your Jolla Smartphone. The
database where that data is stored is encrypted using a master password.

PackageName: ownKeepass
Type: desktop-application
Icon: https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/Sailfish/icons/harbour-ownkeepass.svg
Screenshots:
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass1.png
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass2.png
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass3.png
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass4.png
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass5.png
  - https://raw.githubusercontent.com/sailfishos-chum/ownkeepass/master/screenshots/screenshot-ownkeepass6.png
Categories:
  - Office
  - Utility
AIRating: B
AINote: TOTP support developed with AI, but code human-reviewed.

%prep
%setup -q -n %{name}-%{version}/Sailfish
%dnl %patch -P 25 -p1 -d ../common/src/keepassPlugin/keepass2_database/keepassxc/
%dnl %patch -P 26 -p1 -d ../common/src/keepassPlugin/keepass2_database/keepassxc/
cp %{S:2} ../common/src/keepassPlugin/keepass2_database/keepassxc/src/core
cp %{S:3} ../common/src/keepassPlugin/keepass2_database/keepassxc/src/core
%build

CXXFLAGS="${CXXFLAGS} -std=c++20"

%qtc_qmake5  \
    VERSION=%{version}

%qtc_make %{?_smp_mflags}

%install
rm -rf %{buildroot}

%qmake5_install

%files
%defattr(-,root,root,-)
%defattr(644,root,root,-)
%{_datadir}/icons/hicolor/86x86/apps
%{_datadir}/icons/hicolor/108x108/apps
%{_datadir}/icons/hicolor/128x128/apps
%{_datadir}/icons/hicolor/256x256/apps
%{_datadir}/applications
%{_datadir}/harbour-ownkeepass
%attr(755,-,-) %{_bindir}
