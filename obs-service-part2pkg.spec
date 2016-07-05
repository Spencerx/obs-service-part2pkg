#
# spec file for package obs-service
#
# Copyright (c) 2016 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


%define service part2pkg

Name:           obs-service-%{service}
Version:        0.0.0
Release:        0
Summary:        An OBS source service: to create binary packages of snappy parts
License:        GPL-2.0+
Group:          Development/Tools/Building
Source0:        %name-%version.tar.gz
Requires:       perl-YAML
Requires:       perl-YAML-LibYAML
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description

%prep
%setup -q

%build

%install

mkdir -p %buildroot/usr/lib/obs/service
cp -a part2* %buildroot/usr/lib/obs/service

%files
%defattr(-,root,root)
%dir %{_prefix}/lib/obs
%{_prefix}/lib/obs/service

%changelog
