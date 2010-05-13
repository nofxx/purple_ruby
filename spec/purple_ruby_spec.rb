require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PurpleRuby do

  describe "Listing protocols" do

    it "should list procols" do
      PurpleRuby.list_protocols.should be_an Array
    end

    it "should have a protocol" do
      PurpleRuby.list_protocols.first.should be_a PurpleRuby::Protocol
    end

  end

  describe "Instant Messages" do

    it "should watch incoming IM" do
      lambda do
        Purple.watch_incoming_im do |acc, sender, message|
          sender = sender[0...sender.index('/')] if sender.index('/') #discard anything after '/'
          puts "recv: #{acc.username}, #{sender}, #{message}"
        end
      end.should_not raise_error
    end
  end
end
