# Mool
**Mool** aims to be as flexible as possible while helping you with powerful components to get all operative system information, such as **CPU**, **Load-Average**, **Disks**, **Memory**, **Service** and **Process**.

The best thing to have this gem is how get the information. The information is obtained from different source but mainly from files and basic commands such as **"top"**, **"mpstat"** and **"df"**.

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

## Usage
### CPU
You can check the posible values to use with:
```ruby
    > MoolCpu::PROCESSORS
    ["0", "1", "2", "4", "all"]
```
It's posible get all cpu information:
```ruby
    > MoolCpu.all
    [
      [0] #<MoolCpu:0x7f82959381a8 @nice=0.0, @gnice=0.0, @total=2.0, @irq=0.0, @usr=2.0, @guest=0.0, @iowait=0.0, @cores=2, @steal=0.0, @sys=0.0, @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", @idle=97.0, @cpu_name="cpu_3", @soft=0.0>,
      [1] #<MoolCpu:0x7f8295937ca8 @nice=0.0, @gnice=0.0, @total=1.0, @irq=0.0, @usr=1.0, @guest=0.0, @iowait=0.0, @cores=2, @steal=0.0, @sys=0.0, @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", @idle=97.0, @cpu_name="cpu_2", @soft=0.0>,
      [2] #<MoolCpu:0x7f82959377a8 @nice=0.0, @gnice=0.0, @total=3.0, @irq=0.0, @usr=1.0, @guest=0.0, @iowait=2.0, @cores=2, @steal=0.0, @sys=0.0, @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", @idle=96.0, @cpu_name="cpu_1", @soft=0.0>,
      [3] #<MoolCpu:0x7f82959372a8 @nice=0.0, @gnice=0.0, @total=4.0, @irq=0.0, @usr=3.0, @guest=0.0, @iowait=0.0, @cores=2, @steal=0.0, @sys=1.0, @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", @idle=95.0, @cpu_name="cpu_0", @soft=0.0>,
      [4] #<MoolCpu:0x7f8295936da8 @nice=0.0, @gnice=0.0, @total=2.0, @irq=0.0, @usr=2.0, @guest=0.0, @iowait=0.0, @cores=0, @steal=0.0, @sys=0.0, @model_name=nil, @idle=96.0, @cpu_name="cpu_all", @soft=0.0>
]
```
 Or can get a specific cpu information:
   ```ruby
     >> MoolCpu.new(0) or MoolCpu.new("0")
       #<MoolCpu:0x7f82959381a8 @nice=0.0, @gnice=0.0, @total=2.0, @irq=0.0, @usr=2.0, @guest=0.0, @iowait=0.0, @cores=2, @steal=0.0, @sys=0.0, @model_name="Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz", @idle=97.0, @cpu_name="cpu_3", @soft=0.0>
   ```
### Load-Average
```ruby
     >>  MoolLoadAverage.new
        #<MoolLoadAverage:0x7f8295931c90 @total_thread_entities=638, @current_loadavg=0.08, @thread_entities_exec=2, @last_15min_loadavg=0.13, @last_pid_process_created=6264, @last_5min_loadavg=0.07>
```
### Memory
```ruby
     >> MoolMemory.new
       --- !ruby/object:MoolMemory
       active: 2906775552.0
       active_anon: 2175971328.0
       active_file: 730804224.0
       anon_huge_pages: 0.0
       anon_pages: 2174132224.0
       bounce: 0.0
       buffers: 73887744.0
       cached: 1795256320.0
       commit_limit: 7322968064.0
       committed_as: 8012181504.0
       direct_map2_m: 12499025920.0
       direct_map4k: 280199168.0
       dirty: 217088.0
       hardware_corrupted: 0.0
       huge_pages_free: 0.0
       huge_pages_rsvd: 0.0
       huge_pages_surp: 0.0
       huge_pages_total: 0.0
       hugepagesize: 2097152.0
       inactive: 1136472064.0
       inactive_anon: 573755392.0
       inactive_file: 562716672.0
       kernel_stack: 10485760.0
       mapped: 692449280.0
       mem_available: 9536376832.0
       mem_free: 8219561984.0
       mem_total: 12498477056.0
       mem_used: 2409771008.0
       mlocked: 4096.0
       nfs_unstable: 0.0
       page_tables: 47812608.0
       s_reclaimable: 76697600.0
       s_unreclaim: 34598912.0
       shmem: 575635456.0
       slab: 111296512.0
       swap_cached: 0.0
       swap_free: 1073729536.0
       swap_total: 1073729536.0
       unevictable: 4096.0
       unity: Bytes
       vmalloc_chunk: 35183562584064.0
       vmalloc_total: 35184372087808.0
       vmalloc_used: 381046784.0
       writeback: 0.0
       writeback_tmp: 0.0
```
By default the values are in Bytes. So it's posible to changed to different units (Bytes Kbytes, Mbytes, Gbytes).
```ruby
      >> MoolMemory.new.to_b
      >> MoolMemory.new.to_kb
      >> MoolMemory.new.to_mb
      >> MoolMemory.new.to_gb
```
## Service or Process
To get process information you can provide two params:
1) **name**: This name it's used as key.
2) **pattern**: Used to match with the command top.
```ruby
     >> MoolService.new("profanity Process", "profanity")
        #<MoolService:0x7f4c23f929e8 @messure=[{ :status=>"Sleeping",
                                                 :command=>"profanity",
                                                 :time=>"0:08.22",
                                                 :pattern=>"profanity",
                                                 :nice=>"0",
                                                 :pid=>"1764",
                                                 :memory_in_kb=>"34376",
                                                 :user=>"mool",
                                                 :cpu_percentage=>"0,0",
                                                 :name=>"profanity Process",
                                                 :mem_percentage=>"0,3",
                                                 :priority=>"20" }]>
```

