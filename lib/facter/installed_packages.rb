Facter.add('installed_packages') do
  confine osfamily: 'Darwin'
  require 'puppet/util/plist'
  setcode do
    items = {}

    output = Facter::Util::Resolution.exec("/usr/sbin/pkgutil --regexp --pkg-info-plist '.*'")

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

# yes, windows machines exist
# set to break if powershell cannot be found at the defined path
Facter.add('installed_packages') do
  confine osfamily: 'Windows'

  setcode do
    if Facter.value(:os)['release']['full'].to_i >= 10

      require 'json'

      powershell = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'

      command = 'gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json'

      if File.exist?(powershell)

        raw = Facter::Util::Resolution.exec(%(#{powershell} -command "#{command}"))

        installed_packages = {}

        items = JSON.parse(raw)

        items[1..-1].each do |item|
          next unless item.key?('DisplayName')
          volume = if item['InstallLocation'].nil? || item['InstallLocation'] == ''
                     ''
                   else
                     item['InstallLocation'][0..2]
                   end

          display_name = if item['DisplayName'].nil?
                           ''
                         else
                           item['DisplayName'].encode('UTF-8', 'windows-1250')
                         end

          installed_packages[display_name] = {
            'version' => item['DisplayVersion'],
            'installdate' => item['InstallDate'],
            'installlocation' => item['InstallLocation'],
            'volume' => volume
          }
        end
        installed_packages
      end
    end
  end
end
