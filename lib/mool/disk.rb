class MoolDisk
  PATH_DEV_BLOCK = Dir.glob('/sys/dev/block/*')

  attr_accessor :path, :major, :minor, :devname, :devtype, :size, :swap, :mount_point, :file_system, :total_block, :block_used, :block_free, :partitions, :slaves, :unity

  def initialize(dev_name)
    @path = PATH_DEV_BLOCK.select{ |entry| ( File.read("#{entry}/dev").include?(dev_name)) ||
                                           ( File.read("#{entry}/uevent").include?(dev_name)) ||
                                           ( File.exist?("#{entry}/dm/name") &&
                                             File.read("#{entry}/dm/name").include?(dev_name)) }.first
    raise "Does't exist #{dev_name}!" if @path.nil?
    read_uevent
    logical_name
    swap
    capacity
    @unity = Mool::BYTES
    mounting_point
    file_system
  end

  def mounting_point
    @mount_point ||= File.read("/proc/mounts").scan(/#{@logical_name} (\S+)/).flatten.first if File.read("/proc/mounts").include?(@logical_name)
  end

  def file_system
    @file_system ||= (Dir.glob("/sys/fs/**/*").select{|a| a.include?(@devname)}.first.split("/")[3] rescue nil)
  end

  def logical_name
    @logical_name ||= File.exists?("#{@path}/dm/name")? File.read("#{@path}/dm/name").chomp : @devname
  end

  def read_uevent
    @major, @minor, @devname, @devtype = File.read("#{@path}/uevent").scan(/.*=(\d+)\n.*=(\d+)\n.*=(\S+)\n.*=(\w+)\n/).flatten
  end

  def dev; @major + @minor; end

  def is_disk?; @devtype == "disk"; end

  def is_partition?; @devtype == "partition"; end

  def swap; @swap ||= File.read("/proc/swaps")[/#{@logical_name} /].present?; end

  def capacity
    unless (defined?(@total_block) && defined?(@block_used) && defined?(@block_free))
      result = `df`.scan(/(#{@logical_name}|#{@devname})\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/).flatten
      @total_block = File.read("#{@path}/size").chomp.to_f * Mool::BLOCK_SIZE
      @block_used  = result[2].to_f * Mool::BLOCK_SIZE
      @block_free  = @total_block - @block_used
    end
  end

  def partitions
    unless defined? @partitions
      @partitions = []
      if is_disk?
        Dir.glob("#{@path}/#{@devname}*").each do |part|
          @partitions << MoolDisk.new(part.split("/").last)
        end
      end
    end
    @partitions
  end

  def slaves
    unless defined? @slaves
      @slaves = []
      PATH_DEV_BLOCK.select{ |entry| File.directory?("#{entry}/slaves/#{@devname}") }.each do |slave|
        @slaves << MoolDisk.new(slave.split("/").last)
      end
    end
    @slaves
  end

  def used_percent
    @block_used / @total_block
  end

  def free_percent
    @block_free / @total_block
  end

  def self.all
    disks = []

    PATH_DEV_BLOCK.each do |entry|
      real_path = `readlink -f #{entry}`.chomp
      disks << MoolDisk.new(entry.split("/").last) if (not real_path.include?("virtual")) &&
                                                      (not real_path.include?("/sr")) &&
                                                      (not File.exist?("#{real_path}/partition")) &&
                                                      Dir.glob("#{real_path}/slaves/*").empty?
    end

    disks.each{ |disk| disk.partitions.each { |part| part.partitions and part.slaves }}
    disks.each{ |disk| disk.slaves.each { |part| part.partitions and part.slaves }}
    disks
  end

  def to_b;  Mool.parse_to(self, ["@total_block", "@block_used", "@block_free"], Mool::BYTES);  end
  def to_kb; Mool.parse_to(self, ["@total_block", "@block_used", "@block_free"], Mool::KBYTES); end
  def to_mb; Mool.parse_to(self, ["@total_block", "@block_used", "@block_free"], Mool::MBYTES); end
  def to_gb; Mool.parse_to(self, ["@total_block", "@block_used", "@block_free"], Mool::GBYTES); end

  def self.swap
    result = File.read("/proc/swaps").scan(/.*\n\/dev\/(\S+)/).flatten.first
    MoolDisk.new(result) unless result.nil?
  end

  def self.all_usable
    result = MoolDisk.all
    result.each do |disk|
      result += (disk.partitions + disk.slaves + (disk.partitions + disk.slaves).collect{|p| p.partitions + p.slaves }.flatten)
    end
    result.reject(&:blank?).select{|d| (d.partitions + d.slaves).blank? }
  end
end
