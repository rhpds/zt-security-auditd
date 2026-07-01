# AuditD Lab - Command Reference

Quick reference for all commands used in the lab modules.

## Module 1: Installation & Configuration

```bash
# Verify installation
dnf list installed audit

# Review configuration
sudo cat /etc/audit/auditd.conf

# Backup configuration
sudo cp /etc/audit/auditd.conf /etc/audit/auditd.conf.backup

# Modify configuration
sudo sed -i 's/space_left = 75/space_left = 5120/' /etc/audit/auditd.conf

# Restart service
sudo service auditd condrestart
sudo service auditd status
```

## Module 2: Understanding Audit Logs

```bash
# View audit log directory
sudo ls -lahn /var/log/audit/

# View recent logs
sudo tail -20 /var/log/audit/audit.log

# Search for authentication events
sudo ausearch -m USER_AUTH -ts today | head -30
```

## Module 3: Creating Watch Rules

```bash
# Create test file
touch /home/rhel/log_everything_and_the_kitchen_sink.txt
echo "Logging everything, including the kitchen sink, because why not? Let's see what happens!" > /home/rhel/log_everything_and_the_kitchen_sink.txt

# Create watch rule
sudo auditctl -w /home/rhel/log_everything_and_the_kitchen_sink.txt -S all -k rhel-docs-temp

# View the file
cat /home/rhel/log_everything_and_the_kitchen_sink.txt

# Search audit logs
sudo ausearch -f /home/rhel/log_everything_and_the_kitchen_sink.txt
sudo ausearch -k rhel-docs-temp -ts today
```

## Module 4: Preconfigured Rules

```bash
# View available rules
ls /usr/share/audit-rules/

# Remove existing rules
sudo rm -f /etc/audit/rules.d/*

# Copy STIG rules
sudo cp /usr/share/audit-rules/10-base-config.rules /etc/audit/rules.d/
sudo cp /usr/share/audit-rules/30-stig.rules /etc/audit/rules.d/
sudo cp /usr/share/audit-rules/31-privileged.rules /etc/audit/rules.d/
sudo cp /usr/share/audit-rules/99-finalize.rules /etc/audit/rules.d/

# Load rules
sudo augenrules --load

# Verify rules
sudo auditctl -l | head -30
```

## Module 5: Custom Rule Creation

```bash
# Create temporary rule
sudo auditctl -a always,exit -F exe=/usr/bin/ping -k rhkey

# Test the rule
ping -c 2 localhost

# Search for events
sudo ausearch -k rhkey -ts recent

# Create persistent rule file
sudo touch /etc/audit/rules.d/70-rhkey_lab.rules
echo "-a always,exit -S all -F exe=/usr/bin/ping -F key=rhkey" | sudo tee /etc/audit/rules.d/70-rhkey_lab.rules

# Reload rules
sudo augenrules --load

# Verify rule
sudo auditctl -l | grep rhkey

# Set kernel buffer size
sudo auditctl -b 8192

# Make buffer setting persistent
sudo touch /etc/audit/rules.d/15-rhkey_kernel.rules
echo "-b 8192" | sudo tee /etc/audit/rules.d/15-rhkey_kernel.rules
sudo augenrules --load

# Verify buffer size
sudo auditctl -s | grep backlog
```

## Module 6: Generating Reports

```bash
# General summary
sudo aureport --start today --summary

# File access report
sudo aureport --start today --summary -i --file

# Executable report
sudo aureport --start today --summary -i --executable

# Login report
sudo aureport --start today --summary -i --login

# Custom report by key
sudo ausearch --start today -k rhkey --raw | sudo aureport --summary -i --file

# Login history
sudo aulast
sudo aulast --proof | head -20

# Last login info
sudo aulastlog

# Failed events only
sudo aureport --start today --failed

# Authentication report
sudo aureport --start today --auth

# Modification events
sudo aureport --start today --mods

# Anomaly report
sudo aureport --start today --anomaly
```

## Common ausearch Options

```bash
-m TYPE      # Message type (USER_AUTH, SYSCALL, etc.)
-ts TIME     # Start time (today, recent, yesterday, timestamp)
-te TIME     # End time
-k KEY       # Search by key
-f FILE      # Search by filename
-ui UID      # Search by user ID
--raw        # Output in raw format (for piping to aureport)
```

## Common aureport Options

```bash
--start TIME    # Start time
--end TIME      # End time
--summary       # Generate summary report
-i              # Interpret numeric values to names
--file          # File access report
--executable    # Executable report
--login         # Login report
--auth          # Authentication report
--failed        # Show only failed events
--mods          # Modification events
--anomaly       # Anomaly report
```

## Sample Custom Rules

```bash
# Monitor file access
-w /etc/passwd -p wa -k passwd_changes

# Monitor directory
-w /etc/ssh/ -p wa -k ssh_config

# Monitor syscall by executable
-a always,exit -F arch=b64 -S execve -F exe=/usr/bin/sudo -k sudo_exec

# Monitor by user ID
-a always,exit -F arch=b64 -S all -F uid=1001 -k user_1001_activity
```

## Time Range Shortcuts

- `today` - From midnight today
- `recent` - Last 10 minutes
- `yesterday` - From midnight yesterday
- `boot` - Since last system boot
- `"04/01/2026 00:00:00"` - Specific date/time
- `now` - Current time

## Practical Investigation Scenarios

```bash
# Investigate failed login attempts
sudo aureport --start today --auth --failed -i

# Find who accessed sensitive files
sudo ausearch -f /etc/shadow -ts today

# Track privileged command execution
sudo ausearch -k access -ts boot --raw | sudo aureport -x -i

# View all actions by a specific user
sudo ausearch -ui 1000 -ts today

# Find all file modifications today
sudo aureport --start today --mods -i
```
