%w[command
   cpu
   disk
   memory
   system
   process
   version].each do |file|
  require "mool/#{file}"
end

module Mool
  BLOCK_SIZE = 512

  BYTES = 'Bytes'.freeze
  KBYTES = 'KBytes'.freeze
  MBYTES = 'MBytes'.freeze
  GBYTES = 'GBytes'.freeze

  PARSE_TYPES = {
    BYTES => 1,
    KBYTES => 2**10,
    MBYTES => 2**20,
    GBYTES => 2**30
  }.freeze

  def self.parse_to(obj, vars, parse)
    vars.each do |var|
      value = (obj.instance_variable_get(var).to_f *
               PARSE_TYPES[obj.unity]) /
              PARSE_TYPES[parse]
      obj.instance_variable_set(var, value)
    end
    obj.unity = parse
    obj
  end
end
