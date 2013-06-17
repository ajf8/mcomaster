# Generated from mcomaster-0.0.1.gem by gem2rpm -*- rpm-spec -*-
#%{?scl:Requires:%scl_runtime}

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
    %global scl_rake /usr/bin/ruby193-rake
    ### TODO temp disabled for SCL
    %global nodoc 1
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif

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

Requires: %{?scl_prefix}ruby
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}rubygem(bundler)
Requires(pre): shadow-utils
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts

BuildRequires: %{?scl_prefix}ruby
BuildRequires: %{?scl_prefix}rubygem(bundler)
BuildRequires: scl-utils-build

%description
mcomaster is a web interface to mcollective.

%prep
%setup -q
#rm Gemfile.lock
scl enable ruby193 "bundle install --deployment --without test development"
#scl enable ruby193 "bundle package"
mv config/application.example.yml config/application.yml
mv config/database.example.yml config/database.yml
scl enable ruby193 "bundle install --local --binstubs"
scl enable ruby193 "RAILS_ENV=production rake db:migrate"
scl enable ruby193 "bundle exec rake assets:precompile"

%install

install -d -m0755 %{buildroot}%{_datadir}/%{name}
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/run/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}
install -Dp -m0644 %{SOURCE2} %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{SOURCE1} %{buildroot}%{_initrddir}/%{name}
install -Dp -m0644 %{SOURCE3} %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

cp -p -r bin app config config.ru extra Gemfile Gemfile.lock lib Rakefile script mcollective vendor %{buildroot}%{_datadir}/%{name}

# Move config files to %{_sysconfdir}
for i in database.yml application.yml; do
mv %{buildroot}%{_datadir}/%{name}/config/$i %{buildroot}%{_sysconfdir}/%{name}
ln -sv %{_sysconfdir}/%{name}/$i %{buildroot}%{_datadir}/%{name}/config/$i
done
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

%clean
rm -rf %{buildroot}

%pre
# Add the "mcomaster" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
useradd -r -g %{name} -d /var/lib/mcomaster -s /sbin/nologin -c "mcomaster" %{name}
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
