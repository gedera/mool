# Mool
**Mool** aims to be as flexible as possible while helping you with powerful components to get all operative system information, such as **CPU**, **Load-Average**, **Disks**, **Memory**, **Service** and **Process**.

The best thing to have this gem is how get the information. The information is obtained from different source but mainly from files and basic commands such as **"top"**, **"mpstat"** and **"df"**.

Tested on **Alpine**, **Debian** and **Ubuntu**, 

## Installation
Add this line to your application's Gemfile:
```ruby
    gem 'mool'
```
And then execute:
```console
    $ bundle
```
Or install it yourself as:
```console
    $ gem install mool
```

## Package required

- sysstat: `sudo aptitude install sysstat`

## Usage
### CPU
You can check the posible values to use with:
```ruby
    > MoolCpu.processors
    ["0", "1", "2", "4", "all"]
```
It's posible get all cpu information:
```ruby
    > Mool::Cpu.all
    [
      [0] #<Mool::Cpu:0x7f82959381a8
            @nice=0.0,
            @gnice=0.0,
            @total=2.0,
            @irq=0.0,
            @usr=2.0,
            @guest=0.0,
            @iowait=0.0,
            @cores=2,
            @steal=0.0,
            @sys=0.0,
            @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz",
            @idle=97.0,
            @cpu_name="cpu_3",
            @soft=0.0>,
      [1] #<Mool::Cpu:0x7f8295937ca8
            @nice=0.0,
            @gnice=0.0,
            @total=1.0,
            @irq=0.0,
            @usr=1.0,
            @guest=0.0,
            @iowait=0.0,
            @cores=2,
            @steal=0.0,
            @sys=0.0,
            @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz",
            @idle=97.0,
            @cpu_name="cpu_2",
            @soft=0.0>,
      [2] #<Mool::Cpu:0x7f82959377a8
            @nice=0.0,
            @gnice=0.0,
            @total=3.0,
            @irq=0.0,
            @usr=1.0,
            @guest=0.0,
            @iowait=2.0,
            @cores=2,
            @steal=0.0,
            @sys=0.0,
            @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz",
            @idle=96.0,
            @cpu_name="cpu_1",
            @soft=0.0>,
      [3] #<Mool::Cpu:0x7f82959372a8
            @nice=0.0,
            @gnice=0.0,
            @total=4.0,
            @irq=0.0,
            @usr=3.0,
            @guest=0.0,
            @iowait=0.0,
            @cores=2,
            @steal=0.0,
            @sys=1.0,
            @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz",
            @idle=95.0,
            @cpu_name="cpu_0",
            @soft=0.0>,
      [4] #<Mool::Cpu:0x7f8295936da8
            @nice=0.0,
            @gnice=0.0,
            @total=2.0,
            @irq=0.0,
            @usr=2.0,
            @guest=0.0,
            @iowait=0.0,
            @cores=0,
            @steal=0.0,
            @sys=0.0,
            @model_name=nil,
            @idle=96.0,
            @cpu_name="cpu_all",
            @soft=0.0>
]
```
 Or can get a specific cpu information:
```ruby
     >> Mool::Cpu.new(0) # Or you can Mool::Cpu.new("0")
       #<Mool::Cpu:0x7f82959381a8 
         @nice=0.0, 
         @gnice=0.0, 
         @total=2.0, 
         @irq=0.0, 
         @usr=2.0, 
         @guest=0.0, 
         @iowait=0.0, 
         @cores=2, 
         @steal=0.0, 
         @sys=0.0, 
         @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", 
         @idle=97.0, 
         @cpu_name="cpu_3", 
         @soft=0.0>
```
### System information (V. 2.0.0)
Load average:

```ruby
     >>  Mool::System.new.load_average
        { :total_thread_entities => 638,
          :current_loadavg => 0.08,
          :thread_entities_exec => 2,
          :last_15min_loadavg => 0.13,
          :last_pid_process_created => 6264,
          :last_5min_loadavg => 0.07 }
```

uptime:

```ruby
     >>  Mool::System.new.uptime
        { :uptime_day => 4,
          :uptime_hour => 3,
          :uptime_minute => 20,
          :uptime_second => 10 }
```

Kernel version:

```ruby
     >>  Mool::System.new.kernel_version
        "4.6.0-1-amd64"
```


