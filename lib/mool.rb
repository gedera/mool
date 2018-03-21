mydir = File.expand_path(File.dirname(__FILE__))

require 'i18n'
I18n.load_path += Dir[File.join(mydir, 'locales', '*.yml')]

require 'mool/version'
require 'mool/service'
require 'mool/cpu'
require 'mool/load_average'
require 'mool/disk'
require 'mool/memory'
require 'mool/system'

module Mool
  BLOCK_SIZE = 512
  BYTES = 'Bytes'.freeze
  KBYTES = 'KBytes'.freeze
  MBYTES = 'MBytes'.freeze
  GBYTES = 'GBytes'.freeze
  PARSE_TYPES = { BYTES => 1,
                  KBYTES => 2**10,
                  MBYTES => 2**20,
                  GBYTES => 2**30 }.freeze

  def self.parse_to(obj, vars, parse)
    vars.each do |var|
      value = ((obj.instance_variable_get(var).to_f * PARSE_TYPES[obj.unity]) / PARSE_TYPES[parse])
      obj.instance_variable_set(var, value)
    end
    obj.unity = parse
    obj
  end

end