In this case we have only one messure, but exists especial cases, where the pattern match with more than one process. This cases will have more than one messure, such as:
```ruby
       >> MoolService.new("Terminal", "urxvt")
          #<MoolService:0x7f4c23f88f88 @messure=[ { :status=>"Sleeping",
                                                    :command=>"urxvt",
                                                    :time=>"0:02.80",
                                                    :pattern=>"urxvt",
                                                    :nice=>"0",
                                                    :pid=>"1672",
                                                    :memory_in_kb=>"16152",
                                                    :user=>"mool",
                                                    :cpu_percentage=>"0,0",
                                                    :name=>"Terminal",
                                                    :mem_percentage=>"0,1",
                                                    :priority=>"20" },
                                                  { :status=>"Sleeping",
                                                    :command=>"urxvt",
                                                    :time=>"0:00.00",
                                                    :pattern=>"urxvt",
                                                    :nice=>"0",
                                                    :pid=>"1673",
                                                    :memory_in_kb=>"4020",
                                                    :user=>"mool",
                                                    :cpu_percentage=>"0,0",
                                                    :name=>"Terminal",
                                                    :mem_percentage=>"0,0",
                                                    :priority=>"20" } ]>
```
### Disk
It's possible to get disk, partition or virtual device information using dev name **MAJOR:MINOR** ("**8:2**"), device name **sda**, **sda1** or virtual device such as "**lvm-sda2**" or "**md0**".
```ruby
    >> MoolDisk.new("8:0")
       #<MoolDisk:0x7fdc6e283f00 @logical_name="sda", @total_block=500107862016.0, @devtype="disk", @mount_point="/boot", @swap=false, @minor="0", @devname="sda", @block_free=0.0, @path="/sys/dev/block/8:0", @major="8", @file_system="ext4", @unity="Bytes", @block_used=0.0>
    >> MoolDisk.new("sda1")
       #<MoolDisk:0x7fdc6e266a40 @logical_name="sda1", @total_block=262144000.0, @devtype="partition", @mount_point="/boot", @swap=false, @minor="1", @devname="sda1", @block_free=59062784.0, @path="/sys/dev/block/8:1", @major="8", @file_system="ext4", @unity="Bytes", @block_used=57123840.0>
    >> MoolDisk.new("sdblvm-homelvm")
       #<MoolDisk:0x7fdc6e248658 @logical_name="sdblvm-homelvm", @total_block=445602856960.0, @devtype="disk", @mount_point="/boot", @swap=false, @minor="3", @devname="dm-3", @block_free=187429210112.0, @path="/sys/dev/block/252:3", @major="252", @file_system="btrfs", @unity="Bytes", @block_used=34269296640.0>
```
It's possible get all partition if the object is `@devtype="disk"`, such as:
```ruby
    >> MoolDisk.new("sda").partitions
    [
      [0] #<MoolDisk:0x7fdc6eb3cd18 @logical_name="sda1", @total_block=262144000.0, @devtype="partition", @mount_point="/boot", @swap=false, @minor="1", @devname="sda1", @block_free=59062784.0, @path="/sys/dev/block/8:1", @major="8", @file_system="ext4", @unity="Bytes", @block_used=57123840.0>,
      [1] #<MoolDisk:0x7fdc6e9e7788 @logical_name="sda2", @total_block=1073741824.0, @devtype="partition", @swap=true, @minor="2", @devname="sda2", @block_free=0.0, @path="/sys/dev/block/8:2", @major="8", @file_system="cgroup", @unity="Bytes", @block_used=0.0>,
      [2] #<MoolDisk:0x7fdc6e8d7f78 @logical_name="sda3", @total_block=498770927616.0, @devtype="partition", @swap=false, @minor="3", @devname="sda3", @block_free=0.0, @path="/sys/dev/block/8:3", @major="8", @file_system=nil, @unity="Bytes", @block_used=0.0>
   ]
```
Otherwise it's possible too get the slaves. The slaves are virtual devices for examples `lvm` or `raid`.