### Memory
```ruby
     >> Mool::Memory.new
        @active=5904642048.0,
        @active_anon=3347439616.0,
        @active_file=2557202432.0,
        @anon_huge_pages=2260729856.0,
        @anon_pages=4628471808.0,
        @bounce=0.0,
        @buffers=314597376.0,
        @cached=3452170240.0,
        @commit_limit=7319011328.0,
        @committed_as=13602762752.0,
        @direct_map2_m=8726249472.0,
        @direct_map4k=4052975616.0,
        @dirty=2002944.0,
        @hardware_corrupted=0.0,
        @huge_pages_free=0.0,
        @huge_pages_rsvd=0.0,
        @huge_pages_surp=0.0,
        @huge_pages_total=0.0,
        @hugepagesize=2097152.0,
        @inactive=2607034368.0,
        @inactive_anon=1485414400.0,
        @inactive_file=1121619968.0,
        @kernel_stack=18612224.0,
        @mapped=1865633792.0,
        @mem_available=5570912256.0,
        @mem_free=1771671552.0,
        @mem_total=12490563584.0,
        @mem_used=6926209024.0,
        @mlocked=143360.0,
        @nfs_unstable=0.0,
        @page_tables=70656000.0,
        @s_reclaimable=448073728.0,
        @s_unreclaim=171155456.0,
        @shmem=444522496.0,
        @shmem_huge_pages=0.0,
        @shmem_pmd_mapped=0.0,
        @slab=619229184.0,
        @swap_cached=25915392.0,
        @swap_free=308559872.0,
        @swap_total=1073729536.0,
        @unevictable=143360.0,
        @unity="Bytes",
        @vmalloc_chunk=0.0,
        @vmalloc_total=35184372087808.0,
        @vmalloc_used=0.0,
        @writeback=0.0,
        @writeback_tmp=0.0>
```
By default the values are in Bytes. So it's posible to changed to different units (Bytes Kbytes, Mbytes, Gbytes).
```ruby
      >> Mool::Memory.new.to_b
      >> Mool::Memory.new.to_kb
      >> Mool::Memory.new.to_mb
      >> Mool::Memory.new.to_gb
```
## Process
To get process information you can provide two params:
1) **name**: This name it's used as key.
2) **pattern**: Used to match with the command top.
```ruby
     >> Mool::Process.new("Slim Process", "slim")
        => #<Mool::Process:0x000055618b982fc8
        @messures=
          [{:name=>"Slim Process",
            :pattern=>"slim",
            :ruser=>"root",
            :user=>"root",
            :rgroup=>"root",
            :group=>"root",
            :pid=>"792",
            :ppid=>"1",
            :pgid=>"792",
            :pcpu=>"0.0",
            :vsz=>"167452",
            :nice=>"0",
            :etime=>"23-06:15:22",
            :time=>"00:00:00",
            :tty=>"?",
            :comm=>"slim",
            :args=>"/usr/bin/slim -nodaemon",
            :priority=>"20",
            :virt=>"167452",
            :res=>"38620",
            :shr=>"7072",
            :status=>:sleeping,
            :cpu_percentage=>"0,0",
            :mem_percentage=>"0,3",
            :time_plus=>"0,3"}],
        @pattern="slim">
```

In this case we have only one messure, but exists especial cases, where the pattern match with more than one process. This cases will have more than one messure, such as:
```ruby
       >> Mool::Process.new("Terminal", "urxvt")
          => #<Mool::Process:0x000055618be9a268
          @messures=
            [{:name=>"URXVT Process",
              :pattern=>"urxvt",
              :ruser=>"gabriel",
              :user=>"gabriel",
              :rgroup=>"gabriel",
              :group=>"gabriel",
              :pid=>"2040",
              :ppid=>"1",
              :pgid=>"2040",
              :pcpu=>"0.0",
              :vsz=>"118676",
              :nice=>"0",
              :etime=>"9-03:04:45",
              :time=>"00:00:55",
              :tty=>"?",
              :comm=>"urxvt",
              :args=>"urxvt",
              :priority=>"20",
              :virt=>"118676",
              :res=>"24280",
              :shr=>"11192",
              :status=>:sleeping,
              :cpu_percentage=>"0,0",
              :mem_percentage=>"0,2",
              :time_plus=>"0,2"},
             {:name=>"URXVT Process",
              :pattern=>"urxvt",
              :ruser=>"gabriel",
              :user=>"gabriel",
              :rgroup=>"gabriel",
              :group=>"utmp",
              :pid=>"2041",
              :ppid=>"2040",
              :pgid=>"2040",
              :pcpu=>"0.0",
              :vsz=>"95560",
              :nice=>"0",
              :etime=>"9-03:04:45",
              :time=>"00:00:00",
              :tty=>"?",
              :comm=>"urxvt",
              :args=>"urxvt",
              :priority=>"20",
              :virt=>"95560",
              :res=>"4160",
              :shr=>"3480",
              :status=>:sleeping,
              :cpu_percentage=>"0,0",
              :mem_percentage=>"0,0",
              :time_plus=>"0,0"}],
          @pattern="urxvt">
```
### Disk
It's possible to get disk, partition or virtual device information using dev name **sda**, **sda1** or virtual device such as or "**md-0**". You can check `cat /proc/partitions`.
```ruby
    >> Mool::Disk.new("sda")
    => #<Mool::Disk:0x000056407745c5a0
       @block_free=0.0,
       @block_used=0.0,
       @devname="sda",
       @devtype="disk",
       @free_size=0.0,
       @logical_name="sda",
       @major="8",
       @minor="0",
       @path="/sys/block/sda",
       @total_block=0.0,
       @total_size=0.0,
       @unity="Bytes",
       @used_size=0.0>
```
It's possible get all partition if the object is `@devtype="disk"`, such as:
```ruby
    >> Mool::Disk.new("sda").partitions
    [
      [0] #<Mool::Disk:0x7fdc6eb3cd18 @logical_name="sda1",
                                      @total_block=262144000.0,
                                      @devtype="partition",
                                      @mount_point="/boot",
                                      @swap=false,
                                      @minor="1",
                                      @devname="sda1",
                                      @block_free=59062784.0,
                                      @path="/sys/block/sda/sda1",
                                      @major="8",
                                      @file_system="ext4",
                                      @unity="Bytes",
                                      @block_used=57123840.0>,
      [1] #<Mool::Disk:0x7fdc6e9e7788 @logical_name="sda2",
                                      @total_block=1073741824.0,
                                      @devtype="partition",
                                      @swap=true,
                                      @minor="2",
                                      @devname="sda2",
                                      @block_free=0.0,
                                      @path="/sys/block/sda/sda2",
                                      @major="8",
                                      @file_system="cgroup",
                                      @unity="Bytes",
                                      @block_used=0.0>,
      [2] #<Mool::Disk:0x7fdc6e8d7f78 @logical_name="sda3",
                                      @total_block=498770927616.0,
                                      @devtype="partition",
                                      @swap=false,
                                      @minor="3",
                                      @devname="sda3",
                                      @block_free=0.0,
                                      @path="/sys/block/sda/sda3",
                                      @major="8",
                                      @file_system=nil,
                                      @unity="Bytes",
                                      @block_used=0.0>
   ]
```
Otherwise it's possible too get the slaves. The slaves are virtual devices for examples `lvm` or `raid`.

