# win_current_user.rb
Facter.add('win_current_user') do
  confine kernel: 'windows'

  setcode do
    require 'win32ole'
    username = nil
    name = nil
    domain = nil
    sid = nil
    wmi = WIN32OLE.connect('winmgmts://./root/CIMV2')
    ## First find out
    query1 = 'select Username from win32_computersystem'
    wmi.ExecQuery(query1).each do |data|
      if data.Username.nil?
        username = nil
      else
        domain, name = data.Username.split('\\')
        username = data.Username
      end
    end
    if username.nil?
      sid = nil
    else
      query2 = "select sid from win32_useraccount where name='"+name+"' and domain='"+domain+"'"
      wmi.ExecQuery(query2).each do |data|
        sid = data.SID
      end
    end
    output = {}
    output['domain_username'] = username
    output['domain'] = domain
    output['sid'] = sid
    output['username'] = name
    output
  end
end
