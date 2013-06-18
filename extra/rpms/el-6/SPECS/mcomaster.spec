Summary: Web interface to mcollective
Name: mcomaster
Version: 0.1.0
Release: 1%{?dist}
Group: Development/Languages
License: Apache 2.0
URL: http://www.mcomaster.org/
Source0: mcomaster-%{version}.tar.gz
Source1: mcomaster.init
Source2: mcomaster.sysconfig
Source3: mcomaster.logrotate
Source4: mcomaster.repo

Requires: ruby193-ruby
Requires: ruby193-rubygems
Requires: ruby193-rubygem-bundler
Requires(pre): shadow-utils
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts

BuildRequires: ruby193-ruby
BuildRequires: ruby193-rubygems
BuildRequires: ruby193-rubygem-bundler
BuildRequires: ruby193-ruby-devel
BuildRequires: make
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: sqlite-devel

%package release
Summary:        mcomaster repository files
Group:          Applications/System

%description release
This package contains the repository configuration for the mcomaster
yum repository.

%files release
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/yum.repos.d/*

%description
mcomaster is a web interface to mcollective.

%prep
%setup -q
scl enable ruby193 "bundle install --deployment --without test development"
#scl enable ruby193 "bundle package"
mv config/application.example.yml config/application.yml
mv config/database.example.yml config/database.yml
scl enable ruby193 "bundle install --local --binstubs"
scl enable ruby193 "RAILS_ENV=production rake db:migrate"
scl enable ruby193 "bundle exec rake assets:precompile"

%install
rm -rf %{buildroot}
install -d -m0755 %{buildroot}%{_datadir}/%{name}
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/run/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}
install -Dp -m0644 %{SOURCE2} %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{SOURCE1} %{buildroot}%{_initrddir}/%{name}
install -Dp -m0644 %{SOURCE3} %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE4} $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

cp -p -r bin app config config.ru extra Gemfile Gemfile.lock lib Rakefile script mcollective vendor %{buildroot}%{_datadir}/%{name}

# Move config files to %{_sysconfdir}
mv %{buildroot}%{_datadir}/%{name}/config/database.yml %{buildroot}%{_sysconfdir}/%{name}/database.yml
mv %{buildroot}%{_datadir}/%{name}/config/application.yml %{buildroot}%{_sysconfdir}/%{name}/application.yml
ln -s %{_sysconfdir}/%{name}/database.yml %{buildroot}%{_datadir}/%{name}/config/database.yml
ln -s %{_sysconfdir}/%{name}/application.yml %{buildroot}%{_datadir}/%{name}/config/application.yml
touch %{buildroot}%{_datadir}/%{name}/config/initializers/local_secret_token.rb

# Put db in %{_localstatedir}/lib/%{name}/db
cp -pr db/migrate %{buildroot}%{_datadir}/%{name}
cp -pr db/schema.rb %{buildroot}%{_datadir}/%{name}
mkdir %{buildroot}%{_localstatedir}/lib/%{name}/db
cp -p db/seeds.rb %{buildroot}%{_localstatedir}/lib/%{name}/db

ln -sv %{_localstatedir}/lib/%{name}/db %{buildroot}%{_datadir}/%{name}/db
ln -sv %{_datadir}/%{name}/migrate %{buildroot}%{_localstatedir}/lib/%{name}/db/migrate
ln -sv %{_datadir}/%{name}/schema.rb %{buildroot}%{_localstatedir}/lib/%{name}/db/schema.rb

# Put HTML %{_localstatedir}/lib/%{name}/public
cp -pr public %{buildroot}%{_localstatedir}/lib/%{name}/
ln -sv %{_localstatedir}/lib/%{name}/public %{buildroot}%{_datadir}/%{name}/public

# Put logs in %{_localstatedir}/log/%{name}
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{_datadir}/%{name}/log

# Put tmp files in %{_localstatedir}/run/%{name}
ln -sv %{_localstatedir}/run/%{name} %{buildroot}%{_datadir}/%{name}/tmp
echo %{version} > %{buildroot}%{_datadir}/%{name}/VERSION

mkdir %{buildroot}%{_datadir}/%{name}/.bundle
cat >%{buildroot}%{_datadir}/%{name}/.bundle/config <<EOF
---
BUNDLE_FROZEN: '1'
BUNDLE_PATH: vendor/bundle
BUNDLE_WITHOUT: development:test
BUNDLE_DISABLE_SHARED_GEMS: '1'
EOF

%clean
rm -rf %{buildroot}

%pre
# Add the "mcomaster" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
useradd -r -g %{name} -d /var/lib/mcomaster -s /bin/bash -c "mcomaster" %{name}
exit 0

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%{_initrddir}/%{name}
%config(noreplace) %{_sysconfdir}/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/lib/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/log/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/run/%{name}
%attr(-,%{name},root) %{_datadir}/%{name}/config.ru
%attr(-,%{name},root) %{_datadir}/%{name}/config/environment.rb
%ghost %{_datadir}/%{name}/config/initializers/local_secret_token.rb

%doc README.md
%doc INSTALL.md
%doc LICENSE

%changelog
* Mon Jun 17 2013 Alan F - 0.0.1-1
- Initial package
