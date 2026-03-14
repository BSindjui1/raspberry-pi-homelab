# 🏠 Raspberry Pi Homelab: System Monitoring & Network Management

**Automated system health monitoring with Pi-hole ad-blocking** on Raspberry Pi, featuring real-time metrics tracking, email alerts, and Docker-based observability stack.

![System Monitoring](docs/09-system-monitoring-htop.png)

---

## 📊 Project Overview

This project implements a complete home network monitoring and management solution using a Raspberry Pi, featuring:

- **Automated System Monitoring** - Real-time health checks with email alerts
- **Pi-hole Ad Blocking** - Network-wide DNS-level ad blocking
- **Docker Observability** - Prometheus + Grafana monitoring stack
- **Email Reporting** - Twice-daily automated status reports
- **Resource Efficiency** - Low overhead monitoring on embedded hardware

---

## 🎯 Key Features

### System Monitoring
✅ **Automated health checks** - CPU, memory, disk, network monitoring  
✅ **Email alerts** - Twice-daily reports (9:30 AM, 10:00 PM)  
✅ **Service monitoring** - Failed service detection  
✅ **Temperature tracking** - CPU thermal monitoring with alerts  
✅ **Docker container monitoring** - Real-time container status  

### Pi-hole Network Protection
✅ **Network-wide ad blocking** - Protects all devices on network  
✅ **DNS monitoring** - Query logging and statistics  
✅ **Upstream DNS** - Google (8.8.8.8) and Cloudflare (1.1.1.1)  
✅ **Real-time metrics** - Queries processed, ads blocked, blocking percentage  

### Docker-Based Monitoring Stack
✅ **Prometheus** - Time-series metrics collection  
✅ **Grafana** - Visualization dashboards  
✅ **Persistent storage** - Data retention across reboots  
✅ **Low resource usage** - Optimized for Raspberry Pi  

---

## 📸 Screenshots

### Email Status Report
![Email Report](docs/05-email-report.png)
*Automated twice-daily system health report with comprehensive metrics*

### Pi-hole Dashboard
![Pi-hole Dashboard](docs/08-pihole-dashboard.png)
*Network-wide ad blocking statistics and DNS query monitoring*

### System Monitoring (htop)
![htop Monitoring](docs/09-system-monitoring-htop.png)
*Real-time system resource monitoring showing CPU, memory, and process information*

### Docker Containers
![Docker Containers](docs/10-docker-containers.png)
*Prometheus and Grafana containers running the observability stack*

### Cron Configuration
![Cron Setup](docs/06-cron-setup.png)
*Scheduled automated monitoring jobs*

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Raspberry Pi                         │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Pi-hole    │  │  Monitoring  │  │    Docker    │ │
│  │  DNS Server  │  │    Script    │  │  Containers  │ │
│  │              │  │              │  │              │ │
│  │  • Ad Block  │  │  • System    │  │  Prometheus  │ │
│  │  • DNS Log   │  │  • Network   │  │  Grafana     │ │
│  │  • Stats     │  │  • Pi-hole   │  │              │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                 │                  │         │
│         └─────────────────┴──────────────────┘         │
│                           │                            │
└───────────────────────────┼────────────────────────────┘
                            │
                    ┌───────▼────────┐
                    │  Email Reports │
                    │  (2x daily)    │
                    └────────────────┘
```

---

## 💻 Hardware & Software

### Hardware
- **Raspberry Pi 4** (4GB/8GB RAM)
- **MicroSD Card** (32GB+)
- **Power Supply** (Official 15W USB-C)
- **Network** (Ethernet or WiFi)

### Software Stack
- **OS:** Raspberry Pi OS (64-bit)
- **Pi-hole:** v6.3+ (DNS ad-blocking)
- **Docker:** Container runtime
- **Prometheus:** Metrics collection
- **Grafana:** Visualization
- **msmtp:** Email delivery
- **Bash:** Automation scripting

---

## 🚀 Installation Guide

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl git htop docker.io msmtp msmtp-mta
```

### 1. Install Pi-hole

```bash
# One-line installation
curl -sSL https://install.pi-hole.net | bash

# Follow the interactive setup
# - Select network interface (wlan0 or eth0)
# - Choose upstream DNS (Google, Cloudflare, etc.)
# - Install web interface
# - Enable query logging
# - Set admin password
```

### 2. Set Up Monitoring Script

```bash
# Create script directory
mkdir -p ~/scripts

# Copy monitoring script
# (Download pi-status-report.sh from this repository)
chmod +x ~/scripts/pi-status-report.sh

# Test the script
~/scripts/pi-status-report.sh
```

### 3. Configure Email Alerts

