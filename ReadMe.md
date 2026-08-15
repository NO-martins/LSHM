# Linux System Health Monitor (LSHM) v1.1

A lightweight, automated Bash utility designed to capture, evaluate and log core Linux Operating System performance metrics.

## Purpose: The Origin  Story

This project was born out of pure frustration, digital betrayal, and a sudden operating system rebellion.

Recently, my Windows machine decided to throw an unexpected corporate strike. After entering a rebellious phase of endless troubleshooting, and blue screens. I had a relization while waiting for a technician to put my machine back in one piece: **"I never want to be blind to my system diagnostics again"**

As I wrap up my fundamental Linux traning with Bash scripting as the final milestone, I built LSHM, instead of wasting precious days guessing what went wrong, this tool instantly collates critical metrics in oneclean dashboard. Since my Career path is tracking directly towards Cloud Security where Linux infrastructure is the baseline standard, LSHM ensures I am the absolute master of my environment from day one.

----------

## Key Features

* **Real-time Metrics Extraction:** Evaluate CPU Usage, physical RAM allocation, root disk capacity, and external network availability.
* **Stateful Log Logging:**         Generates automated, plain-text log lines with systematic severity headers ('[SUCCESS]', '[ERROR]').
* **High-Visibility CLI UI:**       Employs vibrant, high-intensity ANSI terminal escape code indicator for instant system state diagnostics.

----------

## System Architecture Flow

```
[System Performance Data] ---> [Text Extraction Pipelines] ---> [Threshold Verification Logic] 
[Metric Fails Threshold] --->  Flag State: [DEGRADED]
                               Prepend Code: COLOR_ERROR
                               Increment: ERROR_COUNT
[All Metrics Healthy] --->     flag State: [HEALTHY]
                               Prepend Code: COLOR_SUCCESS
                               Output: System is in Perfect condiition
```

----------

## Performance Threshold Configuration

The system uses standard entriprise warning parameters for performance flags:

| Metric Module | Data Extraction Source | Default Warning Limit | Core Mechanism |
| -+-+-+-+-+-+-+|+-+-+-+-+-+-+-+-+-+-+-+-|+-+-+-+-+-+-+-+-+-+-+-+|+-+-+-+-+-+-+-+-|
| **Disk Capacity** | 'df /' | **> 90%** | String stripping via 'awk' into raw integers. |
| **RAM Utilization** | 'free' | **> 85%** | Precise integer percentage calculation. |
| **Processor Load** | 'top -bn1' | **> 85%** | Captures kernel idle parameters. |
| **Network Interface** | 'ping -c 1 8.8.8.8' | **Exit Status > 0** | Verification checks routed to '/dev/null'. |
            
----------

## Post-Mortem & Battlefield Discoveries

Building this prototype was a loop of syntax traps. Here is the raw documentation of how this architecture evolved through trial and error:

## 1 Disk Space Refactor (Defeating Column Shift)
* **The Mess:** The initial blueprint relied on `df / | awk 'NR==2 {print $5}'`. While this worked on a clean baseline environment, running it on encrypted partitions shifts column, making `$5` grab empty string
* **The Breakthrough:** I *Refused* to copy-paste hardcoded bypasses. Instead researched `awk` field operators and came with `df /| awk 'NF=="/",{gsub("%","",$5);print $(NF-1)}'`. Anchoring (`$NF=="/"`), the script corrects the dynamic regardless of the filesystem length

## 2 Git Cached Persistence & Log Isolation
* **The Mess:** Adding `*.log` to the `.gitignore` config profile *after* the filesystem was already generated allowed the local staging index to continously track modifications
* **The Breakthrough:** I *Executed* a system cache using `git rm --cached lshm-sys.log`. This removed the file from version control while leaving physical target data intack on the system drive.

----------

## Future CLoud Security Roadmap

As I begin my studies at Lead City University (LCU) this September, I'll have LSH evolve from a local shell script into an enterprise-ready security asset. This phase includes:

* **Phase 1: The Python Automation Pivot (100-level)**
    Completely rewrite the monitoring core in Python with the standard Libraries to eliminate symbolic Bash constraints and enable structured data outputs.
* **Phase 2: Security & File Integrity Monitoring (FIM)**
    Integrate better hashing tools to actively track changes in critical system configuration files. If an unauthorized entity alters a core file, LSHM will flag it instantly as a security breach.
* **Phase 3: Cloud Log Streaming & Webhooks**
    Transition from local '.log' text files to live cloud metrics. Implement Python API connections to stream system health logs directly to a secure remote cloud repository or  trigger instant  notifications via webhooks when a critical failure occurs.    
