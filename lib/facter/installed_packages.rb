Facter.add('installed_packages') do
  confine osfamily: 'Darwin'
  require 'puppet/util/plist'
  setcode do
    items = {}

    output = Facter::Util::Resolution.exec("/usr/sbin/pkgutil --regexp --pkg-info-plist '.*'")

    pkginfos = output.split("\n\n\n")

    for pkginfo in pkginfos
      data = Puppet::Util::Plist.parse_plist(pkginfo)
      items[data['pkgid'].encode('iso-8859-1', undef: :replace, replace: '')] = {
        'version' => data['pkg-version'],
        'installtime' => data['install-time'],
        'installlocation' => data['install-location'],
        'volume' => data['volume']
      }
    end

    items
  end
end
