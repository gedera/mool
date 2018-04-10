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
                  :logical_name,
                  :partitions,
                  :slaves,
                  :unity

    def initialize(devname, path = nil)
      @unity = Mool::BYTES
      @devname = devname

      @path = if path.nil?
                Mool::Disk.proc_partitions_hash(@devname)[:path]
              else
                path
              end

      raise "Does't exist #{devname} on #{@path}" if @path.nil? || @devname.nil?
      lname = Mool::Command.logical_name(@path)
      @logical_name = lname.blank? ? @devname : lname
      read_uevent
      capacity
    end

    def mounting_point
      @mount_point = nil
      Mool::Command.mount.include?(@devname) &&
        @mount_point ||= Mool::Command.mount.scan(
        /#{@devname} (\S+)/
      ).flatten.first
    end

    def file_system
      files = Mool::Command.file_system.select do |a|
        a.include?(@devname)
      end

      files.first.present? &&
        @file_system ||= files.first.split('/')[3]
    end

    def read_uevent
      @major,
      @minor,
      @devname,
      @devtype =
      Mool::Command.uevent(@path).split("\n").map do |result|
        result.split('=').last
      end
    end

    def dev
      @major + @minor
    end

    def disk?
      @devtype == 'disk'
    end

    def partition?
      @devtype == 'partition'
    end

    def swap
      @swap ||= Mool::Command.swap(@devname).present?
    end

    def capacity
      return if defined?(@total_block) && defined?(@block_used) && defined?(@block_free)
      result = Mool::Command.df.scan(
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
      return @cache_partitions if defined? @cache_partitions
      return [] unless disk?

      paths = Mool::Command.partitions(@devname)

      @cache_partitions = paths.map do |path|
        Mool::Disk.new(path.split('/').last, path)
      end
    end

    def slaves
      return @cache_slaves if defined? @cache_slaves

      slaves = Mool::Command.holders(@path)

      @cache_slaves = slaves.map do |slave_devname|
        Mool::Disk.new(slave_devname, @path + "/holders/#{slave_devname}")
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

    def self.swap
      result = Mool::Command.swap.scan(%r{/.*\n\/dev\/(\S+)/}).flatten.first
      Mool::Disk.new(result) unless result.nil?
    end

    def self.find_slaves(path, all_partitions)
      slaves = Mool::Command.holders(path)

      result = {}

      slaves.each do |slave|
        all_partitions.each do |partition|
          devname = partition[3]
          next unless slave.include?(devname)
          all_partitions.delete(partition)
          result[devname] = { path: path + "/holders/#{slave}" }
        end
      end

      result
    end

    def self.find_partitions(disk, all_partitions)
      parts = Mool::Command.partitions(disk)

      result = {}

      parts.each do |part|
        all_partitions.each do |partition|
          devname = partition[3]
          next unless part.include?(devname)
          all_partitions.delete(partition)
          result[devname] = {
            path: part,
            slaves: find_slaves(part, all_partitions)
          }
        end
      end

      result
    end

    def self.find_especific_devname(obj, key)
      if obj.respond_to?(:key?) && obj.key?(key)
        obj[key]
      elsif obj.respond_to?(:each)
        r = nil
        obj.find { |*a| r = find_especific_devname(a.last, key) }
        r
      end
    end

    def self.proc_partitions_hash(especific_devname = nil)
      all_partitions = Mool::Command.all_partitions.scan(/(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/)
      hash_disks = {}

      all_partitions.each do |partition|
        if partition[3].include?('ram') || partition[3].include?('sr')
          all_partitions.delete(partition)
          next
        end
        devname = partition[3]
        path = "/sys/block/#{devname}"
        next unless Mool::Command.root_block_device?(devname)
        all_partitions.delete(partition)
        hash_disks[devname] = {
          path: path,
          partitions: find_partitions(devname, all_partitions),
          slaves: find_slaves(path, all_partitions)
        }
      end

      return hash_disks if especific_devname.nil?
      find_especific_devname(hash_disks, especific_devname)
    end

    def self.all
      disks = []

      proc_partitions_hash.each do |disk_name, disk_opts|
        all_partitions = []
        disk = Mool::Disk.new(disk_name, disk_opts[:path])

        disk_opts[:partitions].map do |partition_name, partition_opts|
          partition = Mool::Disk.new(
            partition_name,
            partition_opts[:path]
          )

          all_partitions << partition

          partition.slaves = partition_opts[:slaves].map do |slave_name, slave_opts|
            Mool::Disk.new(
              slave_name,
              slave_opts[:path]
            )
          end
        end

        disk.partitions = all_partitions

        disk.slaves = disk_opts[:slaves].map do |slave_name, slave_opts|
          Mool::Disk.new(
            slave_name,
            slave_opts[:path]
          )
        end

        disks << disk
      end

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
  end
end
