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

# yes, windows machines exist
# set to break if powershell cannot be found at the defined path
Facter.add('installed_packages') do
  confine osfamily: 'Windows'

  setcode do

    if Facter.value(:os)['release']['full'].to_i >= 10

      require 'json'

      powershell = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'
      # rubocop:disable LineLength
      command = 'gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json'

      if File.exist?(powershell)

        raw = Facter::Util::Resolution.exec(%(#{powershell} -command "#{command}"))

        # rubocop:enable LineLength
        installed_packages = {}

        items = JSON.parse(raw)

        items[1..-1].each do |item|
          # rubocop:disable LineLength
          volume = if item['InstallLocation'].nil? || item['InstallLocation'] == ''
                     # rubocop:enable LineLength
                     ''
                   else
                     item['InstallLocation'][0..2]
                   end

          item['DisplayName'] == '' if item['DisplayName'].nil?

          installed_packages[item['DisplayName']] = {
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
