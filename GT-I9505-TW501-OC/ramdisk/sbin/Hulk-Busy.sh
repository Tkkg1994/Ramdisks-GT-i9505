#!/sbin/busybox sh

BB=/sbin/busybox

# protect init from oom
# echo "-1000" > /proc/1/oom_score_adj;
# 
# PIDOFINIT=$(pgrep -f "/sbin/ext/googymax3.sh");
# for i in $PIDOFINIT; do
# 	echo "-600" > /proc/"$i"/oom_score_adj;
# done;

OPEN_RW()
{
        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;
}
OPEN_RW;

# $BB rm /dev/random;
## $BB mknod -m 666 /dev/random c 1 9;
## $BB chown root:root /dev/random;
# $BB rm /dev/random /dev/urandom
# $BB mknod -m 644 /dev/urandom c 235 12
# $BB mknod -m 644 /dev/random c 235 11
# $BB echo 0 > /proc/sys/kernel/random/write_wakeup_threshold 
# $BB echo 1366 > /proc/sys/kernel/random/read_wakeup_threshold

# Boot with CFQ I/O Gov
$BB echo "cfq" > /sys/block/mmcblk0/queue/scheduler;

# create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/
	$BB chmod 755 /system/etc/init.d/;
fi;

	if [ ! -d /data/init.d_bkp ]; then
		$BB mkdir /data/init.d_bkp;
	fi;
	$BB mv /system/etc/init.d/* /data/init.d_bkp/;

	# run ROM scripts
	if [ -e /system/etc/init.qcom.post_boot.sh ]; then
		 /system/bin/sh /system/etc/init.qcom.post_boot.sh
	else
		$BB echo "No ROM Boot script detected"
	fi;

	$BB mv /data/init.d_bkp/* /system/etc/init.d/

sleep 5;
OPEN_RW;

# some nice thing for dev
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
	$BB ln -s /sys/module/msm_thermal/parameters/ /cputemp;
	$BB ln -s /sys/kernel/intelli_plug/ /hotplugs/intelli;
	$BB ln -s /sys/module/msm_mpdecision/ /hotplugs/msm_mpdecision;
	$BB ln -s /sys/devices/system/cpu/cpufreq/all_cpus/ /all_cpus;
fi;

# cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R system:system /data/anr;
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 06755 /sbin/ext/;
	$BB chmod -R 0777 /data/anr/;
	$BB chmod -R 0400 /data/tombstones;
	$BB chmod 06755 /sbin/busybox;
}
CRITICAL_PERM_FIX;

# oom and mem perm fix
$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree

# make sure we own the device nodes
$BB chown system /sys/devices/system/cpu/cpu0/cpufreq/*
$BB chown system /sys/devices/system/cpu/cpu1/online
$BB chown system /sys/devices/system/cpu/cpu2/online
$BB chown system /sys/devices/system/cpu/cpu3/online
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
$BB chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
$BB chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/stats/*
$BB chmod 666 /sys/devices/system/cpu/cpu1/online
$BB chmod 666 /sys/devices/system/cpu/cpu2/online
$BB chmod 666 /sys/devices/system/cpu/cpu3/online
$BB chmod 666 /sys/module/msm_thermal/parameters/*
$BB chmod 666 /sys/module/msm_thermal/core_control/enabled
$BB chmod 666 /sys/class/kgsl/kgsl-3d0/max_gpuclk
$BB chmod 666 /sys/devices/platform/kgsl-3d0/kgsl/kgsl-3d0/pwrscale/trustzone/governor
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree

$BB chown -R root:root /data/property;
$BB chmod -R 0700 /data/property

# set ondemand GPU governor as default
echo "ondemand" > /sys/devices/platform/kgsl-3d0/kgsl/kgsl-3d0/pwrscale/trustzone/governor

# make sure our max gpu clock is set via sysfs
echo 450000000 > /sys/class/kgsl/kgsl-3d0/max_gpuclk

# set min max boot freq to default.
echo "1890000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo "1890000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq;
echo "1890000" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq;
echo "1890000" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq;
echo "384000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
echo "384000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq;
echo "384000" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq;
echo "384000" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq;
 
# Fix ROM dev wrong sets.
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop pm.sleep_mode 1
setprop wifi.supplicant_scan_interval 180

if [ ! -d /data/.googymax3 ]; then
	$BB mkdir -p /data/.googymax3;
fi;

$BB chmod -R 0777 /data/.googymax3/;

$BB rm -f /data/.googymax3/vdd_levels.ggy;
$BB cat /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels > /data/.googymax3/vdd_levels.ggy

$BB rm -f /data/.googymax3/GPU_mV_table.ggy;
$BB cat /sys/devices/system/cpu/cpu0/cpufreq/GPU_mV_table > /data/.googymax3/GPU_mV_table.ggy

. /res/customconfig/customconfig-helper;

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.googymax3/.ccxmlsum`" ];
then
   $BB rm -f /data/.googymax3/*.profile;
   echo ${ccxmlsum} > /data/.googymax3/.ccxmlsum;
fi;

[ ! -f /data/.googymax3/default.profile ] && cp /res/customconfig/default.profile /data/.googymax3/default.profile;
[ ! -f /data/.googymax3/battery.profile ] && cp /res/customconfig/battery.profile /data/.googymax3/battery.profile;
[ ! -f /data/.googymax3/balanced.profile ] && cp /res/customconfig/balanced.profile /data/.googymax3/balanced.profile;
[ ! -f /data/.googymax3/performance.profile ] && cp /res/customconfig/performance.profile /data/.googymax3/performance.profile;

read_defaults;
read_config;

# zram
if [ "$sammyzram" == "on" ];then
 if [ -f /system/bin/rtccd3 ]; then
  UNIT="M"
  /system/bin/rtccd3 -a "$zramdisksize$UNIT"
  echo "1" > /data/.googymax3/zram.ggy
 else
 if [ -f /system/bin/rtccd2 ]; then
  UNIT="M"
  /system/bin/rtccd2 -a "$zramdisksize$UNIT"
  echo "3" > /data/.googymax3/zram.ggy
 else
  echo 1 > /sys/devices/virtual/block/zram0/reset
  swapoff /dev/block/zram0
  echo `expr $zramdisksize \* 1024 \* 1024` > /sys/devices/virtual/block/zram0/disksize
  echo `expr $swappiness \* 1` > /proc/sys/vm/swappiness
  mkswap /dev/block/zram0
  swapon /dev/block/zram0
  echo "2" > /data/.googymax3/zram.ggy
 fi;
 fi;
else
echo "0" > /data/.googymax3/zram.ggy
fi;

if [ "$hotplug" == "1" ];then
        stop mpdecision
	mv /system/bin/mpdecision /system/bin/mpdecision.googy
        echo "1" > /sys/module/intelli_plug/parameters/intelli_plug_active
else
        echo "0" > /sys/module/intelli_plug/parameters/intelli_plug_active
	mv /system/bin/mpdecision.googy /system/bin/mpdecision
	start mpdecision
fi;

# cpu
if [ "$hotplug" == "0" ];then
   stop mpdecision
else
   echo "0" > /sys/module/intelli_plug/parameters/intelli_plug_active
fi;
    echo "N" > /sys/module/msm_thermal/parameters/enabled
    echo "1" > /sys/devices/system/cpu/cpu0/online
    echo "1" > /sys/devices/system/cpu/cpu1/online
    echo "1" > /sys/devices/system/cpu/cpu2/online
    echo "1" > /sys/devices/system/cpu/cpu3/online
    echo "$cpu_governor" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
    echo "$cpu_governor" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
    echo "$cpu_governor" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
    echo "$cpu_governor" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
    echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
    echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq;
    echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq;
    echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq;
    echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
    echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq;
    echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq;
    echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq;
    echo "Y" > /sys/module/msm_thermal/parameters/enabled
if [ "$hotplug" == "0" ];then
   start mpdecision
else
   echo "1" > /sys/module/intelli_plug/parameters/intelli_plug_active
fi;

if [ "$logger_mode" == "on" ]; then
	echo "1" > /sys/kernel/logger_mode/logger_mode;
else
	echo "0" > /sys/kernel/logger_mode/logger_mode;
fi;

# scheduler
echo "$int_scheduler" > /sys/block/mmcblk0/queue/scheduler;
echo "$int_read_ahead_kb" > /sys/block/mmcblk0/bdi/read_ahead_kb;
echo "$ext_scheduler" > /sys/block/mmcblk1/queue/scheduler;
echo "$ext_read_ahead_kb" > /sys/block/mmcblk1/bdi/read_ahead_kb;

# busybox addons
if [ -e /system/xbin/busybox ] && [ ! -e /sbin/ifconfig ]; then
	$BB ln -s /system/xbin/busybox /sbin/ifconfig;
fi;

# enable kmem interface for everyone by GM
echo "0" > /proc/sys/kernel/kptr_restrict;

# apply STweaks defaults
export CONFIG_BOOTING=1
/res/uci.sh apply
export CONFIG_BOOTING=

OPEN_RW;

if [ -d /system/etc/init.d ]; then
  /sbin/busybox chmod 755 /system/etc/init.d/*
  /sbin/busybox run-parts /system/etc/init.d
fi

# CPU Voltage Control Switch

if [ "$CONTROLSWITCH_CPU" == "on" ]; then

	newvolt17=$(( $(grep 384000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT17) ))
	newvolt16=$(( $(grep 486000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT16) ))
	newvolt15=$(( $(grep 594000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT15) ))
	newvolt14=$(( $(grep 702000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT14) ))
	newvolt13=$(( $(grep 810000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT13) ))
	newvolt12=$(( $(grep 918000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT11) ))
	newvolt11=$(( $(grep 1026000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT11) ))
	newvolt10=$(( $(grep 1134000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT10) ))
	newvolt9=$(( $(grep 1242000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT9) ))
	newvolt8=$(( $(grep 1350000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT8) ))
	newvolt7=$(( $(grep 1458000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT7) ))
	newvolt6=$(( $(grep 1566000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT6) ))
	newvolt5=$(( $(grep 1674000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT5) ))
	newvolt4=$(( $(grep 1782000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT4) ))
	newvolt3=$(( $(grep 1890000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT3) ))
	newvolt2=$(( $(grep 1998000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT2) ))
	newvolt1=$(( $(grep 2106000 /data/.googymax3/vdd_levels.ggy | awk '{print $2}') + ($CPUVOLT1) ))

	echo "384000 $newvolt17" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "486000 $newvolt16" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "594000 $newvolt15" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "702000 $newvolt14" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "810000 $newvolt13" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "918000 $newvolt12" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1026000 $newvolt11" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1134000 $newvolt10" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1242000 $newvolt9" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1350000 $newvolt8" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1458000 $newvolt7" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1566000 $newvolt6" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1674000 $newvolt5" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1782000 $newvolt4" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1890000 $newvolt3" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "1998000 $newvolt2" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
	echo "2106000 $newvolt1" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels
		
fi

# Selinux Switch

	setenforce 0;

# GPU Voltage Control Switch

if [ "$CONTROLSWITCH_GPU" == "on" ]; then

	newvolt1=$(( $(sed -n '1p' /data/.googymax3/GPU_mV_table.ggy) + ($GPUVOLT1) ))
	newvolt2=$(( $(sed -n '2p' /data/.googymax3/GPU_mV_table.ggy) + ($GPUVOLT2) ))
	newvolt3=$(( $(sed -n '3p' /data/.googymax3/GPU_mV_table.ggy) + ($GPUVOLT3) ))

	echo "$newvolt1 $newvolt2 $newvolt3" > /sys/devices/system/cpu/cpu0/cpufreq/GPU_mV_table
fi

# ROOT activation if supersu used
if [ -e /system/app/SuperSU.apk ] && [ -e /system/xbin/daemonsu ]; then
	if [ "$(pgrep -f "/system/xbin/daemonsu" | wc -l)" -eq "0" ]; then
		/system/xbin/daemonsu --auto-daemon &
	fi;
fi;

if [ -f /system/app/STweaks.apk ] || [ -f /data/app/STweaks.apk ] ; then
	$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
	$BB rm -f /data/app/STweaks.apk > /dev/null 2>&1;
	$BB rm -f /system/app/STweaks_Googy-Max.apk > /dev/null 2>&1;
	$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
	$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
	$BB cp /res/STweaks_Googy-Max.apk /system/app/;
	$BB chown root.root /system/app/STweaks_Googy-Max.apk;
	$BB chmod 644 /system/app/STweaks_Googy-Max.apk;
fi;

if [ ! -f /system/app/STweaks_Googy-Max.apk ] ; then
	$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
	$BB rm -f /data/app/STweaks.apk > /dev/null 2>&1;
	$BB rm -f /system/app/STweaks_Googy-Max.apk > /dev/null 2>&1;
	$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
	$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
	$BB cp /res/STweaks_Googy-Max.apk /system/app/;
	$BB chown root.root /system/app/STweaks_Googy-Max.apk;
	$BB chmod 644 /system/app/STweaks_Googy-Max.apk;
fi;

# echo "20000" > /proc/sys/vm/dirty_expire_centisecs;
# echo "20000" > /proc/sys/vm/dirty_writeback_centisecs;

# Special kernel tweaks (thx to nfsmw_gr)
if [ "$tweaks" == "on" ];then

echo "256" > /proc/sys/fs/inotify/max_user_instances;
echo "32000" > /proc/sys/fs/inotify/max_queued_events;
echo "10" > /proc/sys/kernel/panic;
echo "10" > /proc/sys/fs/lease-break-time;
echo "6144,87380,524288" > /proc/sys/net/ipv4/tcp_rmem;
echo "524288" > /proc/sys/kernel/threads-max;
echo "524288" > /proc/sys/fs/file-max;
echo "65536" > /proc/sys/kernel/msgmax;
echo "6144,87380,524288" > /proc/sys/net/ipv4/tcp_wmem;
echo "500,512000,64,2048" > /proc/sys/kernel/sem;
echo "524288" > /proc/sys/net/core/wmem_max;
echo "8192" > /proc/sys/vm/min_free_kbytes;
echo "524288" > /proc/sys/net/core/rmem_max;
echo "90" > /proc/sys/vm/dirty_ratio;
echo "268435456" > /proc/sys/kernel/shmmax;
echo "250" > /proc/sys/vm/dirty_expire_centisecs;
echo "1" > /proc/sys/vm/drop_caches;
echo "2048" > /proc/sys/kernel/msgmni;
echo "2" > /proc/sys/vm/min_free_order_shift;
echo "10240" > /proc/sys/fs/inotify/max_user_watches;
echo "70" > /proc/sys/vm/dirty_background_ratio;
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
echo "1" > /proc/sys/vm/overcommit_memory;
echo "50" > /proc/sys/vm/overcommit_ratio;  

fi;

	# Fix critical perms again after init.d mess
	CRITICAL_PERM_FIX;

