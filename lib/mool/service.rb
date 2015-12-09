class MoolService
  STATUS_PROCESS = { "D" => I18n.t("process.status.uninterruptible_sleep"),
                     "R" => I18n.t("process.status.running"),
                     "S" => I18n.t("process.status.sleeping"),
                     "T" => I18n.t("process.status.traced_or_stopped"),
                     "Z" => I18n.t("process.status.zombie") }

  attr_reader :messure, :pattern

  def initialize(name, pattern, opt={})
    raise "Please only use string types!" if (name.class != String or pattern.class != String)
    @messure = []
    @pattern = pattern

    result = opt[:result] || MoolService.top_parser(MoolService.top, pattern)

    result.each do |res|
      #pid,user,pcpu,pmem,rss,priority,args,nice, memory_in_kb, status, cpu_percetage, men_percentage, time
      @messure << { :name               => name,
                    :pattern            => pattern,
                    :pid                => res[0],
                    :user               => res[1],
                    :cpu_average        => res[2],
                    :mem_average        => res[3],
                    :resident_set_size  => res[4],
                    :priority           => res[5],
                    :args               => res[6],
                    :nice               => res[7],
                    :memory_in_kb       => res[8],
                    :status             => MoolService::STATUS_PROCESS[res[9]],
                    :cpu_percentage     => res[10],
                    :mem_percentage     => res[11],
                    :time               => res[12]}
    end
  end


  def self.all(services)
    raise "Please only use Array type!" if services.class != Array
    _services = {}

    command_ps = MoolService.ps
    command_top = MoolService.top

    services.each do |service|
      _services[service[:name]] = MoolService.new(service[:name],
                                                  service[:pattern],
                                                  { :result => MoolService.ps_parser(command_ps, service[:pattern]).collect{ |result| result += MoolService.top_parser(command_top, result[0]).flatten } })
    end

    _services
  end

  def self.ps; `ps --no-headers -o pid,user,pcpu,pmem,rss,priority,args -A`; end

  def self.top; `top -c -b -n1`; end

  private

  def self.ps_parser(command, pattern)
    pattern = pattern.gsub('/','\/')
    # pid,user,pcpu,pmem,rss,priority,args
    command.scan(/[\s+](\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(#{pattern})/)
  end

  def self.top_parser(command, pid)
    # nice, memory_in_kb, status, cpu_percetage, men_percentage, time
    # command.scan(/[\s+]#{pid}\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)\s+.*/)
    command.scan(/#{pid}\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+/)
  end

end
