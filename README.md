ImgShark
========
Like a shark its, uh, good at resizing and storing images, an images archive.

Install
-------
  
    gem install imgshark

Requirements
------------
 - Redis - `brew install redis` or `heroku addons:add redistogo:nano` the gem will pickup the `REDISTOGO_URL` env variable when deployed on heroku.
 
 - Amazon S3 account. The gem will look for `AMAZON_ACCESS_KEY_ID` and `AMAZON_SECRET_ACCESS_KEY` env varialbes to connect to your account, you can always specify the connection parameters manually (show below).

Usage
-----

    require 'imgshark'
    
    # You can initialize it manually or use env variables.
    # The amazon env variables are named the same as the keys below.
    # The Redis env variable is REDISTOGO_URL so its heroku ready.
    i = ImgShark.new(amazon_access_key_id: 'somekey', 
                   amazon_secret_access_key: 'shhhhh', 
                   amazon_bucket: 'bucket_of_awesome',
                   redis_url: 'redis://whereisredis:someport/0')
    # => #<ImgShark:0x000001025658a8 @redis=#<Redis client v2.2.2 connected to redis://127.0.0.1:6379/0 (Redis v2.4.2)>, @json=#<Yajl::Parser:0x00000102564e58>, @bucket="bucket_of_awesome"> 

    i.redis.flushall
    # => "OK" 
    i.redis.keys
    # => [] 
    
    i.get_url('http://i.imgur.com/onLqO.jpg', 100, 100)
    # Resizes the image and uploads to S3
    # => "http://s3.amazonaws.com/bucket_of_awesome/onLqO_100X100.jpg" 
    
    i.redis.keys
    # => ["cabf75fecf67c2197e2034aed0e90e36ed899342"] 
    
    i.get_url('http://i.imgur.com/onLqO.jpg', 100, 100)
    # Hits the redis cache, insanely fast response.
    # => "http://s3.amazonaws.com/bucket_of_awesome/onLqO_100X100.jpg"
    
    i.redis.keys
    # => ["cabf75fecf67c2197e2034aed0e90e36ed899342"]
    
    i.get_url('http://underwaterschoolbus.com/images/Godzilla.gif', 100, 100)
    # Cache miss! Upload!
    # => "http://s3.amazonaws.com/bucket_of_awesome/images/Godzilla_100X100.gif" 
    
    i.redis.keys
    # => ["cabf75fecf67c2197e2034aed0e90e36ed899342", "c54cc8e5d37b467b943cb6eed8c632c4d1985a9f"] 
   
    i.get_url('http://underwaterschoolbus.com/images/Godzilla.gif', 400, 400)
    # Cache miss! Upload!
    # => "http://s3.amazonaws.com/bucket_of_awesome/images/Godzilla_400X400.gif" 
    
    i.redis.keys
    # => ["cabf75fecf67c2197e2034aed0e90e36ed899342", "8a5b2e4b49aeda688a9fdc15764e6edf01e10e81", "c54cc8e5d37b467b943cb6eed8c632c4d1985a9f"]
    
    i.get_url('http://underwaterschoolbus.com/images/Godzilla.gif', 400, 400)
    # Cache hit!
    # => "http://s3.amazonaws.com/bucket_of_awesome/images/Godzilla_400X400.gif" 
    
    i.redis.keys
    # => ["cabf75fecf67c2197e2034aed0e90e36ed899342", "8a5b2e4b49aeda688a9fdc15764e6edf01e10e81", "c54cc8e5d37b467b943cb6eed8c632c4d1985a9f"]

