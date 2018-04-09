module Mool
  class Disk < Mool::Base
    attr_accessor :path,
                  :major,
                  :minor,
                  :devname,
                  :devtype,
                  :size,
                  :total_size,
                  :percentage_used,
                  :used_size,
                  :free_size,
                  :swap,
                  :mount_point,
                  :file_system,
                  :total_block,
                  :block_used,
                  :block_free,
                  :partitions,
                  :slaves,
                  :unity

    def initialize(dev_name, path = nil)
      @path = if path.nil?
                Mool::Command.dev_block_command.select do |entry|
                  logical_name = Mool::Command.logical_name_command(entry)
                  Mool::Command.dev_name_command(entry).include?(dev_name) ||
                    Mool::Command.uevent_command(entry).include?(dev_name) ||
                    (logical_name.present? && logical_name.include?(dev_name))
                end.first
              else
                path
              end

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
      @mount_point = nil
      Mool::Command.mount_command.include?(@logical_name) &&
        @mount_point ||= Mool::Command.mount_command.scan(
        /#{@logical_name} (\S+)/
      ).flatten.first
    end

    def file_system
      files = Mool::Command.file_system_command.select do |a|
        a.include?(@devname)
      end

      files.first.present? &&
        @file_system ||= files.first.split('/')[3]
    end

    def logical_name
      lname = Mool::Command.logical_name_command(@path)
      @logical_name = lname.present? ? lname : @devname
    end

    def read_uevent
      @major,
      @minor,
      @devname,
      @devtype =
      Mool::Command.uevent_command(@path).split("\n").map do |result|
        result.split('=').last
      end
      # Mool::Command.uevent_command(@path).scan(
      #   /.*=(\d+)\n.*=(\d+)\n.*=(\S+)\n.*=(\w+)\n/
      # ).flatten
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
      @swap ||= Mool::Command.swap_command(@logical_name).present?
    end

    def capacity
      return if defined?(@total_block) && defined?(@block_used) && defined?(@block_free)
      result = Mool::Command.df_command.scan(
        /(#{@logical_name}|#{@devname})\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/
      ).flatten
      # @total_block = Mool::Command.capacity_partition_command(@path).chomp.to_f
      @total_block = result[1].to_f
      @total_size = result[1].to_f * Mool::BLOCK_SIZE
      @block_used  = result[2].to_f
      @block_free  = result[3].to_f
      @used_size = result[2].to_f * Mool::BLOCK_SIZE
      @free_size = result[3].to_f * Mool::BLOCK_SIZE
      return if result.empty?
      @percentage_used = result[4].delete('%')
    end

    def partitions
      return @partitions if defined? @partitions
      return [] unless is_disk?

      @partitions = Mool::Command.partitions_command(
        @path,
        @devname
      ).map do |part|
        Mool::Disk.new(part.split('/').last)
      end
    end

    def slaves
      return @slaves if defined? @slaves

      blocks = Mool::Command.dev_block_command.select do |entry|
        File.directory?("#{entry}/slaves/#{@devname}")
      end

      @slaves = blocks.map do |slave|
        Mool::Disk.new(slave.split('/').last)
      end
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

    def self.all
      disks = []

      Mool::Command.dev_block_command.each do |entry|
        real_path = Mool::Command.real_path_block_command(entry)
        next unless !real_path.include?('virtual') &&
                    !real_path.include?('/sr') &&
                    !Mool::Command.real_path_command_exist?(real_path) &&
                    Mool::Command.slaves_command(real_path).empty?

        disks << Mool::Disk.new(entry.split('/').last, entry)
      end

      disks.each { |disk| disk.partitions.each { |part| part.partitions && part.slaves }}
      disks.each { |disk| disk.slaves.each { |part| part.partitions && part.slaves }}

      disks.each do |disk|
        disk.partitions.each do |partition|
          partition.slaves.each do |slave|
            partition.total_size += slave.total_size
            partition.used_size += slave.used_size
            partition.free_size += slave.free_size
            partition.block_free += slave.block_free
            partition.block_used += slave.block_used
            partition.total_block += slave.total_block
          end
          disk.total_size += partition.total_size
          disk.used_size += partition.used_size
          disk.free_size += partition.free_size
          disk.block_free += partition.block_free
          disk.block_used += partition.block_used
          disk.total_block += partition.total_block
        end
      end

      disks
    end

    def self.swap
      result = Mool::Command.swap_command.scan(%r{/.*\n\/dev\/(\S+)/}).flatten.first
      Mool::Disk.new(result) unless result.nil?
    end

    def self.all_usable
      result = Mool::Disk.all
      result.each do |disk|
        result += (disk.partitions +
                   disk.slaves +
                   (disk.partitions + disk.slaves).collect { |p| p.partitions + p.slaves }.flatten)
      end
      result.reject(&:blank?).select { |d| (d.partitions + d.slaves).blank? }
    end
  end
end
