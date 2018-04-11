Facter.add('installed_packages') do
  confine osfamily: 'Darwin'
  setcode do
    require 'puppet/util/plist'

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

      commands = [
        'gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json',
        'gp HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json',
        'gp HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json'
      ]

      if File.exist?(powershell)

        installed_packages = {}

        commands.each do |command|
          raw = Facter::Util::Resolution.exec(%(#{powershell} -command "#{command}"))
          next if raw.nil? || raw == ''
          items = JSON.parse(raw)

          if items.is_a?(Array)

            items.each do |item|
              next unless item.key?('DisplayName')

              display_name = if item['DisplayName'].nil?
                               ''
                             else
                               item['DisplayName'].encode('UTF-8', 'windows-1250')
                             end

              installed_packages[display_name] = {
                'version' => item['DisplayVersion'],
                'installdate' => item['InstallDate']
              }
            end

          else
            display_name = if items['DisplayName'].nil?
                             ''
                           else
                             items['DisplayName'].encode('UTF-8', 'windows-1250')
                           end

            installed_packages[display_name] = {
              'version' => items['DisplayVersion'],
              'installdate' => items['InstallDate']
            }
          end
        end
        installed_packages
      end
    end
  end
end
