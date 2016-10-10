# puppet-mac_stdlib

This module contains functions that are useful in the administration of macOS.

## `plist`

This function accepts a hash and will convert it into a plist. This requires the [CFPropertyList](https://github.com/ckruse/CFPropertyList/) gem to be installed on your Puppet Server (`sudo puppetserver gem install cfpropertylist`).

### Example

``` puppet
$plist = {
    'SomeKey' => 'Some Value',
    'Another Key' => 'Another Value'
}

file {'/tmp/a.plist':
    content => plist($plist, binary),
}
```
