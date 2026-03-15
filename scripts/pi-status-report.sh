#!/bin/bash
# ==============================================================================
# Pi-hole & System Status Report Script
# Sends comprehensive system health report via email
# ==============================================================================

# Get current date and time
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes for terminal output (optional)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ==============================================================================
# SYSTEM CHECKS
# ==============================================================================

# CPU Temperature
CPU_TEMP=$(vcgencmd measure_temp | cut -d'=' -f2)

# CPU Usage (fixed for Raspberry Pi)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if [ -z "$CPU_USAGE" ]; then
    CPU_USAGE=$(top -bn1 | grep "%Cpu" | awk '{print $2}' | cut -d'%' -f1)
fi

# Memory Usage (FIXED - using bytes for accurate calculation)
MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
MEM_USED=$(free -m | awk 'NR==2{print $3}')
MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")
MEM_DISPLAY=$(free -h | awk 'NR==2{printf "%s/%s", $3,$2}')

# Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3,$2,$5}')
DISK_PERCENT=$(df / | awk 'NR==2{print $5}' | cut -d'%' -f1)

# System Uptime
UPTIME=$(uptime -p)

# ==============================================================================
# NETWORK CHECKS
# ==============================================================================

# Internet connectivity (Google DNS)
if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
    INTERNET_STATUS="✓ Internet connection: OK"
else
    INTERNET_STATUS="✗ Internet connection: FAILED"
fi

# DNS resolution check (using your actual upstream DNS)
if ping -c 3 google.com > /dev/null 2>&1; then
    DNS_STATUS="✓ DNS Resolution: OK"
else
    DNS_STATUS="✗ DNS Resolution: FAILED"
fi

# ==============================================================================
# PI-HOLE STATUS
# ==============================================================================

# Pi-hole status
PIHOLE_STATUS=$(pihole status 2>/dev/null || echo "Pi-hole status check failed")

# DNS upstream servers
DNS_UPSTREAMS=$(sudo pihole-FTL --config 2>/dev/null | grep "dns.upstreams" || echo "Could not retrieve DNS upstreams")

# Pi-hole FTL service status
PIHOLE_FTL_STATUS=$(systemctl status pihole-FTL 2>/dev/null | head -n 6 || echo "Could not retrieve pihole-FTL status")

# Queries blocked today (if available)
QUERIES_BLOCKED=$(pihole -c -j 2>/dev/null | grep -o '"ads_blocked_today":[0-9]*' | cut -d':' -f2 || echo "N/A")
QUERIES_TOTAL=$(pihole -c -j 2>/dev/null | grep -o '"dns_queries_today":[0-9]*' | cut -d':' -f2 || echo "N/A")

# ==============================================================================
# DOCKER STATUS (if running Prometheus/Grafana)
# ==============================================================================

if command -v docker &> /dev/null; then
    DOCKER_RUNNING=$(docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "Docker not running or no containers")
else
    DOCKER_RUNNING="Docker not installed"
fi

# ==============================================================================
# FAILED SERVICES CHECK
# ==============================================================================

FAILED_SERVICES=$(systemctl --failed --no-pager --no-legend)
if [ -z "$FAILED_SERVICES" ]; then
    FAILED_SERVICES="✓ No failed services"
fi

# ==============================================================================
# WARNINGS/ALERTS
# ==============================================================================

WARNINGS=""

# Disk space warning
if [ "$DISK_PERCENT" -gt 80 ]; then
    WARNINGS="${WARNINGS}⚠ WARNING: Disk usage is at ${DISK_PERCENT}%\n"
fi

# Memory warning
MEM_PERCENT_INT=$(echo $MEM_PERCENT | cut -d'.' -f1)
if [ "$MEM_PERCENT_INT" -gt 80 ]; then
    WARNINGS="${WARNINGS}⚠ WARNING: Memory usage is at ${MEM_PERCENT}%\n"
fi

# CPU temperature warning (throttling starts around 80°C)
CPU_TEMP_NUM=$(echo $CPU_TEMP | cut -d"'" -f1)
if (( $(echo "$CPU_TEMP_NUM > 70" | bc -l) )); then
    WARNINGS="${WARNINGS}⚠ WARNING: CPU temperature is high: ${CPU_TEMP}\n"
fi

if [ -z "$WARNINGS" ]; then
    WARNINGS="✓ All system metrics healthy"
fi

# ==============================================================================
# BUILD EMAIL REPORT
# ==============================================================================

REPORT="╔══════════════════════════════════════════════════════════════════╗
║          Pi-hole & System Status Report                         ║
║          Generated: $DATE                     ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│ SYSTEM INFORMATION                                              │
└─────────────────────────────────────────────────────────────────┘
  CPU Temperature:    $CPU_TEMP
  CPU Usage:          ${CPU_USAGE}%
  Memory Usage:       $MEM_DISPLAY (${MEM_PERCENT}%)
  Disk Usage:         $DISK_USAGE
  System Uptime:      $UPTIME

┌─────────────────────────────────────────────────────────────────┐
│ PI-HOLE STATUS                                                  │
└─────────────────────────────────────────────────────────────────┘
$PIHOLE_STATUS

  DNS Queries Today:    $QUERIES_TOTAL
  Ads Blocked Today:    $QUERIES_BLOCKED

┌─────────────────────────────────────────────────────────────────┐
│ DNS CONFIGURATION                                               │
└─────────────────────────────────────────────────────────────────┘
$DNS_UPSTREAMS

┌─────────────────────────────────────────────────────────────────┐
│ NETWORK CONNECTIVITY                                            │
└─────────────────────────────────────────────────────────────────┘
  $INTERNET_STATUS
  $DNS_STATUS

┌─────────────────────────────────────────────────────────────────┐
│ DOCKER CONTAINERS                                               │
└─────────────────────────────────────────────────────────────────┘
$DOCKER_RUNNING

┌─────────────────────────────────────────────────────────────────┐
│ FAILED SERVICES                                                 │
└─────────────────────────────────────────────────────────────────┘
$FAILED_SERVICES

┌─────────────────────────────────────────────────────────────────┐
│ ALERTS & WARNINGS                                               │
└─────────────────────────────────────────────────────────────────┘
$(echo -e "$WARNINGS")

┌─────────────────────────────────────────────────────────────────┐
│ PIHOLE-FTL SERVICE STATUS                                       │
└─────────────────────────────────────────────────────────────────┘
$PIHOLE_FTL_STATUS

╔══════════════════════════════════════════════════════════════════╗
║ End of Report                                                   ║
╚══════════════════════════════════════════════════════════════════╝
"

# ==============================================================================
# SEND EMAIL
# ==============================================================================

echo "$REPORT" | msmtp "Email goes here"

# Log that report was sent
echo "[$DATE] Report sent successfully" >> /home/USER/pi-status-report.log

# Optional: Print to console if running manually
# echo "$REPORT"
