class MoolDisk
  attr_accessor :path, :major, :minor, :devname, :devtype, :size, :swap, :mount_point, :file_system, :total_block, :block_used, :block_free, :partitions, :slaves, :unity

  def initialize(dev_name)
    paths = MoolDisk.dev_block_command.select do |entry|
      MoolDisk.dev_name_command(entry).include?(dev_name) ||
        MoolDisk.uevent_command(entry).include?(dev_name) ||
        MoolDisk.logical_name_command(entry)
    end

    @path = paths.first

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
    @mount_point ||= MoolDisk.mount_command.scan(/#{@logical_name} (\S+)/).flatten.first if MoolDisk.mount_command.include?(@logical_name)
  end

  def file_system
    @file_system ||= (MoolDisk.file_system_command.select { |a| a.include?(@devname) }.first.split("/")[3] rescue nil)
  end

  def logical_name
    lname = MoolDisk.logical_name_command(@path)
    @logical_name = lname.present? ? lname : @devname
  end

  def read_uevent
    @major, @minor, @devname, @devtype = MoolDisk.uevent_command(@path).scan(/.*=(\d+)\n.*=(\d+)\n.*=(\S+)\n.*=(\w+)\n/).flatten
  end

  def dev
    @major + @minor
  end

  def is_disk?
    @devtype == 'disk'
  end

  def is_partition?
    @devtype == 'partition'
  end

  def swap
    @swap ||= MoolDisk.swap_command(@logical_name).present?
  end

  def capacity
    unless defined?(@total_block) && defined?(@block_used) && defined?(@block_free)
      result = MoolDisk.df_command.scan(/(#{@logical_name}|#{@devname})\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/).flatten
      @total_block = MoolDisk.capacity_partition_command(@path).chomp.to_f * Mool::BLOCK_SIZE
      @block_used  = result[2].to_f * Mool::BLOCK_SIZE
      @block_free  = @total_block - @block_used
    end
  end

  def partitions
    unless defined? @partitions
      @partitions = []
      if is_disk?
        MoolDisk.partitions_command(@path, @devname).each do |part|
          @partitions << MoolDisk.new(part.split('/').last)
        end
      end
    end
    @partitions
  end

  def slaves
    unless defined? @slaves
      @slaves = []
      MoolDisk.dev_block_command.select{ |entry| File.directory?("#{entry}/slaves/#{@devname}") }.each do |slave|
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

  def to_b
    Mool.parse_to(self,
                  ['@total_block',
                   '@block_used',
                   '@block_free'],
                  Mool::BYTES)
  end

  def to_kb
    Mool.parse_to(self,
                  ['@total_block',
                   '@block_used',
                   '@block_free'],
                  Mool::KBYTES)
  end

  def to_mb
    Mool.parse_to(self,
                  ['@total_block',
                   '@block_used',
                   '@block_free'],
                  Mool::MBYTES)
  end

  def to_gb
    Mool.parse_to(self,
                  ['@total_block',
                   '@block_used',
                   '@block_free'],
                  Mool::GBYTES)
  end

  def self.df_command
    `df`
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

  def self.all
    disks = []

    MoolDisk.dev_block_command.each do |entry|
      real_path = MoolDisk.real_path_block_command(entry)
      next unless !real_path.include?('virtual') &&
                  !real_path.include?('/sr') &&
                  !MoolDisk.real_path_command_exist?(real_path) &&
                  MoolDisk.slaves_command(real_path).empty?
      disks << MoolDisk.new(entry.split('/').last)
    end

    disks.each { |disk| disk.partitions.each { |part| part.partitions && part.slaves }}
    disks.each { |disk| disk.slaves.each { |part| part.partitions && part.slaves }}
    disks
  end

  def self.swap
    result = MoolDisk.swap_command.scan(%r{/.*\n\/dev\/(\S+)/}).flatten.first
    MoolDisk.new(result) unless result.nil?
  end

  def self.all_usable
    result = MoolDisk.all
    result.each do |disk|
      result += (disk.partitions +
                 disk.slaves +
                 (disk.partitions + disk.slaves).collect { |p| p.partitions + p.slaves }.flatten)
    end
    result.reject(&:blank?).select { |d| (d.partitions + d.slaves).blank? }
  end
end
