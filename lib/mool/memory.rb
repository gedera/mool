class MoolMemory
  PATH_PROC_MEMORY = "/proc/meminfo"
  PARSE_TYPES = {"Bytes" => 1, "KBytes" => 2**10, "MBytes" => 2**20, "GBytes" => 2**30}

  attr_reader :values_in, :mem_used

  def initialize(type="Bytes")
    raise "Suported types: Bytes, KBytes, MBytes, GBytes" if not MoolMemory::PARSE_TYPES.keys.include?(type)
    File.read(PATH_PROC_MEMORY).scan(/(\S+):\s+(\d+)/).each do |meminfo|
      var = meminfo[0].gsub("(", "_").gsub(")", "").underscore
      instance_variable_set("@#{var}", (meminfo[1].to_f * 1024 / MoolMemory::PARSE_TYPES[type]).round(2))
      class_eval{attr_reader var.to_sym}
    end
    @values_in = type
    @mem_used = @mem_total - (@mem_free + @cached + @buffers + @swap_cached )
  end

  def data
    [
      {:name => "#{I18n.t('dashboard.pie.free')} #{free}MB",
       :y => free_p.round, :color => '#00ff00', :sliced => true, :selected => true },
      {:name => "#{I18n.t('dashboard.pie.use')} #{used}MB",
       :y => used_p.round,:color => '#0000ff' }
    ]
  end

  def to_kb; MoolMemory.new("kBytes"); end
  def to_mb; MoolMemory.new("MBytes"); end
  def to_gb; MoolMemory.new("GBytes"); end
end
