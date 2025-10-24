# Common Issues and Solutions

This document covers common issues you might encounter when using LinuxTools and their solutions.

## Installation Issues

### Issue: Package manager not found

**Error:**
```
No supported package manager found
```

**Solution:**
LinuxTools currently supports apt, dnf, and yum. If you're using a different package manager:
1. Install tools manually
2. Contribute support for your package manager to the project

### Issue: Permission denied

**Error:**
```
Permission denied
```

**Solution:**
Run the script with sudo:
```bash
sudo ./script-name.sh
```

### Issue: Script not executable

**Error:**
```
bash: ./script.sh: Permission denied
```

**Solution:**
```bash
chmod +x script.sh
```

## Monitoring Issues

### Issue: Datadog agent not starting

**Symptoms:**
- Agent service fails to start
- No metrics appearing in Datadog

**Solutions:**

1. Check API key:
```bash
sudo cat /etc/datadog-agent/datadog.yaml | grep api_key
```

2. Verify service status:
```bash
sudo systemctl status datadog-agent
```

3. Check logs:
```bash
sudo tail -f /var/log/datadog/agent.log
```

4. Restart agent:
```bash
sudo systemctl restart datadog-agent
```

### Issue: Prometheus Node Exporter not accessible

**Symptoms:**
- Cannot access http://localhost:9100/metrics
- Connection refused

**Solutions:**

1. Check if service is running:
```bash
sudo systemctl status node_exporter
```

2. Check firewall:
```bash
sudo ufw allow 9100/tcp
# or
sudo firewall-cmd --add-port=9100/tcp --permanent
```

3. Verify binding address:
```bash
sudo netstat -tlnp | grep 9100
```

### Issue: Netdata dashboard not loading

**Symptoms:**
- Cannot access http://server:19999
- Page not loading

**Solutions:**

1. Check if Netdata is running:
```bash
sudo systemctl status netdata
```

2. Check firewall:
```bash
sudo ufw allow 19999/tcp
```

3. Restart Netdata:
```bash
sudo systemctl restart netdata
```

## Security Issues

### Issue: SSH connection refused after hardening

**Symptoms:**
- Cannot connect via SSH
- Connection refused or timeout

**Solutions:**

1. Revert SSH configuration:
```bash
sudo cp /etc/ssh/sshd_config.backup-* /etc/ssh/sshd_config
sudo systemctl restart sshd
```

2. Check SSH is running:
```bash
sudo systemctl status sshd
```

3. Verify firewall allows SSH:
```bash
sudo ufw status | grep 22
```

4. Check SSH logs:
```bash
sudo tail -f /var/log/auth.log
```

### Issue: Locked out after firewall setup

**Symptoms:**
- Cannot access server remotely
- All connections timing out

**Solutions:**

If you have console access:
```bash
# Disable firewall temporarily
sudo ufw disable
# or
sudo systemctl stop firewalld

# Fix rules and re-enable
sudo ufw allow 22/tcp
sudo ufw enable
```

**Prevention:**
Always keep an active SSH session open when modifying firewall rules.

### Issue: Lynis scan fails

**Symptoms:**
- Lynis command not found
- Scan errors

**Solutions:**

1. Install Lynis:
```bash
sudo apt-get update
sudo apt-get install lynis
```

2. Update Lynis database:
```bash
sudo lynis update info
```

## Network Issues

### Issue: Network test script fails

**Symptoms:**
- Cannot resolve DNS
- Ping failures

**Solutions:**

1. Check network interfaces:
```bash
ip addr show
```

2. Check DNS configuration:
```bash
cat /etc/resolv.conf
```

3. Test basic connectivity:
```bash
ping -c 3 8.8.8.8
```

4. Check routing:
```bash
ip route show
```

### Issue: Port scanner not working

**Symptoms:**
- nmap command not found

**Solution:**
```bash
sudo apt-get install nmap
```

## Backup Issues

### Issue: Rsync backup fails

**Symptoms:**
- Permission denied errors
- Backup incomplete

**Solutions:**

1. Run with sudo:
```bash
sudo ./rsync-backup.sh
```

2. Check disk space:
```bash
df -h /backup
```

