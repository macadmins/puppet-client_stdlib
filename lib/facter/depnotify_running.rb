# frozen_string_literal: true

Facter.add('depnotify_running') do
  confine osfamily: 'Darwin'
  setcode do
    depnotify_running = false
    _ = Facter::Util::Resolution.exec('/bin/ps axo pid,command | grep "[D]EPNotify.app"')
    depnotify_running = true if $CHILD_STATUS.exitstatus.zero?
    depnotify_running
  end
end
