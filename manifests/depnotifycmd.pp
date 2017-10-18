# == Class: client_stdlib::depnotifycmd
# Uses file_line to add the line to the end of the log
# == Define: define_name
#
define client_stdlib::depnotifycmd (){
  file_line {"DEPNotifyCmd ${name}":
    path => '/var/tmp/depnotify.log'
    line => $name
  }
}
