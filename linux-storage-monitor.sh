cd ~/linux-storage-monitor
cat > bin/storage_menu.sh << 'EOF'
#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR" || exit 1
source config/monitor.conf

pause() { echo; read -rp "Press Enter to return to the menu..." _; }

show_menu() {
    clear
    echo "=========================================================="
    echo "          LINUX STORAGE MONITORING SYSTEM"
    echo "        with Automatic LVM Volume Extension"
    echo "=========================================================="
    echo
    echo "  --- Storage Monitoring ---"
    echo "  1. Check disk usage"
    echo "  2. Check inode usage"
    echo "  3. Record storage growth and view history"
    echo "  4. Check current alert status"
    echo "  5. View monitoring logs"
    echo "  6. View administrator alerts"
    echo "  7. Generate and view storage report"
    echo
    echo "  --- LVM Capacity Management ---"
    echo "  8. Show LVM layers and volume status"
    echo "  9. Run automatic volume extension now"
    echo " 10. View extension history"
    echo
    echo "  --- Testing, Backup and Security ---"
    echo " 11. Run alert test (simulation)"
    echo " 12. Run backup now and verify it"
    echo " 13. Check scheduled jobs (cron)"
    echo " 14. Check firewall and SSH"
    echo " 15. Exit"
    echo
}

while true; do
    show_menu
    read -rp "Enter your choice [1-15]: " choice
    echo
    case "$choice" in
        1)  bash bin/disk_monitor.sh ;;
        2)  bash bin/inode_monitor.sh ;;
        3)  bash bin/storage_growth.sh
            echo "----- Last 5 history records -----"
            tail -n 5 data/storage_history.csv ;;
        4)  bash bin/alert_monitor.sh ;;
        5)  echo "----- Disk monitoring log (last 10) -----"
            tail -n 10 logs/storage_monitor.log 2>/dev/null || echo "No disk log yet."
            echo
            echo "----- Inode monitoring log (last 10) -----"
            tail -n 10 logs/inode_monitor.log 2>/dev/null || echo "No inode log yet." ;;
        6)  echo "----- Administrator alerts (last 10) -----"
            tail -n 10 logs/administrator_alerts.log 2>/dev/null || echo "No alerts recorded." ;;
        7)  bash bin/generate_report.sh
            echo
            cat reports/storage_report.txt ;;
        8)  if ! mountpoint -q "$LVM_MOUNT"; then
                echo "LVM volume is not mounted. Run: bash bin/lvm_attach.sh"
            else
                echo "----- Physical volume -----"
                sudo pvs
                echo
                echo "----- Volume group -----"
                sudo vgs
                echo
                echo "----- Logical volume -----"
                sudo lvs
                echo
                echo "----- Mounted filesystem -----"
                df -hT "$LVM_MOUNT"
                echo
                echo "Critical limit: ${LVM_CRITICAL}%   Extension step: ${LVM_EXTEND_MB} MB"
            fi ;;
        9)  bash bin/lvm_autoextend.sh ;;
        10) echo "----- Extension history (last 10) -----"
            tail -n 10 logs/lvm_autoextend.log 2>/dev/null || echo "No extension history yet."
            echo
            echo "----- Extension alerts -----"
            grep "LVM" logs/administrator_alerts.log 2>/dev/null | tail -n 5 || echo "None." ;;
        11) bash tests/test_alerts.sh
            echo
            echo "----- Latest alerts -----"
            tail -n 5 logs/administrator_alerts.log ;;
        12) bash bin/backup.sh
            ls -lh backup/project_backup.tar.gz
            echo "----- Archive contents (first 20) -----"
            tar -tzf backup/project_backup.tar.gz | head -n 20 ;;
        13) echo "Cron service: $(systemctl is-active cron)"
            echo
            echo "----- Scheduled jobs -----"
            crontab -l 2>/dev/null || echo "No cron jobs found." ;;
        14) echo "----- Firewall (ufw) -----"
            sudo ufw status verbose
            echo
            echo "----- SSH service -----"
            systemctl status ssh --no-pager 2>&1 | head -n 5 ;;
        15) echo "Exiting Linux Storage Monitoring System. Goodbye!"
            exit 0 ;;
        *)  echo "ERROR: Invalid choice. Enter a number from 1 to 15." ;;
    esac
    pause
done
EOF
chmod +x bin/storage_menu.sh
