class MoolSystem
  attr_reader :kernel, :current_loadavg, :last_5min_loadavg, :last_15min_loadavg, :thread_entities_exec, :total_thread_entities, :last_pid_process_created, :uptime_day, :uptime_hour, :uptime_minute, :uptime_second

  def initialize
    @kernel = `uname -r`.chomp
    load_avg = File.read("/proc/loadavg").chomp.split(" ")
    @current_loadavg          = load_avg[0].to_f
    @last_5min_loadavg        = load_avg[1].to_f
    @last_15min_loadavg       = load_avg[2].to_f
    @thread_entities_exec     = load_avg[3].split("/").first.to_i # Currently executing kernel scheduling entities
    @total_thread_entities    = load_avg[3].split("/").last.to_i # Number of kernel scheduling entities that currently exist on the system
    @last_pid_process_created = load_avg[4].to_i
    time = `cat /proc/uptime`.split(" ").first.to_f
    mm, ss = time.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    @uptime_day    = dd.to_i
    @uptime_hour   = hh.to_i
    @uptime_minute = mm.to_i
    @uptime_second = ss.to_i
  end

  def load_average
    { :current_loadavg => @current_loadavg,
      :last_5min_loadavg => @last_5min_loadavg,
      :last_15min_loadavg => @last_15min_loadavg,
      :thread_entities_exec => @thread_entities_exec,
      :total_thread_entities => @total_thread_entities,
      :last_pid_process_created => @last_pid_process_created }
  end

  def uptime
    { :day => @uptime_day,
      :hour => @uptime_hour,
      :minute => @uptime_minute,
      :second =>  @uptime_second }
  end

  def kernel_version
    @kernel
  end
end
