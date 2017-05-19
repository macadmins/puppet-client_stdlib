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

  require 'json'

	powershell = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'
	command = 'gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Convertto-json'

 	if File.exists?(powershell)

	raw = Facter::Util::Resolution.exec(%Q{#{powershell} -command "#{command}"})

	installed_packages = {}

	items = JSON.parse(raw)

	for item in items[1..-1]

		if item['InstallLocation'].nil? || item['InstallLocation'] == ""
			volume = ""
		else
			volume = item['InstallLocation'][0..2]
		end

		if item['DisplayName'].nil?
			item['DisplayName'] == ""
		end

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
