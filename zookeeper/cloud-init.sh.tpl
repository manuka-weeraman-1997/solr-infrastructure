#!/bin/bash
echo "${myid}" > /var/lib/zookeeper/myid
cat >> /etc/zookeeper/conf/zoo.cfg <<'EOF'
${server_lines}
EOF
systemctl enable zookeeper
systemctl start zookeeper
