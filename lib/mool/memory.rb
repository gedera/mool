class MoolMemory
  PATH_PROC_MEMORY = "/proc/meminfo"
  PARSE_TYPES = { "Bytes" => 1, "KBytes" => 2**10, "MBytes" => 2**20, "GBytes" => 2**30 }

  attr_reader :values_in, :mem_used

  def initialize(type="Bytes")
    File.read(PATH_PROC_MEMORY).scan(/(\S+):\s+(\d+)/).each do |meminfo|
      var = meminfo[0].gsub("(", "_").gsub(")", "").underscore
      instance_variable_set("@#{var}", (meminfo[1].to_f * 1024).round(2))
      class_eval{attr_reader var.to_sym}
    end
    @values_in = "Bytes"
    @mem_used = @mem_total - (@mem_free + @cached + @buffers + @swap_cached )
  end

  def to_b;  parse_to("Bytes");  end
  def to_kb; parse_to("kBytes"); end
  def to_mb; parse_to("MBytes"); end
  def to_gb; parse_to("GBytes"); end

  private

  def parse_to(parse)
    (instance_variable_names - ["@values_in"]).each do |var|
      value = ((instance_variable_get(var).to_f * PARSE_TYPES[@values_in]) / PARSE_TYPES[parse])
      instance_variable_set(var, value)
    end
    @values_in = parse
    self
  end

end
