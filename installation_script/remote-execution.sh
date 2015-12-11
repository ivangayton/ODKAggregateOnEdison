# Copyright 2015 The Project Buendia Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at: http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distrib-
# uted under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.  See the License for
# specific language governing permissions and limitations under the License.

# Utility functions for executing shell commands and scripts on an Edison.

# This version slightly modified by Ivan: 
# I added a copy_to_edison function to make scp transfers easy and readable. 
# Also this version targets bash rather than ash (bash is the default shell 
# on Ubilinux, # while ash is apparently what is used on the Yocto 
# distribution targeted by the original Buendia authors.

export TARGET_IPADDR
if [ ! -n "$TARGET_IPADDR" ]; then
    TARGET_IPADDR=192.168.2.15
fi

target="root@$TARGET_IPADDR"
key_file=$HOME/.ssh/edison
ssh_opts="-i $key_file -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ssh="ssh $ssh_opts"
scp="scp $ssh_opts"

# Executes the (bash) shell commands passed into stdin on the Edison.
# Typical use: do_on_edison <<< "commands..."
function do_on_edison() {
    connect_ethernet
    echo ">> $target" 1>&2
    result_file=/tmp/result.$$
    # Saving the exit status lets us use grep to suppress the annoying "Warning:
    # Permanently added..." message, while returning the exit status of bash.
    (
        $ssh $target bash
        echo $? > $result_file
    ) 2>&1 | grep -v 'Warning: Permanently added' || true
    result=$(cat $result_file)
    rm -f $result_file
    echo "<< $result" 1>&2
    return $result
}

# Writes the contents of stdin to a file on the Edison.
# Typical use: write_to_edison filename <<< "text..."
function write_to_edison() {
    file=$1
    connect_ethernet
    echo "=> $target:$file" 1>&2
    result_file=/tmp/result.$$
    # Saving the exit status lets us use grep to suppress the annoying "Warning:
    # Permanently added..." message, while returning the exit status of cat.
    (
        $ssh $target "cat > '$file'"
        echo $? > $result_file
    ) 2>&1 | grep -v 'Warning: Permanently added' || true
    result=$(cat $result_file)
    rm -f $result_file
    echo "<= $result" 1>&2
    return $result
}

# Sends a file to the Edison using scp.
# Typical use: copy_to_edison path/to/file /path/to/destination
function copy_to_edison() {
    local_file=$1
    remote_path=$2
    connect_ethernet
    if [ ! -f $local_file ]; then
      echo Your file $local_file does not seem to exist. That might be a problem.
    fi

    if [ -f $local_file ]; then
      $scp $local_file $target:/$remote_path
    fi
}

# Connect a host Linux system to the Edison on its USB Ethernet interface.
function connect_linux_ethernet() {
    if [[ "$OSTYPE" = linux* ]]; then
        if [ $(id -u) != 0 ]; then
            echo "Username: $USER (on $(hostname))" 1>&2
            sudo ifconfig usb0 up 192.168.2.1 2>/dev/null
        else
            ifconfig usb0 up 192.168.2.1 2>/dev/null
        fi
    fi
}

# Connect a host Mac system to the Edison on its USB Ethernet interface.
function connect_mac_ethernet() {
    if [[ "$OSTYPE" = darwin* ]]; then
        usbif=$(ifconfig | grep -v '^en[01]:' | grep -vw UP | grep -o '^en[0-9]\+')
        if [ -n "$usbif" ]; then
            if [ $(id -u) != 0 ]; then
                echo "Username: $USER (on $(hostname))" 1>&2
                sudo ifconfig $usbif up 192.168.2.1 2>/dev/null
            else
                ifconfig $usbif up 192.168.2.1 2>/dev/null
            fi
        fi
    fi
}

# Connect a host system to the Edison on its USB Ethernet interface.
function connect_ethernet() {
    retry_count=0
    while true; do
        connect_linux_ethernet || true
        connect_mac_ethernet || true
        if ping -c 1 -t 1 $TARGET_IPADDR >/dev/null 2>/dev/null; then break; fi
        if [[ $retry_count = 0 ]]; then
            echo "Waiting for Edison to come up at $TARGET_IPADDR.  Connect"
            echo "a USB cable from this computer to the Edison's USB OTG port."
        fi
        sleep 1

        echo -n '.' 1>&2
        let retry_count=retry_count+1
        if [[ "$OSTYPE" = darwin* && $retry_count = 3 ]]; then
            echo '
If the Edison does not appear within 30 seconds of power-on, open
Network Preferences and look for a new Ethernet device.  Try clicking
the small + at the bottom of the list of network devices and looking
for Multifunction Composite Gadget (enX) in the dropdown list.
Select the new network device.  In the Configure IPv4 dropdown list,
select Manually, set your IP Address to 192.168.2.1, and click Apply.
' 1>&2
        fi
    done
}
