# frozen_string_literal: true

#
# macos_package_installed
#
require "puppet/util/package"

# Returns true if the specified or newer version of the package is installed
module Puppet::Parser::Functions
  newfunction(:macos_package_installed, type: :rvalue, doc: <<-SOMEDOC
  Returns true if the specified or newer version of the package is installed.
  SOMEDOC
  ) do |args|
    if args.size != 2
      raise(Puppet::ParseError, "macos_package_installed(): " \
      "Wrong number of arguments given (#{args.size} for 2)")
    end

    raise(Puppet::ParseError, "This can only be used on macOS") unless lookupvar("operatingsystem").casecmp("darwin").zero?

    # Alright, let's see what version is installed (if any)
    installed_packages = lookupvar("installed_packages")
    found = false
    found = true if installed_packages.key?(args[0])

    # the receipt is here, check the version against what we want
    if found == true
      version_check = Puppet::Util::Package.versioncmp(
        installed_packages[args[0]]["version"],
        args[1]
      )
      return true if version_check != -1
    end

    # If we're down here, it's not installed
    return false
  end
end
