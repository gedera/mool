class MoolService
  STATUS_PROCESS = {
    'D' => I18n.t('process.status.uninterruptible_sleep'),
    'R' => I18n.t('process.status.running'),
    'S' => I18n.t('process.status.sleeping'),
    'T' => I18n.t('process.status.traced_or_stopped'),
    'Z' => I18n.t('process.status.zombie')
  }.freeze

  attr_reader :messure, :pattern

  def initialize(name, pattern, opt = {})
    if name.class != String || pattern.class != String
      raise 'Please only use string types!'
    end

    @messure = []
    @pattern = pattern

    result = opt[:result] ||
             MoolService.services_status(
               [{ name: name,
                  pattern: pattern }]
             )[name]

    result.each do |res|
      # pid, user, pcpu, pmem, rss, priority, args, nice, memory_in_kb,
      # status, cpu_percetage, men_percentage, time
      @messure << {
        name: name,
        pattern: pattern,
        pid: res[0],
        user: res[1],
        cpu_average: res[2],
        mem_average: res[3],
        resident_set_size: res[4],
        priority: res[5],
        time: res[6],
        status: MoolService::STATUS_PROCESS[res[7]],
        nice: res[8],
        args: res[9],
        memory_in_kb: res[10],
        cpu_instant: (res[11] || 0),
        mem_instant: (res[12] || 0.0)
      }
    end
  end

  def self.all(services)
    raise 'Please only use Array type!' if services.class != Array
    result = {}

    services_data = MoolService.services_status(services)

    services.each do |service|
      result[service[:name]] = MoolService.new(
        service[:name],
        service[:pattern],
        result: services_data[service[:name]]
      )
    end

    result
  end

  def self.services_status services
    command_ps = MoolService.ps_command
    command_top = MoolService.top_command
    result = {}
    services.each do |service|
      ps_parsed = MoolService.ps_parser(
        command_ps,
        service[:pattern]
      )
      result[service[:name]] = ps_parsed.collect do |data|
        data + MoolService.top_parser(command_top, data[0])
      end
    end
    result
  end

  def self.ps_command
    `ps --no-headers -o pid,user,pcpu,pmem,rss,priority,time,stat,nice,args -A`
  end

  def self.top_command
    `top -c -b -n1`
  end

  private

  def self.ps_parser(command, pattern)
    pattern = pattern.gsub('/', '\/')
    # pid,user,pcpu,pmem,rss,priority,time,stat,nice,args
    command.scan(/^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S)\S*\s+(\S+)\s+.*(#{pattern}).*\n/)
  end

  def self.top_parser(command, pid)
    # memory_in_kb, cpu_percetage, men_percentage
    # command.scan(/[\s+]#{pid}\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)\s+.*/)
    result = command.scan(/#{pid}\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s+\S+/).flatten
  end

end
