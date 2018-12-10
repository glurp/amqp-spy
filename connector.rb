# copyright regis d'Auabrede, License : MIT

class SaiaAmqpConnector
  def initialize(options)
      @conn = Bunny.new(options)
      @conn.start
      @channel = @conn.create_channel
      @exchange={}
      @clients=Hash.new {|h,k| h[k]=[] }
  end
  
  def post_init
   @clients.keys.each do |(topicName,route)|
        channel=@exchange[topicName]
        queue  = @channel.queue("", :exclusive => true)
        log "   subscribe to channel(#{topicName}) routing_key=#{route} ..."
        queue.bind(channel, :routing_key => route).subscribe() do |di, meta, payload|
            mess=(JSON.parse(payload) rescue (log "ERROR PARSING JSON : #{$!}  / #{payload}" ; nil))
            next unless mess
            @clients[[topicName,route]].each {|c|  
                c.receive_message(di.routing_key,mess) 
            }
      end
   end
  end
  def shutdown() 
     @conn.close rescue nil
  end
  
  def test_ok() ! @channel.closed?  end
  
  def subscribe_topic(client,topicName,route)
    if route.kind_of?(Array)
       route.each {|r| subscribe_topic(client,topicName,r) }
       return
    end
    @clients[[topicName,route]] << client unless @clients[[topicName,route]] && @clients[[topicName,route]].member?(client)
    @exchange[topicName]    = @channel.topic(topicName,  :auto_delete => false )  unless @exchange[topicName]
  end
  
  def declare_topic(topicName,route) # for publisher-only
    @exchange[topicName]    = @channel.topic(topicName,  :auto_delete => false ) unless @exchange[topicName]
  end
    
  def send_data(topicName,routing,data)
    puts "publish(#{data},  #{routing})"
    @exchange[topicName].publish(data.to_s,  :routing_key => routing)
  end
end