3. Verify source directory exists:
```bash
ls -la /source/directory
```

### Issue: MySQL backup fails

**Symptoms:**
- Authentication failed
- mysqldump errors

**Solutions:**

1. Set correct credentials:
```bash
export MYSQL_USER="backup_user"
export MYSQL_PASSWORD="password"
```

2. Verify MySQL is running:
```bash
sudo systemctl status mysql
```

3. Test connection:
```bash
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;"
```

4. Grant backup privileges:
```sql
GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'backup_user'@'localhost';
FLUSH PRIVILEGES;
```

## Performance Issues

### Issue: High memory usage

**Symptoms:**
- System slow
- Out of memory errors

**Solutions:**

1. Check memory usage:
```bash
free -h
top
```

2. Find memory hogs:
```bash
ps aux --sort=-%mem | head -10
```

3. Clean package cache:
```bash
sudo apt-get clean
# or
sudo yum clean all
```

### Issue: Disk full

**Symptoms:**
- No space left on device
- Cannot write files

**Solutions:**

1. Check disk usage:
```bash
df -h
du -sh /* | sort -h
```

2. Clean logs:
```bash
cd LinuxTools/automation-scripts/system-maintenance
sudo ./log-cleanup.sh
```

3. Remove old backups:
```bash
find /backup -mtime +30 -delete
```

4. Clean package cache:
```bash
sudo apt-get autoremove
sudo apt-get autoclean
```

## Container Issues

### Issue: Docker installation fails

**Symptoms:**
- Package conflicts
- Installation errors

**Solutions:**

1. Remove old Docker versions:
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

2. Clean up:
```bash
sudo apt-get update
sudo apt-get autoremove
```

3. Retry installation:
```bash
cd LinuxTools/container-tools/docker
sudo ./install-docker.sh
```

### Issue: Cannot connect to Docker daemon

**Symptoms:**
- Permission denied
- Cannot connect to Docker socket

**Solutions:**

1. Add user to docker group:
```bash
sudo usermod -aG docker $USER
```

2. Log out and back in, or:
```bash
newgrp docker
```

3. Start Docker service:
```bash
sudo systemctl start docker
```

## Log Issues

### Issue: Cannot write to log directory

**Symptoms:**
- Permission denied writing to /var/log/linuxtools

**Solution:**
```bash
sudo mkdir -p /var/log/linuxtools
sudo chmod 755 /var/log/linuxtools
```

### Issue: Log files too large

**Solution:**
```bash
cd LinuxTools/automation-scripts/system-maintenance
sudo ./log-cleanup.sh
```

## Script Errors

### Issue: "command not found"

**Solutions:**

1. Install missing dependencies:
```bash
# For Debian/Ubuntu
sudo apt-get install package-name

# For RHEL/CentOS
sudo yum install package-name
```

2. Update PATH:
```bash
export PATH=$PATH:/usr/local/bin
```

### Issue: "syntax error near unexpected token"

**Solution:**
Ensure you're using bash, not sh:
```bash
bash script.sh
# Not: sh script.sh
```

## Getting Additional Help

If you encounter an issue not covered here:

1. Check script logs in `/var/log/linuxtools/`
2. Review the script's source code for comments
3. Run with verbose output: `bash -x script.sh`
4. Check system logs: `sudo journalctl -xe`
5. Open an issue on GitHub with:
   - Error message
   - System information (OS, version)
   - Steps to reproduce
   - Relevant log excerpts

## Emergency Recovery

### Recover from Bad Configuration

1. Boot into single-user mode
2. Restore configuration backup:
```bash
cp /etc/config.backup /etc/config
```
3. Restart services:
```bash
systemctl restart service-name
```

### Factory Reset LinuxTools

```bash
# Remove configurations
sudo rm -rf /etc/linuxtools

# Remove logs
sudo rm -rf /var/log/linuxtools

# Reinstall
cd LinuxTools
sudo ./setup.sh
```

## Best Practices to Avoid Issues

1. **Always backup before changes**
2. **Test in non-production first**
3. **Keep active SSH session when modifying firewall**
4. **Review script output carefully**
5. **Keep system updated**
6. **Monitor disk space**
7. **Review logs regularly**
8. **Document custom changes**
