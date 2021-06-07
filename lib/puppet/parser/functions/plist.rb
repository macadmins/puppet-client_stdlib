# ruby hash

require 'cfpropertylist' if Puppet.features.cfpropertylist?
require 'puppet/util/plist' if Puppet.features.cfpropertylist?

# Accepts a hash as input and returns a plist
module Puppet::Parser::Functions
  newfunction(:plist, type: :rvalue) do |args|
    hash   = args[0]      || {}
    format = args[1]      || :xml
    plist_to_save       = CFPropertyList::List.new
    plist_to_save.value = CFPropertyList.guess(hash, {:convert_unknown_to_string => true})
    return plist_to_save.to_str(Puppet::Util::Plist.to_format(format), {:formatted => true})
  end
end
