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

    top_result = opt[:top_result] || MoolService.top_parser(MoolService.top, pattern)

    top_result.each do |result|
      @messure << { :name           => name,
                    :pattern        => pattern,
                    :pid            => result[0],
                    :user           => result[1],
                    :priority       => result[2],
                    :nice           => result[3],
                    :memory_in_kb   => result[4],
                    :status         => STATUS_PROCESS[result[5]],
                    :cpu_percentage => result[6],
                    :mem_percentage => result[7],
                    :time           => result[8],
                    :command        => result[9] }
    end
  end

  def self.all(services)
    raise "Please only use Array type!" if services.class != Array
    _services = {}
    command_top = MoolService.top
    services.each do |service|
      _services[service[:name]] = MoolService.new(service[:name], service[:pattern], { :top_result => top_parser(command_top, service[:pattern])})
    end
    _services
  end

  private

  def self.top; `top -c -b -n1`; end

  def self.top_parser(command, pattern)
    pattern = pattern.gsub('/','\/')
    command.scan(/[\s+](\d+)\s+(\S+)\s+(\d+)\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)\s+.*(#{pattern}).*/)
  end

end
