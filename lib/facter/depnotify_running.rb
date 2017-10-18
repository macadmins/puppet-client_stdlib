Facter.add('depnotify_running') do
  confine osfamily: 'Darwin'
  setcode do
    depnotify_running = false
    output = Facter::Util::Resolution.exec("/bin/ps axo pid,command | grep \"[D]EPNotify.app\"")
    if $CHILD_STATUS.exitstatus === 0
      depnotify_running = true
    end
    depnotify_running
  end
end
