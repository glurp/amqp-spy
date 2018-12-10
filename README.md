AMQP-SPY : guidebug.rb
======================

Simple GUI tool for show messages trafic and send (json) message to any routing_key.

Only for Topic Exchange !

![hmi](https://raw.githubusercontent.com/glurp/amqp-spy/master/hmi.png)

Tested on windows10/RabbitMQ.

Installation
============

> gem install bunny

> gem install Ruiby

> ruby guidemo.rb


TODO
====

* edit connection / reconnect ( actually : edit $config definition in beginning of guidebug.rb )
* edit messages templates (actually: dynamique reload done)
* reconnect on amqp server shutdown. (actually : exit !)
* log in file
* gem ?

License
=======
MIT
