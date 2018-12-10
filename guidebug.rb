# copyright regis d'Aubarede, License : MIT

require 'bunny' # gem install bunny
require 'json'
require 'time'
require 'date'
require 'Ruiby'
require_relative 'connector.rb'

$config={
  :host           => "10.203.76.160",
  :port           => 5672,
  :ssl            => false,
  :vhost          => "/",
  :user           => "ca",
  :pass           => "ca",
  :heartbeat      => :server, # will use RabbitMQ setting
  :frame_max      => 131072,
  :auth_mechanism => "PLAIN",
  :topic          => 'broker',
  :routing        => "broker.entry,broker.tc,broker.ack,broker.service,broker.service,broker.icnode.tc",
  :routing_rec    => "broker.#",
  :messdefault    =>"{
   type: '',
   timstamp: '#{Time.now.to_datetime.rfc3339()}',
   date: []}"
}
$hmessage= {
  "acq connector => broker" => '
{
  "_interface": "icnode/V1",
  "_type": "index",
  "_rdate": "%now",
  "_idn2": "tsadin17",
  "data": [
    {
      "date": "%now",
      "value": "14683",
      "unit": "?"
    }
  ]
} 
  ',
  "acq broker => N3" => '
 
{
  "id": [
    "metier",
    "EP",
    "vendeur",
    "icnode",
    "composant",
    "acquisition"
  ],
  "timestampProduction": "%now",
  "data": [
    {
      "id": "tsadin17",
      "values": [
        {
          "k": "index",
          "v": "14683222",
          "unit": "?"
        }
      ]
    }
  ]
}
  ',
  "tc N3 => broker" => '
{
  "id": [
    "metier",
    "EP",
    "vendeur",
    "icnode",
    "composant",
    "switch"
  ],
  "timestampProduction": "%now",
  "data": [
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    },
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    },
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    }
  ]
}
'
}
$error=nil
if File.exists?("predef-message.rb")
begin
  h= eval(File.read("predef-message.rb"))
  $hmessage=h
rescue Exception => e
  $error="ERROR in predef-message.rb : #{e}"
end end

$keys=$config.keys - [:messdefault]

def log(*t) $app.log(*t) end

module Ruiby_dsl
  def receive_message(routing,mess)
    log "Received on routingKey '#{routing}' message: \n#{mess}"
  end
end


Ruiby.app height: 700,title: "Amqp Spy" do
  stack do
    flowi { labeli " routing_key : " ; @routk=entry "broker.icnode.tc" ; buttoni("  Go  ") { send_message() } }
    flowi {  
      buttoni("rload") { reload_predef() }
      @flow=flow { $hmessage.each { |text,mess|  buttoni(text) { @ta.text=mess.strip } } }
    }
    @ta=text_area(300,100)
    @ta.text="{}"
    flowi { @log=log_as_widget(300,200 ,{bg: "black", fg: "yellow", font: "courier new bold 10"}) }
    flowi { buttoni("Clear log") {@log.text='' } ; button("pp Last") {show_log()} ; button("Export to npp") {export_log()} }
    log "test"
  end
  
  after(1) {
    $amqp=SaiaAmqpConnector.new($config)
    $amqp.subscribe_topic(self,$config[:topic],$config[:routing_rec] )
    $amqp.post_init
    error($erreur) if $erreur
  }
  anim(1000) {
    unless $amqp.test_ok()
        log("Amqp serveur hs?, exit from connector")
        Ruiby.update
        sleep(10)
        os.exit(1)
    end
  }
  
  def send_message()
     route=@routk.text.strip
     mess=@ta.text.strip.gsub("'",'"').gsub(/\r?\n/," ")
     (alert("pas de route !") ; return ) if  route.size==0
     (alert("pas de message!") ; return ) if  mess.size==0
     mess.gsub!(/%now-(\d+)/) {|a| (Time.now-$1.to_i).to_datetime.rfc3339() }
     mess.gsub!(/%now/) {|a| Time.now.to_datetime.rfc3339() }
     begin
         mess=JSON.generate(JSON.parse(mess))
     rescue
         alert("Erreur JSON syntaxe message : #{$!}")
         return
     end
     ($amqp.send_data($config[:topic],route, mess)  ; log("to #{route} sended #{mess}") ) rescue alert("Erreur publish : #{$!}")
  end
  def export_log()
      content=@log.buffer.text.split(/\r?\n/).grep(/^\{/).join(",\n") 
      if content.size>0
        File.write("a.a", content)
        Thread.new { system('C:\Program Files (x86)\Notepad++\notepad++.exe',"a.a") }
        log "done."
      else
        log "empty!"
      end
  end
  def show_log()
      content=@log.buffer.text.split(/\r?\n/).grep(/^\{/).last(15).map { |txt| JSON.pretty_generate(eval(txt))}.join(",\n") 
      dialog_async("Edit ") {
             @editor=source_editor(:width=>500,:height=>300,:lang=> "javascript", :font=> "Courier new 12")
             @editor.editor.buffer.text= content
      }
  end
  def reload_predef()
      h= eval(File.read("predef-message.rb"))
      clear_append_to(@flow) { h.each { |text,mess|  button(text) { @ta.text=mess.strip } } }
  rescue 
     error($!)
  end
end

