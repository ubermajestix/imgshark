require "aws/s3"
require "redis"
require 'digest/sha1'
require 'yajl'
require 'json'
require 'map'
require 'http'
require 'rmagick'

class ImgShark
  
  attr_reader :redis
  attr_reader :json
  attr_accessor :bucket
  
  def initialize(opts = {})
    AWS::S3::Base.establish_connection!(
      :access_key_id     => opts.delete(:amazon_access_key_id) || ENV['AMAZON_ACCESS_KEY_ID'], 
      :secret_access_key => opts.delete(:amazon_secret_access_key) || ENV['AMAZON_SECRET_ACCESS_KEY']
    )
    redis_url = opts.delete(:redis_url) || ENV['REDISTOGO_URL']
    @redis = redis_url ? Redis.new(redis_url) : Redis.new()
    @json = Yajl::Parser.new
    @bucket = opts.delete(:amazon_bucket) || ENV['AMAZON_BUCKET']
  end
  
  def get_url(url, height, width)
    @image = ImgShark::Image.new(self, url: url, h: height, w: width)
    if @image.exists?
      find(@image.key).amazon_url
    else
      if !@image.on_amazon?
        @image.resize
        @image.upload
      end
      @image.save
      @image.amazon_url
    end
  end
  
  def find(key, response_type = {object: true})
    json = Yajl::Parser.new
    response = redis.get(key)
    if response_type[:object]
      ImgShark::Image.new(self, json.parse(response)) if response && response.kind_of?(String)
    elsif response_type[:json]
      json.parse response
    else
      response
    end
  end

end

class ImgShark::Image < Map
  
  attr_reader :imgshark
  attr_accessor :blob
  
  def initialize(imgshark, attributes)
    @imgshark = imgshark
    super(attributes)
  end
  
  def save
    response = imgshark.redis.set(key, attributes.to_json)
    response == 'OK'
  end
  
  def exists?
    !!imgshark.find(key, {})
  end
  
  def resize
    data = Http.get(url) # todo check status
    data = Magick::Image.from_blob(data).first
    self.blob = data.resize_to_fill(width, height).to_blob
  end
  
  def upload(opts = {:access => :public_read})
    raise 'no blob' unless blob
    # TODO upload only if the image isn't there
    AWS::S3::S3Object.store(filename, blob, imgshark.bucket, opts) 
  end
  
  def attributes
    {url: url, h: height, w: width, amazon_url: amazon_url }  
  end
  
  def filename
     @filename = url.split('?').first.split('/').last
     ext = File.extname(@filename)
     @filename.gsub(ext, "_#{height}X#{width}#{ext}")
  end
  
  def height
    self.h.to_i
  end
  
  def width
    self.w.to_i
  end
  
  def amazon_url
    "http://s3.amazonaws.com/#{amazon_path}"
  end
  
  def amazon_path
    "#{imgshark.bucket}/#{filename}"
  end
  
  def on_amazon?
    #Http.head(amazon_url).status == 200
    false
  end
  
  def key
    Digest::SHA1.hexdigest("#{url}#{height}#{width}")
  end
  
end