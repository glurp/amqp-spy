# copyright regis d'Auabrede, License : MIT

#################################################################################################################
#  subscribe.rb : abonnement a un exchenge/topic, print les messages recus
#################################################################################################################
require 'bunny' # gem install bunny
require 'json' 
require_relative 'connector.rb'

##############################################################
#  Test amqp part
#  Usage: > ruby amqp.rb.rb host topicsname data
##############################################################
def mlog(*t)
  mess="#{Time.now.strftime('%H:%M:%S')} | AMQP #{t.join(' ')}" 
  puts mess
end
def log(*t) mlog(*t) end


######################################################
 if ARGV.size<5
    puts "Usage: >ruby #{$0} ip-server user pass topic routing"
    exit(1) 
 end

host=ARGV.shift
user=ARGV.shift
pass=ARGV.shift
topic=ARGV.shift
routing=ARGV.shift
class A
  def receive_message(routing,mess)
    log "Received on #{routing} : #{mess}"
  end
end
amqp=SaiaAmqpConnector.new({host: host,user: user, pass: pass})
amqp.subscribe_topic(A.new(),topic,routing) 
amqp.post_init
sleep()
