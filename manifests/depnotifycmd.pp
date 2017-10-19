# == Class: client_stdlib::depnotifycmd
# Uses file_line to add the line to the end of the log

define client_stdlib::depnotifycmd (
  String $message = '',
  ){
    if $message == '' {
      $output = $title
    } else {
      $output = $message
    }
  if $facts['depnotify_running'] == true {
    file_line {"DEPNotifyCmd ${name}":
      path => '/var/tmp/depnotify.log',
      line => $output
    }
  }
}
