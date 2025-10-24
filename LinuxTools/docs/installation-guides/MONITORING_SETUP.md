# Monitoring Setup Guide

This guide covers setting up monitoring agents and configuring system monitoring.

## Overview

LinuxTools supports multiple monitoring solutions:
- **Datadog**: Full-featured APM and infrastructure monitoring
- **New Relic**: Application performance monitoring
- **Prometheus**: Open-source metrics and alerting
- **Zabbix**: Enterprise monitoring platform
- **Netdata**: Real-time performance monitoring

## Quick Setup

### Option 1: Interactive Setup

```bash
cd LinuxTools/monitoring-agents
sudo ./setup-monitoring.sh
```

Select the monitoring agent you want to install from the menu.

### Option 2: Direct Installation

Each monitoring agent has its own installation script.

## Datadog Setup

### Prerequisites
- Datadog account and API key

### Installation

```bash
export DD_API_KEY="your-api-key-here"
cd LinuxTools/monitoring-agents/datadog
sudo ./install.sh
```

### Configuration

Configuration files are located in `/etc/datadog-agent/`:

```bash
# Main configuration
sudo vim /etc/datadog-agent/datadog.yaml

# Integration configs
sudo vim /etc/datadog-agent/conf.d/
```

### Apply Configuration Templates

```bash
# System core metrics
sudo cp config-templates/system-core.yaml /etc/datadog-agent/conf.d/

# Nginx monitoring
sudo cp config-templates/nginx.yaml /etc/datadog-agent/conf.d/

# PostgreSQL monitoring
sudo cp config-templates/postgresql.yaml /etc/datadog-agent/conf.d/
```

### Verify Installation

```bash
sudo datadog-agent status
```

## Prometheus Node Exporter

### Installation

```bash
cd LinuxTools/monitoring-agents/prometheus
sudo ./setup-node-exporter.sh
```

### Verify

```bash
curl http://localhost:9100/metrics
```

### Configure Prometheus Server

Add this job to your Prometheus server's `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['your-server:9100']
        labels:
          instance: 'production-server'
```

## Netdata

### Installation

```bash
cd LinuxTools/monitoring-agents/netdata
sudo ./install.sh
```

### Access Dashboard

```
http://your-server-ip:19999
```

### Configuration

```bash
# Edit configuration
sudo /usr/sbin/netdata -W set

# Main config file
sudo vim /etc/netdata/netdata.conf
```

## New Relic

### Prerequisites
- New Relic account and license key

### Installation

```bash
export NEW_RELIC_LICENSE_KEY="your-license-key"
cd LinuxTools/monitoring-agents/newrelic
sudo ./install.sh
```

### Configuration

```bash
sudo vim /etc/newrelic-infra.yml
```

## Zabbix Agent

### Prerequisites
- Zabbix server IP/hostname

### Installation

```bash
export ZABBIX_SERVER="zabbix-server.example.com"
cd LinuxTools/monitoring-agents/zabbix
sudo ./agent-install.sh
```

### Configuration

```bash
sudo vim /etc/zabbix/zabbix_agent2.conf
```

## Custom Metrics

### Prometheus Custom Metrics

Create custom metrics script:

```bash
cd LinuxTools/monitoring-agents/prometheus/node-exporter
sudo ./custom-metrics.sh
```

### Datadog Custom Metrics

Create custom check:

```python
# /etc/datadog-agent/checks.d/custom_check.py
from checks import AgentCheck

class CustomCheck(AgentCheck):
    def check(self, instance):
        self.gauge('custom.metric', 100)
```

## Alerting

### Prometheus Alert Rules

Create alert rules in `prometheus/alert-rules/`:

```yaml
groups:
  - name: system_alerts
    rules:
      - alert: HighCPUUsage
        expr: node_cpu_seconds_total > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
```

### Datadog Monitors

Configure monitors through the Datadog UI or API.

## Best Practices

### 1. Resource Planning

- Node Exporter: ~50MB RAM
- Netdata: ~100-200MB RAM
- Datadog Agent: ~100MB RAM
- Zabbix Agent: ~20MB RAM

### 2. Retention Policies

Configure appropriate data retention:

```bash
# Prometheus
retention.time=15d

# Netdata
history = 3600  # seconds
```

### 3. Security

- Use TLS for metric transmission
- Restrict access to monitoring ports
- Rotate API keys regularly

### 4. High Availability

- Monitor multiple replicas
- Use redundant monitoring agents
- Configure alerting to multiple channels

## Troubleshooting

### Agent Not Starting

```bash
# Check status
sudo systemctl status datadog-agent
sudo systemctl status node_exporter
sudo systemctl status netdata

# Check logs
sudo journalctl -u datadog-agent -n 50
sudo journalctl -u node_exporter -n 50
```

### Metrics Not Appearing

1. Verify agent is running
2. Check firewall rules
3. Verify API keys/credentials
4. Review agent logs

### High Resource Usage

1. Disable unnecessary integrations
2. Increase collection intervals
3. Limit metric cardinality

## Integration with Other Tools

### Grafana

Create Grafana dashboards for Prometheus:

```bash
# Import Node Exporter dashboard
Dashboard ID: 1860
```

### Alert Manager

Configure Prometheus Alert Manager for notifications:

```yaml
receivers:
  - name: 'team-email'
    email_configs:
      - to: 'team@example.com'
```

## Updating Agents

```bash
cd LinuxTools
sudo ./update-tools.sh
```

## Uninstalling

### Datadog
```bash
sudo apt-get remove datadog-agent
```

### Prometheus Node Exporter
```bash
sudo systemctl stop node_exporter
sudo systemctl disable node_exporter
sudo rm /etc/systemd/system/node_exporter.service
```

### Netdata
```bash
sudo /usr/libexec/netdata/netdata-uninstaller.sh --yes
```

## Further Reading

- [Datadog Documentation](https://docs.datadoghq.com/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Netdata Documentation](https://learn.netdata.cloud/)
- [Zabbix Documentation](https://www.zabbix.com/documentation)
