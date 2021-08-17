Name:       harbour-ownkeepass

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    A password safe application
Version:    2.0.1
Release:    1
Group:      Qt/Qt
License:    GPL v2
URL:        https://github.com/jobe-m/ownkeepass
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 0.0.10
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Concurrent)
BuildRequires:  libargon2-devel
BuildRequires:  pkgconfig(libsodium)
BuildRequires:  pkgconfig(libgcrypt)
BuildRequires:  qt5-qttools-linguist

%description
ownKeepass is a password safe application for the Sailfish OS platform.
You can use it to store your passwords for webpages, PINs, TANs and any
other data that should be kept secret on your Jolla Smartphone. The
database where that data is stored is encrypted using a master password.

%prep
%setup -q -n %{name}-%{version}/Sailfish

%build

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