```ruby
   >> MoolDisk.new("sda3").slaves
      [
        [0] #<MoolDisk:0x7fdc6e6bec00 @logical_name="sdblvm-rootlvm", @total_block=32212254720.0, @devtype="disk", @swap=false, @minor="0", @devname="dm-0", @block_free=9739984896.0, @path="/sys/dev/block/252:0", @major="252", @file_system="ext4", @unity="Bytes", @block_used=5232629760.0>,
        [1] #<MoolDisk:0x7fdc6e672350 @logical_name="sdblvm-tmplvm", @total_block=4294967296.0, @devtype="disk", @mount_point="/boot", @swap=false, @minor="1", @devname="dm-1", @block_free=1926668288.0, @path="/sys/dev/block/252:1", @major="252", @file_system="ext4", @unity="Bytes", @block_used=4227072.0>,
        [2] #<MoolDisk:0x7fdc6e627ff8 @logical_name="sdblvm-varlvm", @total_block=16106127360.0, @devtype="disk", @mount_point="/boot", @swap=false, @minor="2", @devname="dm-2", @block_free=5497151488.0, @path="/sys/dev/block/252:2", @major="252", @file_system="ext4", @unity="Bytes", @block_used=1951399936.0>,
        [3] #<MoolDisk:0x7fdc6e5cec78 @logical_name="sdblvm-homelvm", @total_block=445602856960.0, @devtype="disk", @mount_point="/boot", @swap=false, @minor="3", @devname="dm-3", @block_free=187430152192.0, @path="/sys/dev/block/252:3", @major="252", @file_system="btrfs", @unity="Bytes", @block_used=34268366848.0>
     ]
```

Other way is get all disk with yours parititons and slaves.
```ruby
    >> MoolDisk.all
       - !ruby/object:MoolDisk
         block_free: 0.0
         block_used: 0.0
         devname: sda
         evtype: disk
         file_system: ext4
         logical_name: sda
         major: "8"
         minor: "0"
         mount_point: /boot
         swap: false
         total_block: 500107862016.0
         unity: Bytes
         partitions:
         - !ruby/object:MoolDisk
           block_free: 59062784.0
           block_used: 57123840.0
           devname: sda1
           devtype: partition
           file_system: ext4
           logical_name: sda1
           major: "8"
           minor: "1"
           mount_point: /boot
           partitions: []
           path: /sys/dev/block/8:1
           slaves: []
           swap: false
           total_block: 262144000.0
           unity: Bytes
         - !ruby/object:MoolDisk
           block_free: 0.0
           block_used: 0.0
           devname: sda2
           devtype: partition
           file_system: cgroup
           logical_name: sda2
           major: "8"
           minor: "2"
           partitions: []
           path: /sys/dev/block/8:2
           slaves: []
           swap: true
           total_block: 1073741824.0
           unity: Bytes
         - !ruby/object:MoolDisk
           block_free:	0.0
           block_used:	0.0
           devname: sda3
           devtype: partition
           file_system:
           logical_name: sda3
           major: "8"
           minor: "3"
           partitions: []
           path: /sys/dev/block/8:3
           slaves:
           - !ruby/object:MoolDisk
             block_free: 9739984896.0
             block_used: 5232629760.0
             devname: dm-0
             devtype: disk
             file_system: ext4
             logical_name: sdblvm-rootlvm
             major: "252"
             minor: "0"
             path: /sys/dev/block/252:0
             swap: false
             total_block: 32212254720.0
             unity: Bytes
           - !ruby/object:MoolDisk
             block_free: 1926668288.0
             block_used: 4227072.0
             devname: dm-1
             devtype: disk
             file_system: ext4
             logical_name: sdblvm-tmplvm
             major: "252"
             minor: "1"
             mount_point: /boot
             path: /sys/dev/block/252:1
             swap: false
             total_block: 4294967296.0
             unity: Bytes
           - !ruby/object:MoolDisk
             block_free: 5497149440.0
             block_used: 1951401984.0
             devname: dm-2
             devtype: disk
             file_system: ext4
             logical_name: sdblvm-varlvm
             major: "252"
             minor: "2"
             mount_point: /boot
             path: /sys/dev/block/252:2
             swap: false
             total_block: 16106127360.0
             unity: Bytes
           - !ruby/object:MoolDisk
             block_free: 187430135808.0
             block_used: 34268346368.0
             devname: dm-3
             devtype: disk
             file_system: btrfs
             logical_name: sdblvm-homelvm
             major: "252"
             minor: "3"
             mount_point: /boot
             path: /sys/dev/block/252:3
             swap: false
             total_block: 445602856960.0
             unity: Bytes
             swap: false
             total_block: 498770927616.0
             unity: Bytes
             path: /sys/dev/block/8:0
             slaves: []
```

### Version
0.0.1

License
----
MIT

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