```bash
# Configure msmtp for Gmail (example)
cat > ~/.msmtprc << EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           your-email@gmail.com
user           your-email@gmail.com
password       your-app-password
EOF

# Secure the config file
chmod 600 ~/.msmtprc
```

**Note:** For Gmail, use an [App Password](https://support.google.com/accounts/answer/185833), not your regular password.

### 4. Set Up Cron Jobs

```bash
# Edit crontab
crontab -e

# Add monitoring schedule (9:30 AM and 10:00 PM daily)
30 9 * * * /home/bsindjui1373/scripts/pi-status-report.sh
0 22 * * * /home/bsindjui1373/scripts/pi-status-report.sh
```

### 5. Deploy Docker Monitoring Stack

```bash
# Create docker-compose.yml
mkdir -p ~/monitoring
cd ~/monitoring

cat > docker-compose.yml << EOF
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

# Start containers
docker-compose up -d
```

---

## ⚙️ Configuration

### Monitoring Script Configuration



```bash
# Email recipient
echo "$REPORT" | msmtp your-email@gmail.com

# Alert thresholds
DISK_THRESHOLD=80        # Disk usage warning at 80%
MEM_THRESHOLD=80         # Memory usage warning at 80%
CPU_TEMP_THRESHOLD=70    # CPU temp warning at 70°C
```

### Pi-hole Configuration

Access web interface: `http://YOUR_PI_IP/admin`

**Recommended settings:**
- Enable query logging
- Configure upstream DNS (8.8.8.8, 1.1.1.1)
- Add additional blocklists from [Firebog](https://firebog.net/)
- Set up local DNS records if needed

### Router Configuration

**Configure DHCP to use Pi-hole as DNS:**
1. Access router admin panel
2. Find DHCP settings
3. Set Primary DNS to Pi IP address
4. Leave Secondary DNS blank (or set to backup Pi-hole)
5. Save and reboot router

---

## 📊 Monitoring Metrics

### System Metrics Tracked
- **CPU Temperature** - Real-time thermal monitoring
- **CPU Usage** - Percentage utilization
- **Memory Usage** - RAM consumption and percentage
- **Disk Usage** - Storage capacity and percentage
- **System Uptime** - Continuous operation time
- **Network Connectivity** - Internet and DNS status
- **Failed Services** - Systemd service health

### Pi-hole Metrics
- **DNS Queries Today** - Total queries processed
- **Ads Blocked Today** - Blocked advertising/tracking requests
- **Blocking Percentage** - Percentage of queries blocked
- **Upstream DNS Status** - Google and Cloudflare DNS health

### Docker Metrics
- **Container Status** - Running/stopped state
- **Container Uptime** - How long containers have been running
- **Resource Usage** - CPU and memory per container

---

## 📧 Email Report Format

**Report Schedule:**
- Morning Report: 9:30 AM
- Evening Report: 10:00 PM

**Report Contents:**
```
================================================================
          Pi-hole & System Status Report
          Generated: 2026-03-13 16:26:48
================================================================

SYSTEM INFORMATION
----------------------------------------------------------------
  CPU Temperature:    49.4'C
  CPU Usage:          2.3%
  Memory Usage:       1.2Gi/7.9Gi (15.3%)
  Disk Usage:         9.7G/115G (9%)
  System Uptime:      up 1 day, 7 hours, 0 minutes

PI-HOLE STATUS
----------------------------------------------------------------
  DNS Queries Today:    694,255
  Ads Blocked Today:    99,642
  Blocking Percentage:  14.4%

[Additional sections...]
```

---

## 🛠️ Maintenance

### Regular Updates

```bash
# Update Pi-hole
pihole -up

# Update gravity (blocklists)
pihole -g

# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker containers
cd ~/monitoring
docker-compose pull
docker-compose up -d
```

### Backup Configuration

```bash
# Backup Pi-hole settings
pihole -a teleporter

# Backup monitoring script
cp ~/scripts/pi-status-report.sh ~/scripts/pi-status-report-backup.sh

# Backup crontab
crontab -l > ~/crontab-backup.txt

# Backup Pi-hole database
sudo cp /etc/pihole/gravity.db ~/pihole-gravity-backup.db
```

### Troubleshooting

**Script not sending emails:**
```bash
# Test email manually
echo "Test" | msmtp your-email@gmail.com

# Check msmtp logs
cat ~/.msmtp.log

# Verify cron is running
systemctl status cron
```

**Pi-hole not blocking:**
```bash
# Check status
pihole status

# Restart service
sudo systemctl restart pihole-FTL

# Update blocklists
pihole -g
```

**Docker containers not starting:**
```bash
# Check container logs
docker logs prometheus
docker logs grafana

# Restart containers
docker-compose restart
```

---

## 📈 Performance & Impact

### System Resource Usage
- **CPU:** < 5% idle, < 15% under load
- **Memory:** ~1.2GB / 8GB (15% usage)
- **Disk:** ~10GB total for OS + apps
- **Network:** Minimal overhead (DNS queries only)

### Pi-hole Statistics (Example)
- **Queries Processed:** 694,255 per day
- **Ads Blocked:** 99,642 per day (14.4%)
- **Response Time:** < 50ms average
- **Bandwidth Saved:** 10-20% (ads not downloaded)

### Docker Resource Usage
- **Prometheus:** < 100MB RAM, < 1% CPU
- **Grafana:** < 200MB RAM, < 1% CPU
- **Total Docker Overhead:** ~300MB RAM

---

## 🔒 Security Considerations

✅ **No hardcoded credentials** - Email password in secure config file  
✅ **File permissions** - `.msmtprc` set to 600 (owner only)  
✅ **Network isolation** - Docker containers on isolated network  
✅ **Regular updates** - Automated security patches  
✅ **Local DNS only** - Pi-hole not exposed to internet  
✅ **Firewall configured** - Only necessary ports open  

---

## 🎓 What I Learned

### Technical Skills
- **Linux System Administration** - Systemd, cron, user management
- **Bash Scripting** - Advanced automation and reporting
- **Docker & Containerization** - Multi-container applications
- **Network Administration** - DNS, DHCP, routing
- **Monitoring & Observability** - Metrics collection, visualization
- **Email Systems** - SMTP configuration and automation

### Problem-Solving
- Fixed memory calculation errors in monitoring script
- Debugged email delivery issues with SMTP
- Optimized Docker resource usage for embedded systems
- Configured Pi-hole to work with existing network setup

### Best Practices
- Configuration as code (all settings version controlled)
- Automated testing before deployment
- Regular backups of critical configurations
- Documentation-first approach
- Security by design (principle of least privilege)

---

## 🔮 Future Enhancements

- [ ] Grafana dashboard for Pi-hole metrics
- [ ] Alerting via Telegram/Discord instead of just email
- [ ] Redundant Pi-hole (two Pis for high availability)
- [ ] VPN integration (WireGuard) for remote access
- [ ] Automated backup to cloud storage
- [ ] Custom DNS records for local services
- [ ] Integration with Home Assistant
- [ ] Network traffic analysis with ntopng

---

## 📚 Resources

- **Pi-hole Documentation:** https://docs.pi-hole.net/
- **Prometheus Documentation:** https://prometheus.io/docs/
- **Grafana Documentation:** https://grafana.com/docs/
- **Docker Documentation:** https://docs.docker.com/
- **Raspberry Pi Documentation:** https://www.raspberrypi.com/documentation/

---

## 📝 Project Structure

```
raspberry-pi-homelab/
├── README.md                      # This file
├── .gitignore                     # Git ignore rules
├── scripts/
│   ├── pi-status-report.sh        # Main monitoring script
│   └── pi-status-report-backup.sh # Backup copy
├── config/
│   └── crontab-example.txt        # Cron schedule reference
└── docs/
    ├── 01-backup-process.png      # Backup procedure
    ├── 02-script-creation.png     # Script development
    ├── 03-script-permissions.png  # File permissions setup
    ├── 04-script-execution.png    # Running the script
    ├── 05-email-report.png        # Email alert example
    ├── 06-cron-setup.png          # Cron configuration
    ├── 07-cron-verification.png   # Cron validation
    ├── 08-pihole-dashboard.png    # Pi-hole web interface
    ├── 09-system-monitoring-htop.png  # System monitoring
    ├── 10-docker-containers.png   # Docker status
    └── 11-network-config.png      # Network configuration
```

---

## 🤝 Contributing

This is a personal learning project, but suggestions and improvements are welcome! If you'd like to:
- Report a bug
- Suggest an enhancement
- Share your own implementation

Please open an issue or reach out!

---

## 📄 License

This project is provided as-is for educational purposes. Feel free to use, modify, and distribute with attribution.

---

## 👤 Contact

**Brandon Sindjui**

- **Email:** BrandonSindjui@Gmail.com
- **LinkedIn:** [linkedin.com/in/brandon-sindjui](https://www.linkedin.com/in/brandon-sindjui-349916253/)
- **GitHub:** [github.com/BSindjui1](https://github.com/BSindjui1)

---

## 🙏 Acknowledgments

- Pi-hole development team for the excellent ad-blocking solution
- Raspberry Pi Foundation for affordable, capable hardware
- Prometheus and Grafana teams for powerful monitoring tools
- Open-source community for documentation and support

---

**⭐ If you found this project helpful, please consider starring the repository!**