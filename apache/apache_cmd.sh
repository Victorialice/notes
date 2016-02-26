sudo /etc/init.d/apache2 restart


LoadModule passenger_module /home/alice/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/passenger-5.0.25/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
PassengerRoot /home/alice/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/passenger-5.0.25
PassengerDefaultRuby /home/alice/.rbenv/versions/2.3.0/bin/ruby
</IfModule>

