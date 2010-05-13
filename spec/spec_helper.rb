$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'purple_ruby'
require 'spec'
require 'spec/autorun'

PurpleRuby.init :debug => false

Spec::Runner.configure do |config|

end
