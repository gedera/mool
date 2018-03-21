module Mool
  class Memory

    attr_accessor :unity, :mem_used

    def initialize
      Mool::Memory.meminfo_command.scan(/(\S+):\s+(\d+)/).each do |meminfo|
        var = meminfo[0].gsub('(', '_').gsub(')', '').underscore
        instance_variable_set(
          "@#{var}",
          (meminfo[1].to_f * Mool::PARSE_TYPES[Mool::KBYTES]).round(2)
        )
        class_eval { attr_accessor var.to_sym }
      end
      @unity = Mool::BYTES
      @mem_used = @mem_total - (@mem_free +
                                @cached +
                                @buffers +
                                @swap_cached)
    end

    def to_b
      Mool.parse_to(
        self,
        (instance_variable_names - ["@unity"]),
        Mool::BYTES
      )
    end

    def to_kb
      Mool.parse_to(
        self,
        (instance_variable_names - ["@unity"]),
        Mool::KBYTES
      )
    end

    def to_mb
      Mool.parse_to(
        self,
        (instance_variable_names - ["@unity"]),
        Mool::MBYTES
      )
    end

    def to_gb
      Mool.parse_to(
        self,
        (instance_variable_names - ["@unity"]),
        Mool::GBYTES
      )
    end

    def self.meminfo_command
      File.read('/proc/meminfo')
    end
  end
end
