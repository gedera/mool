module Mool
  class Process < Mool::Base
    attr_accessor :messures, :pattern

    STATUS_PROCESS = {
      'D' => :uninterruptible_sleep,
      'R' => :running,
      'S' => :sleeping,
      'T' => :stopped_by_job_control_signal,
      't' => :stopped_by_debugger_during_trace,
      'Z' => :zombie
    }.freeze

    def initialize(name, pattern, opt = {})
      if name.class != String || pattern.class != String
        raise 'Please only use string types!'
      end

      @messures = []
      @pattern = pattern

      result = opt[:result] ||
               Mool::Process.services_status(
                 [{ name: name,
                    pattern: pattern }]
               )[name]

      result.each do |res|
        # pid, user, pcpu, pmem, rss, priority, args, nice, memory_in_kb,
        # status, cpu_percetage, men_percentage, time
        @messures << {
          name: name,
          pattern: pattern,
          ruser: res[0], # The real user ID of the process.
          user: res[1], # The effective user ID of the process.
          rgroup: res[2], #  The real group ID of the process.
          group: res[3], # The effective group ID of the process.
          pid: res[4], # The decimal value of the process ID.
          ppid: res[5], # The decimal value of the parent process ID.
          pgid: res[6], # The decimal value of the process group ID.
          pcpu: res[7], # The ratio of CPU time used recently to CPU time available in the same period, expressed as a percentage.
          vsz: res[8], # The size of the process in (virtual) memory in 1024 byte units as a decimal integer.
          nice: res[9], # The decimal value of the nice value of the process; see nice.
          etime: res[10], # In the POSIX locale, the elapsed time since the process was started, in the form: [[dd-]hh:]mm:ss
          time: res[11], # In the POSIX locale, the cumulative CPU time of the process in the form:  [dd-]hh:mm:ss
          tty: res[12], # The name of the controlling terminal of the process (if any) in the same format used by the who utility.
          comm: res[13], # The name of the command being executed (argv[0] value) as a string.
          args: res[14], # The command with all its arguments as a string.
          priority: res[15], # Priority: The scheduling priority of the task.
          virt: res[17], # Virtual Memory Size (KiB) The total amount of virtual memory used by the task
          res: res[18], # Resident Memory Size (KiB), A subset of the virtual address space (VIRT)
          shr: res[19], # Shared Memory Size (KiB), A subset of resident memory (RES) that may be used by other processes
          status: Mool::Process::STATUS_PROCESS[res[20]],
          cpu_percentage: res[21], # CPU Usage The task's share of the elapsed CPU
          mem_percentage: res[22], # Memory Usage (RES) A task's currently resident share of available physical memory.
          time_plus: res[22] # CPU Time, hundredths The same as TIME, but reflecting more granularity through hundredths of a second
        }
      end
    end

    def self.all(services)
      raise 'Please only use Array type!' if services.class != Array
      result = {}

      services_data = Mool::Process.services_status(services)

      services.each do |service|
        result[service[:name]] = Mool::Process.new(
          service[:name],
          service[:pattern],
          result: services_data[service[:name]]
        )
      end

      result
    end

    def self.services_status(services)
      command_ps = Mool::Command.ps
      command_top = Mool::Command.top

      result = {}

      services.each do |service|
        ps_parsed = Mool::Process.ps_parser(
          command_ps,
          service[:pattern]
        )

        result[service[:name]] = ps_parsed.collect do |data|
          data + Mool::Process.top_parser(command_top, data[4])
        end
      end

      result
    end

    private

    def self.ps_parser(command, pattern)
      pattern = pattern.gsub('/', '\/')

      results = []

      # ruser,user,rgroup,group,pid,ppid,pgid,pcpu,vsz,nice,etime,time,tty,comm,args
      command.split("\n").each do |comm|
        match = comm.scan(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(#{pattern})\s+(.*)/).flatten
        next if match.empty?
        results << match
      end
      results
    end

    def self.top_parser(command, pid)
      # memory_in_kb, cpu_percetage, men_percentage
      # command.scan(/[\s+]#{pid}\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)\s+.*/)
      results = []
      #          15 16  17  18   19 20  21   22   23    24
      # PID USER PR NI VIRT RES SHR  S %CPU %MEM TIME+ COMMAND
      command.split("\n").each do |comm|
        match = comm.strip.scan(/#{pid}\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/).flatten
        next if match.empty?
        results = match
        break
      end
      results
    end
  end
end
