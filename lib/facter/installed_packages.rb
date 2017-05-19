Facter.add('installed_packages') do
  confine osfamily: 'Darwin'
  require 'puppet/util/plist'
  setcode do
    items = {}

    # rubocop:disable LineLength
    output = Facter::Util::Resolution.exec("/usr/sbin/pkgutil --regexp --pkg-info-plist '.*'")
    # rubocop:enable LineLength

    pkginfos = output.split("\n\n\n")

    pkginfos.each do |pkginfo|
      data = Puppet::Util::Plist.parse_plist(pkginfo)
      pkgid = data['pkgid']
      items[pkgid.encode('iso-8859-1', undef: :replace, replace: '')] = {
        'version' => data['pkg-version'],
        'installtime' => data['install-time'],
        'installlocation' => data['install-location'],
        'volume' => data['volume']
      }
    end

    items
  end
end
