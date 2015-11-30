class MoolCpu
  PAHT_PROC_CPUINFO = "/proc/cpuinfo"

  attr_reader :cpu_name, :model_name, :cores, :usr, :nice, :sys, :iowait, :irq, :soft, :steal, :guest, :gnice, :idle, :total

  # ["all", "1", "2"]
  def initialize(process_number, opt={})
    raise "Cpu name incorrect!. Posible values: #{MoolCpu.processors.join(",")}" unless MoolCpu.processors.include?(process_number.to_s)
    result = opt.empty? ? MoolCpu.cpu_info[process_number.to_s] : opt
    @cpu_name = "cpu_#{process_number.to_s}"
    @model_name = result["model_name"]
    @cores      = result["cpu_cores"].to_i
    @usr        = result["%usr"].to_f
    @nice       = result["%nice"].to_f
    @sys        = result["%sys"].to_f # This is kernel %
    @iowait     = result["%iowait"].to_f
    @irq        = result["%irq"].to_f
    @soft       = result["%soft"].to_f
    @steal      = result["%steal"].to_f
    @guest      = result["%guest"].to_f
    @gnice      = result["%gnice"].to_f
    @idle       = result["%idle"].to_f
    @total      = @usr + @nice + @sys + @iowait + @irq + @soft + @steal + @guest
  end

  def self.cpu_info
    cpu_info = {}

    mpstat = File.read("|mpstat -P ALL 1 1").split("\n\n")[1].split("\n").map{|i| i.gsub(/\d+:\d+:\d+/, '').strip.split(/\s+/) }
    mpstat_vars = mpstat.shift
    mpstat_vars.shift
    mpstat.each do |data|
      res = {}
      core_name = data.shift
      data.each_with_index { |d, i| res.merge!(mpstat_vars[i] => d) }
      cpu_info.merge!(core_name => res)
    end

    File.read(PATH_PROC_CPUINFO).gsub(/([^\n])\n([^\n])/, '\1 \2').scan(/processor\t*: (\d+).*model name\t*: (.*) stepping.*cpu cores\t*: (\d+)/).each do |v|
      cpu_info[v[0]]["model_name"] = v[1]
      cpu_info[v[0]]["cpu_cores"] = v[2]
    end

    cpu_info
  end

  def self.processors
    File.read(PATH_PROC_CPUINFO).scan(/processor\t*: (\d+)/).flatten + ["all"]
  end


  def self.all
    MoolCpu.cpu_info.map{ |key, value| MoolCpu.new(key, value) }
  end
end
