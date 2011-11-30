require 'spec_helper'

describe ImgShark do
  
  # TODO use vcr
  
  before :each do
    @img = ImgShark.new(amazon_bucket: 'ubermajestix')
    @image = ImgShark::Image.new @img, url: 'http://example.com/example.png', h: 1, w: 1
    redis.set @image.key, @image.attributes.to_json
  end
  
  it "should grab an image from the internet, resize it, store it on s3 and give me the new url" do
    @img.get_url('http://i.imgur.com/onLqO.jpg', 20, 20).should == "http://s3.amazonaws.com/ubermajestix/onLqO_20X20.jpg"
  end 


end

describe ImgShark::Image do
  before :each do
    @img = ImgShark.new()
    @image = ImgShark::Image.new(@img, url: 'http://example.com/example.png', h: 1, w: 1)
  end
  
  it "should respond to height and width" do
    @image.width.should == 1
    @image.height.should == 1
  end
  
  it "should get a filename with the size init" do
    @image.filename.should == "example_1X1.png"
  end
  
  it "should know if something doesn't exist" do
    @image.should_not exist
  end
  

end