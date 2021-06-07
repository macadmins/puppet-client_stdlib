# ruby hash

require 'cfpropertylist' if Puppet.features.cfpropertylist?
require 'puppet/util/plist' if Puppet.features.cfpropertylist?

# Accepts a hash as input and returns a plist
module Puppet::Parser::Functions
  newfunction(:plist, type: :rvalue) do |args|
    hash   = args[0]      || {}
    format = args[1]      || :xml
    plist_to_save       = CFPropertyList::List.new
    opts = {:convert_unknown_to_string => true}
    plist_to_save.value = CFPropertyList.guess(hash, opts)
    fmt_opts = {:formatted => true}
    return plist_to_save.to_str(Puppet::Util::Plist.to_format(format), fmt_opts)
  end
end
