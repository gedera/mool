class MoolLoadAverage
  attr_reader :current_loadavg, :last_5min_loadavg, :last_15min_loadavg, :thread_entities_exec, :total_thread_entities, :last_pid_process_created

  def initialize
    result = File.read("/proc/loadavg").chomp.split(" ")
    @current_loadavg       = result[0]
    @last_5min_loadavg     = result[1]
    @last_15min_loadavg    = result[2]
    @thread_entities_exec  = result[3].split("/").first # Currently executing kernel scheduling entities
    @total_thread_entities = result[3].split("/").last # Number of kernel scheduling entities that currently exist on the system
    @last_pid_process_created = result[4]
  end
end
