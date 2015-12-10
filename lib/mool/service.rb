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

    result = opt[:result] || MoolService.all([{:name => name, :pattern => pattern}])

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
                    :time               => res[6],
                    :status               => MoolService::STATUS_PROCESS[res[7]],
                    :nice               => res[8],
                    :args               => res[9],
                    :memory_in_kb       => res[10],
                    :cpu_percentage     => res[11],
                    :mem_percentage     => res[12]}
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
                                                  { :result => MoolService.ps_parser(command_ps, service[:pattern]).collect{ |result| result += MoolService.top_parser(command_top, result[0]) } })
    end

    _services
  end

  def self.ps; `ps --no-headers -o pid,user,pcpu,pmem,rss,priority,time,stat,nice,args -A`; end

  def self.top; `top -c -b -n1`; end

  private

  def self.ps_parser(command, pattern)
    pattern = pattern.gsub('/','\/')
    # pid,user,pcpu,pmem,rss,priority,time,stat,nice,args
    command.scan(/[\s+](\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S)\S*\s+(\S+)\s+(#{pattern})/)
  end

  def self.top_parser(command, pid)
    # memory_in_kb, cpu_percetage, men_percentage
    # command.scan(/[\s+]#{pid}\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)\s+.*/)
    result = command.scan(/#{pid}\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s+\S+/).flatten
    result.blank? ? [0, 0, 0.0] : result
  end

end
