#
#Example Usage:
#
#Start the daemon and receive IM:
#$ruby examples/purplegw_example.rb prpl-msn user@hotmail.com password prpl-jabber user@gmail.com password
#
#Send im:
#$ irb
#irb(main):001:0> require 'examples/purplegw_example'
#irb(main):007:0> PurpleGWExample.deliver 'prpl-jabber', 'friend@gmail.com', 'hello worlds!'
#

require 'socket'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/purple_ruby'))

class PurpleGWExample
  SERVER_IP = "127.0.0.1"
  SERVER_PORT = 9877

  def start configs
    Purple.init :debug => false, :user_dir => File.dirname(__FILE__) #use 'true' if you want to see the debug messages
    
    puts "Available protocols:", Purple.list_protocols
    
    accounts = {}
    configs.each {|config|
      puts "logging in #{config[:username]} (#{config[:protocol]})..."
      account = Purple.login(config[:protocol], config[:username], config[:password])
      accounts[config[:protocol]] = account
    }
    
    #handle incoming im messages
    Purple.watch_incoming_im do |acc, sender, message|
      sender = sender[0...sender.index('/')] if sender.index('/') #discard anything after '/'
      puts "recv: #{acc.username}, #{sender}, #{message}"
    end
    
    Purple.watch_signed_on_event do |acc| 
      puts "signed on: #{acc.username}"
    end
    
    Purple.watch_connection_error do |acc, type, description| 
      puts "connection_error: #{acc.username} #{type} #{description}"
      true #'true': auto-reconnect; 'false': do nothing
    end
    
    #request can be: 'SSL Certificate Verification' etc
    Purple.watch_request do |title, primary, secondary, who|
      puts "request: #{title}, #{primary}, #{secondary}, #{who}"
      true #'true': accept a request; 'false': ignore a request
    end
    
    #request for authorization when someone adds this account to their buddy list
    Purple.watch_new_buddy do |acc, remote_user, message| 
      puts "new buddy: #{acc.username} #{remote_user} #{message}"
      true #'true': accept; 'false': deny
    end
    
    Purple.watch_notify_message do |type, title, primary, secondary|
      puts "notification: #{type}, #{title}, #{primary}, #{secondary}"
    end
    
    #listen a tcp port, parse incoming data and send it out.
    #We assume the incoming data is in the following format (separated by comma):
    #<protocol>,<user>,<message>
    Purple.watch_incoming_ipc(SERVER_IP, SERVER_PORT) do |data|
      protocol, user, message = data.split(",").collect{|x| x.chomp.strip}
      puts "send: #{protocol},#{user},#{message}"
      puts accounts[protocol].send_im(user, message)
    end
        
    Purple.main_loop_run
  end
  
  def self.deliver(protocol, to_users, message)
    to_users = [to_users] unless to_users.is_a?(Array)      
    to_users.each do |user|
      t = TCPSocket.new(SERVER_IP, SERVER_PORT)
      t.print "#{protocol},#{user},#{message}"
      t.close
    end
  end
end

if ARGV.length >= 3
  configs = []
  configs << {:protocol => ARGV[0], :username => ARGV[1], :password => ARGV[2]}
  configs << {:protocol => ARGV[3], :username => ARGV[4], :password => ARGV[5]} if ARGV.length >= 6
  #add more accounts here if you like
  PurpleGWExample.new.start configs
end