```ruby
   >> Mool::Disk.new("sda3").slaves
      [
        [0] #<Mool::Disk:0x7fdc6e6bec00 @logical_name="sdblvm-rootlvm",
                                        @total_block=32212254720.0,
                                        @devtype="disk",
                                        @swap=false,
                                        @minor="0",
                                        @devname="dm-0",
                                        @block_free=9739984896.0,
                                        @path="/sys/block/sda/sda3/holders/dm-0",
                                        @major="252",
                                        @file_system="ext4",
                                        @unity="Bytes",
                                        @block_used=5232629760.0>,
        [1] #<Mool::Disk:0x7fdc6e672350 @logical_name="sdblvm-tmplvm",
                                        @total_block=4294967296.0,
                                        @devtype="disk",
                                        @mount_point="/boot",
                                        @swap=false,
                                        @minor="1",
                                        @devname="dm-1",
                                        @block_free=1926668288.0,
                                        @path="/sys/block/sda/sda3/holders/dm-1",
                                        @major="252",
                                        @file_system="ext4",
                                        @unity="Bytes",
                                        @block_used=4227072.0>,
        [2] #<Mool::Disk:0x7fdc6e627ff8 @logical_name="sdblvm-varlvm",
                                        @total_block=16106127360.0,
                                        @devtype="disk",
                                        @mount_point="/boot",
                                        @swap=false,
                                        @minor="2",
                                        @devname="dm-2",
                                        @block_free=5497151488.0,
                                        @path="/sys/block/sda/sda3/holders/dm-2",
                                        @major="252",
                                        @file_system="ext4",
                                        @unity="Bytes",
                                        @block_used=1951399936.0>,
        [3] #<Mool::Disk:0x7fdc6e5cec78 @logical_name="sdblvm-homelvm",
                                        @total_block=445602856960.0,
                                        @devtype="disk",
                                        @mount_point="/boot",
                                        @swap=false,
                                        @minor="3",
                                        @devname="dm-3",
                                        @block_free=187430152192.0,
                                        @path="/sys/block/sda/sda3/holders/dm-3",
                                        @major="252",
                                        @file_system="btrfs",
                                        @unity="Bytes",
                                        @block_used=34268366848.0>
     ]
```

Other way is get all disk with yours parititons and slaves.

```ruby
    >> Mool::Disk.all
```

Swap partition:

```ruby
    >> Mool::Disk.swap
       #<Mool::Disk:0x7f711644d890 @file_system="cgroup",
                                   @unity="Bytes",
                                   @block_used=0.0,
                                   @logical_name="sda2",
                                   @total_block=1073741824.0,
                                   @minor="2",
                                   @devtype="partition",
                                   @path="/sys/block/sda/sda2",
                                   @swap=true,
                                   @major="8",
                                   @ devname="sda2",
                                   @block_free=1073741824.0>
```

### Version
3.0.0

License
----
MIT

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
