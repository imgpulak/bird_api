# BIRD API: A basic HTTP service with a JSON API using Sinatra and MongoDB. 

The service you will build is a bird registry and it will support the following requests:

 - `GET /birds` - List all birds
 - `POST /birds` - Add a new bird
 - `GET /birds/{id}` - Get details on a specific bird
 - `DELETE /birds/{id}` - Delete a bird by id

Detailed specification is [here](https://gist.github.com/sebdah/265f4255cb302c80abd4).

------

## Language 

Ruby version - 2.3.1

------

## Web framework 

Sinatra version - 1.4.7 

------

## Database 

Mongodb version - 3.2.9 

------

## Getting started

Clone or download this repository

~~~
$ git clone git@github.com:ghoshpulak91/bird_api.git
$ cd bird_api
~~~

Install prerequisites and setting up environment.

Install mongodb

~~~
Ref: https://docs.mongodb.com/manual/installation/
~~~

If you are using Debian-based OS then run below command.

~~~
$ ./setup/install_rvm_ruby_and_gems
~~~

Else or if above script fails, then please install RVM and Ruby(2.3.1). Ref: http://tecadmin.net/install-ruby-on-rails-on-ubuntu/. Then install all gems required.

Install gems manually 

~~~ 
$ gem install bundler sinatra thin mongo json multi_json logger monitor json-schema httpclient minitest 
~~~

Use bundler 

~~~
$ bundle install
~~~

## Run the application 

To start 

~~~
$ ./start 
~~~

The application can be accessed by http://localhost:7777 . 

To stop 

~~~
$ ./stop 
~~~

## Check logs 

Log file path  

~~~
$ ./log/bird_api.log 
~~~

If you are using Linux then you can use bellow command to check log  

~~~
$ tail -f ./log/bird_api.log
~~~

## Run test suite 

To run the test suite 

~~~
$ ruby ./test/test_delete_birds_by_id.rb 
$ ruby ./test/test_get_birds_by_id.rb
$ ruby ./test/test_get_birds.rb
$ ruby ./test/test_post_birds.rb
~~~ 
