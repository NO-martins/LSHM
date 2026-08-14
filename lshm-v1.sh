#!/bin/bash

# ============================================================
# Name: 	Linux System Health Monitor (LSHM)
# Purpose:	Utility to monitor core OS performance metrics
# ============================================================ 

# ---  Thresholds ---
# These limits are based on the industrial-standard site reliability engineering (SRE)


THRESHOLD_CPU=85	# Trigger warning if CPU usage exceeds 85%
THRESHOLD_RAM=85	# Trigger warning if physical memory usage exceeds 85%
THRESHOLD_DISK=90	# Trigger warning if root file system exceeds 90%
PING_TARGET="8.8.8.8"	# Highly reliable Public DNS server to test for conectivity

ERROR_COUNT=0
# An error counter to measure the number of errors for the log file

# --- Log Management ---
# The software uses a clean, system logging. Located safely within user space.

LOG_FILE="$HOME/bin/lshm/lshm-sys.log"

# --- Initialization & Timestamp Generation ---
# The software gets the exact system date and time

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S") 
cat << _EOF_
==============================================================
		LINUX SYSTEM HEALTH MONITOR (LSHM)
		Generated: $TIMESTAMP
=============================================================
_EOF_

# ============================================================
# MODULE 1: DISK SPACE MONITOR
# ============================================================
# LOGIC: Extract root file system in readable human text with df /, then grab the field 5 using 'awk' to isolate just the 5th colum, sed then strip off the % to leave an integer
DISK_USAGE=$(df / | awk '$NF=="/"{gsub("%","",$5);print $5}') 


# --- Disk Space Evaluation Logic ---
# The software compares the live disk integer against the global threshold config

if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
	echo "[WARNING] Disk Space is Critically low: ${DISK_USAGE}% (Limit: ${THRESHOLD_DISK}%"

	# Track the failure with an increment to counter
	((ERROR_COUNT++))  
else
	echo "[SUCCESS] Disk Space is healthy: ${DISK_USAGE}%"
fi


# ========================================================= 
# MODULE 2: RAM/MEMORY MONITOR
# ========================================================= 
# LOGIC: Navigate to Mem from 'free' then (calculate used / total) * 100, and format as integer.
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')


# --- Meomry Evaluation Metric ---
if [ "$RAM_USAGE" -gt "$THRESHOLD_RAM" ]; then
	echo "[wARNING] RAM Usage is dangerously high: ${RAM_USAGE}% (Limit: ${THRESHOLD_RAM}%)"
	((ERROR_COUNT++)) 
else
	echo "[SUCCESS] RAM Usage is healthy: ${RAM_USAGE}%"
fi


# ========================================================
# MODULE 3: CPU USAGE MONITOR
# ========================================================
# LOGIC: Basically isolates '%Cpu(s);, grabs the idle element, and subtract from 100%
CPU_USAGE=$(top -bn1 | grep "%Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1) # -d. to drop decimal point and -f1 to turn floating value to integer


# --- CPU Evaluation ---
if [ "$CPU_USAGE" -gt "$THRESHOLD_CPU" ]; then
	echo "[WARNING] CPU Load is critically high: ${CPU_USAGE}% (Limit: ${THRESHOLD_CPU}%)"
	((ERROR_COUNT++))
else
	echo "[SUCCESS] CPU Usage is healthy: ${CPU_USAGE}%"
fi


# ======================================================= 
# MODULE 4: NETWORK STATUS MONITOR
# =======================================================
# LOGIC: Silently ping the target IP and evaluate the execution exit status code.


# --- Network Status Evaluation---
ping -c 1 -W 2 -w 2  "$PING_TARGET" > /dev/null 2>&1
# Check exit status of of ping immediately
if [ "$?" -eq 0 ]; then
	echo "[SUCCESS] Network Connection: Connected"
else
	echo "[WARNING] Network Connection: Disconnected or Unreachable"
	cat << _EOF_
[Troubleshooting Steps]
1. Hardware:  Check network cables or Wifi status
2. Gateway:   Try pinging your Local router IP
3. Firewall:  Ensure security rules allows outbound ICMP
4. IP config: Verify your machine has a valid IP address
_EOF_


	((ERROR_COUNT++))
fi
