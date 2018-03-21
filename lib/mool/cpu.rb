module Mool
  class Cpu
    attr_reader :cpu_name,
                :model_name,
                :cores,
                :usr,
                :nice,
                :sys,
                :iowait,
                :irq,
                :soft,
                :steal,
                :guest,
                :gnice,
                :idle,
                :total

    # ["all", "1", "2"]
    def initialize(process_number, opt={})
      result = Mool::Cpu.processors

      unless result.include?(process_number.to_s)
        raise "Cpu name incorrect!. Posible values: #{result.join(', ')}"
      end
      result = opt.empty? ? Mool::Cpu.cpuinfo[process_number.to_s] : opt
      @cpu_name = "cpu_#{process_number}"
      @model_name = result['model_name']
      @cores      = result['cpu_cores'].to_i
      @usr        = result['%usr'].to_f
      @nice       = result['%nice'].to_f
      @sys        = result['%sys'].to_f # This is kernel %
      @iowait     = result['%iowait'].to_f
      @irq        = result['%irq'].to_f
      @soft       = result['%soft'].to_f
      @steal      = result['%steal'].to_f
      @guest      = result['%guest'].to_f
      @gnice      = result['%gnice'].to_f
      @idle       = result['%idle'].to_f
      @total      = [@usr,
                     @nice,
                     @sys,
                     @iowait,
                     @irq,
                     @soft,
                     @steal,
                     @guest].sum
    end

    def self.cpuinfo_command
      File.read('/proc/cpuinfo')
    end

    def self.mpstat_command
      File.read('|mpstat -P ALL 1 1')
    end

    def self.cpuinfo
      cpu_info = {}

      mpstat = mpstat_command.split("\n\n")[2].split("\n").map do |i|
        i.gsub(/^\S+:/, '').strip.split(/\s+/)
      end

      mpstat_vars = mpstat.shift
      mpstat_vars.shift

      mpstat.each do |data|
        res = {}
        core_name = data.shift
        data.each_with_index { |d, i| res.merge!(mpstat_vars[i] => d) }
        cpu_info.merge!(core_name => res)
      end

      cpuinfo_command.gsub(/([^\n])\n([^\n])/,
                           '\1 \2').scan(/processor\t*: (\d+).*model name\t*: (.*) stepping.*cpu cores\t*: (\d+)/).each do |v|
        cpu_info[v[0]]['model_name'] = v[1]
        cpu_info[v[0]]['cpu_cores'] = v[2]
      end

      cpu_info
    end

    def self.processors
      cpuinfo_command.scan(/processor\t*: (\d+)/).flatten + ['all']
    end

    def self.all
      Mool::Cpu.cpuinfo.map { |key, value| Mool::Cpu.new(key, value) }
    end
  end
end
