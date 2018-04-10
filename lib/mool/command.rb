module Mool
  module Command

    # CPU COMMANDS
    def self.cpuinfo
      File.read('/proc/cpuinfo')
    end

    def self.mpstat
      File.read('|mpstat -P ALL 1 1')
    end

    # DISK COMMANDS
    def self.logical_name(path)
      File.read("#{path}/dm/name") rescue nil
    end

    def self.mount
      File.read('/proc/mounts')
    end

    def self.file_system
      Dir.glob('/sys/fs/**/*')
    end

    def self.uevent(path)
      File.read("#{path}/uevent")
    end

    def self.swap(lname = nil)
      result = File.read('/proc/swaps')
      lname.present? ? result[/#{lname} /] : result
    end

    def self.df
      `POSIXLY_CORRECT=512 df`
    end

    def self.partitions(devname)
      Dir.glob("/sys/block/#{devname}/#{devname}*")
    end

    def self.holders(path)
      Dir.glob("#{path}/holders/*").uniq
    end

    def self.all_partitions
      File.read('/proc/partitions')
    end

    def self.root_block_device?(devname)
      File.exist?("/sys/block/#{devname}") &&
        !Dir.glob("/sys/block/#{devname}/slaves/*").present?
    end

    # def self.capacity_partition_command(path)
    #   File.read("#{path}/size")
    # end

    # MEMORY COMMANDS
    def self.meminfo
      File.read('/proc/meminfo')
    end

    # PROCESS COMMANDS
    def self.ps
      # `ps --no-headers -o pid,user,pcpu,pmem,rss,priority,time,stat,nice,args -A`
      `ps --no-headers -o ruser,user,rgroup,group,pid,ppid,pgid,pcpu,vsz,nice,etime,time,tty,comm,args=HEADER -A`
    end

    def self.top
      `top -c -b -n1`
    end

    # SYSTEM COMMANDS
    def self.uname
      `uname -r`.chomp
    end

    def self.loadavg
      File.read('/proc/loadavg').chomp
    end

    def self.uptime
      `cat /proc/uptime`.chomp
    end
  end
end
