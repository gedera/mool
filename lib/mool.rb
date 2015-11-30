mydir = File.expand_path(File.dirname(__FILE__))

require 'i18n'
require 'mool/version'
require 'mool/service'
require 'mool/cpu'
require 'mool/disk'
require 'mool/memory'


I18n.load_path += Dir[File.join(mydir, 'locales', '*.yml')]

module Mool
  # Your code goes here...
end
