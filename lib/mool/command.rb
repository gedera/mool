module Mool
  module Command

    def self.cpuinfo_command
      File.read('/proc/cpuinfo')
    end

    def self.mpstat_command
      File.read('|mpstat -P ALL 1 1')
    end

    def self.df_command
      `df`
    end

    def self.dev_name_command(dev_entry)
      File.read("#{dev_entry}/dev")
    end

    def self.mount_command
      File.read('/proc/mounts')
    end

    def self.file_system_command
      Dir.glob('/sys/fs/**/*')
    end

    def self.logical_name_command(path)
      File.exist?("#{path}/dm/name") ? File.read("#{path}/dm/name").chomp : nil
    end

    def self.uevent_command(path)
      File.read("#{path}/uevent")
    end

    def self.swap_command(lname = nil)
      result = File.read('/proc/swaps')
      lname.present? ? result[/#{lname} /] : result
    end

    def self.capacity_partition_command(path)
      File.read("#{path}/size")
    end

    def self.partitions_command(path, devname)
      Dir.glob("#{path}/#{devname}*")
    end

    def self.dev_block_command
      Dir.glob('/sys/dev/block/*')
    end

    def self.real_path_block_command(entry)
      `readlink -f #{entry}`.chomp
    end

    def self.real_path_command_exist?(real_path)
      File.exist?("#{real_path}/partition")
    end

    def self.slaves_command(real_path)
      Dir.glob("#{real_path}/slaves/*")
    end

    def self.meminfo_command
      File.read('/proc/meminfo')
    end

    def self.ps_command
      # `ps --no-headers -o pid,user,pcpu,pmem,rss,priority,time,stat,nice,args -A`
      `ps --no-headers -o ruser,user,rgroup,group,pid,ppid,pgid,pcpu,vsz,nice,etime,time,tty,comm,args=HEADER -A`
    end

    def self.top_command
      `top -c -b -n1`
    end

    def self.uname_command
      `uname -r`.chomp
    end

    def self.uptime_command
      `cat /proc/uptime`.chomp
    end

    def self.loadavg_command
      File.read('/proc/loadavg').chomp
    end
  end
end
