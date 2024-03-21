#!/bin/bash

# Thanks to https://lang-ship.com/reference/Arduino/libraries/RTC_RV-3028-C7_Arduino_Library/class_r_v3028.html#a9cbc9a009d4e5dbfeb29e366140be42b
# And the folks at https://github.com/raspberrypi/linux/issues/2912
# Forked directly from Phil Randal's https://github.com/philrandal/gpsctl/blob/master/configure-rv3028.sh

function wait_for_EEBusy_done {
   busy=$((0x04))
   while (( busy == 0x04 ))
   do
      status=$( i2cget -y 1 0x51 0x0E )
      busy=$((status & 0x04))
   done
}

rmmod rtc_rv3032

wait_for_EEBusy_done

# disable auto refresh
# on 3032 control is 10h
register=$( i2cget -y 1 0x51 0x10 )
writeback=$((register | 0x04))
i2cset -y 1 0x51 0x10 $writeback



# enable BSM in level switching mode
register=$( i2cget -y 1 0x51 0xC0 )
writeback=$((register | 0x20))
i2cset -y 1 0x51 0xC0 $writeback

# update EEPROM
# 3032 does not need 00h sent before sending UPDATE
#i2cset -y 1 0x51 0x27 0x00
# p44 of app manual
i2cset -y 1 0x51 0x3F 0x11

wait_for_EEBusy_done

# reenable auto refresh
register=$( i2cget -y 1 0x51 0x10 )
writeback=$((register & ~0x04))
i2cset -y 1 0x51 0x10 $writeback

wait_for_EEBusy_done

modprobe rtc_rv3032