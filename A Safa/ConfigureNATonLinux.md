echo 1 > /proc/sys/net/ipv4/ip_forward

sudo nano /etc/sysctl.conf

# net.ipv4.ip_forward=1

net.ipv4.ip_forward=1

sudo sysctl -p

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

sudo iptables-save > /etc/iptables/rules.v4

sudo service iptables save

sudo apt install iptables-persistent

ping google.com

sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.2:80
