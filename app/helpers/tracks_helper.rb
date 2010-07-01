require 'rubygems'
require 'uuidtools'

module TracksHelper
   def before_create()
    self.uuid = UUID.timestamp_create().to_s
  end
end
