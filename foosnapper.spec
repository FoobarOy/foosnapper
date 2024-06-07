Name:           foosnapper
Version:        1.2
Release:        1%{?dist}
Summary:        Automatic filesystem snapshooter
License:        GPL-2.0-or-later
URL:            https://github.com/FoobarOy/foosnapper
Source0:        https://github.com/FoobarOy/foosnapper/archive/v%{version}/foosnapper-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  make
BuildRequires:  systemd-rpm-macros
Requires:       python3
%{?systemd_requires}


%description
Automatic filesystem snapshooter, supporting Stratis and Btrfs.


%prep
%autosetup -p1


%build


%install
make install DESTDIR=%{buildroot}


%post
%systemd_post foosnapper.service foosnapper.timer


%preun
%systemd_preun foosnapper.service foosnapper.timer


%postun
%systemd_postun_with_restart foosnapper.timer


%files
%license COPYING
%doc README.md

%dir %{_sysconfdir}/foosnapper
%attr(0640,root,adm) %config(noreplace) %{_sysconfdir}/foosnapper/foosnapper.conf
%{_bindir}/foosnapper
%{_unitdir}/foosnapper.service
%{_unitdir}/foosnapper.timer


%changelog
* Fri Jun 07 2024 Kim B. Heino <b@bbbs.net> - 1.2-1
- Upgrade to 1.2

* Tue Mar  7 2023 Kim B. Heino <b@bbbs.net> - 1.1-1
- Initial version
