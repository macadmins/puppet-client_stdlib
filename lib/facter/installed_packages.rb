# frozen_string_literal: true

Facter.add("installed_packages") do
  confine osfamily: "Darwin"
  setcode do
    require "puppet/util/plist"

    items = {}

    output = Facter::Util::Resolution.exec("/usr/sbin/pkgutil --regexp --pkg-info-plist '.*'")

    pkginfos = output.split("\n\n\n")

    pkginfos.each do |pkginfo|
      data = Puppet::Util::Plist.parse_plist(pkginfo)
      pkgid = data["pkgid"]
      items[pkgid.encode("iso-8859-1", undef: :replace, replace: "")] = {
        "version" => data["pkg-version"],
        "installtime" => data["install-time"],
        "installlocation" => data["install-location"],
        "volume" => data["volume"],
      }
    end

    items
  end
end

# yes, windows machines exist
Facter.add("installed_packages") do
  confine :kernel => "windows"
  setcode do
    require "win32/registry"

    # Generate empty array to store hashes
    installed_packages = {}

    # Check if reg path exist, return true / false
    def key_exists?(path, scope)
      begin
        Win32::Registry::scope.open(path, ::Win32::Registry::KEY_READ)
        return true
      rescue
        return false
      end
    end

    # Loop through all uninstall keys for 64bit applications.
    Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\Windows\CurrentVersion\Uninstall') do |reg|
      reg.each_key do |key|
        k = reg.open(key)
        displayname = k["DisplayName"] rescue nil
        version = k["DisplayVersion"] rescue nil
        uninstallpath = k["UninstallString"] rescue nil
        systemcomponent = k["SystemComponent"] rescue nil
        installdate = k["InstallDate"] rescue nil

        if (displayname && uninstallpath)
          unless (systemcomponent == 1)
            installed_packages[displayname] = {
              "version" => version,
              "installdate" => installdate,
            }
          end
        end
      end
    end

    # Loop through all uninstall keys for 32bit applications.
    Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall') do |reg|
      reg.each_key do |key|
        k = reg.open(key)

        displayname = k["DisplayName"] rescue nil
        version = k["DisplayVersion"] rescue nil
        uninstallpath = k["UninstallString"] rescue nil
        systemcomponent = k["SystemComponent"] rescue nil
        installdate = k["InstallDate"] rescue nil

        if (displayname && uninstallpath)
          unless (systemcomponent == 1)
            installed_packages[displayname] = {
              "version" => version,
              "installdate" => installdate,
            }
          end
        end
      end
    end

    # Loop through all uninstall keys for user applications.
    Win32::Registry::HKEY_USERS.open('\\') do |reg|
      reg.each_key do |sid|
        unless (sid.include?("_Classes"))
          path = "#{sid}\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
          scope = "HKEY_USERS"
          if key_exists?(path, scope)
            Win32::Registry::scope.open(path) do |userreg|
              userreg.each_key do |key|
                k = userreg.open(key)
                displayname = k["DisplayName"] rescue nil
                version = k["DisplayVersion"] rescue nil
                uninstallpath = k["UninstallString"] rescue nil
                installdate = k["InstallDate"] rescue nil

                if (displayname && uninstallpath)
                  installed_packages[displayname] = {
                    "version" => version,
                    "installdate" => installdate,
                  }
                end
              end
            end
          end
        end
      end
    end
    installed_packages
  end
end
