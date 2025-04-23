#!/usr/bin/env bash

# TODO add interactive mode for adding alias' to bashrc

echo 'alias check_cpu_mode=arr=("0" "1" "2" "3"); for i in ${arr[@]}; do cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done' >> ~/.bashrc
echo 'alias performance_mode=echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; check_cpu_mode' >> ~/.bashrc
echo 'alias powersave_mode=echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; check_cpu_mode' >> ~/.bashrc
echo 'alias cpu_frequency_watch=watch -n.5 "cat /proc/cpuinfo | grep \"^[c]pu MHz\""' >> ~/.bashrc
echo 'alias updateDiscord="~/projects/bash-scripts/updaters/updateDiscord.sh"' >> ~/.bashrc
