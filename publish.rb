# copyright regis d'Aubarede, License : MIT

#################################################################################################################
# publish.rb : publie un message sur un 
#     . vers un serveur rabbitmq par defaur
#     . exchangeName / routing_key message en argument
#
# Usage:
#  > ruby publish.rb 127.0.0.1 broker broker.entry "{'type': 'icnode'}"
#
#################################################################################################################
require 'bunny' # gem install bunny
require 'json'
require_relative 'connector.rb'

def mlog(*t)
  mess="#{Time.now.strftime('%H:%M:%S')} | AMQP #{t.join(' ')}" 
  puts mess
end
def log(*t) mlog(*t) end

######################### M A I N ###################################

  if ARGV.size<3
    puts  "Usage: >ruby #{$0} ip-server user pass exchange topic        json  (json: string,' remplassé par \")"
    puts %{Usage: >ruby #{$0} localhost ca   ca   broker   broker.entry "{'type': 'icnode'}" } 
    exit(1) 
end

host=ARGV.shift
user=ARGV.shift
pass=ARGV.shift
topic=ARGV.shift
routing=ARGV.shift
mess=ARGV.join(" ").gsub("'",'"')
json=JSON.parse(mess) rescue (puts "error scaning #{mess} : #{$!}"; exit(1))


con=SaiaAmqpConnector.new({host: host,user: user, pass: pass})
con.declare_topic(topic,routing) 
con.send_data(topic,routing, JSON.generate(json) ) 
sleep(0.1)