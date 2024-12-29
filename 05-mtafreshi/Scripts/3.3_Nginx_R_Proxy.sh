#!/bin/bash

check_root ()
{
    if [ `whoami` == "root" ]; then
        echo "you are login with Root User"
    else
        echo "Please Login "root" User and Run Script Agein." 
        exit 1
    fi
}

nginx_reverse ()
{
    sudo apt update
    sudo apt install nginx iptables-persistent -y
    systemctl start nginx
    systemctl enable nginx
    sleep 5
}

config_proxy ()
{
    path=/etc/nginx/sites-available/reverse-proxy
    file=./host_config
    tail -n 2 ${file} > ngtemp 
    head -n 1 ngtemp | awk '{print $1}' > ng
    head -n 1 ${file} | awk '{print $1}' > web
    unlink /etc/nginx/sites-enabled/default
    echo "server {" > ${path}
    echo "    listen 80;" >> ${path}
    echo "    server_name _;" >> ${path}
    echo "    access_log /var/log/reverse-access.log;" >> ${path}
    echo "    error_log /var/log/reverse-error.log;" >> ${path}
    echo "" >> ${path}
    echo "    location / {" >> ${path}
    echo "        proxy_pass http://`cat web`/;" >> ${path}
    echo "    }" >> ${path}
    echo "}" >> ${path}
    cat ${path}
    sleep 5
    ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
    nginx -t
    systemctl restart nginx
    echo "Configuration Completed. "
}

iptable ()
{
    iptables -A INPUT -d `cat ng` -p TCP --dport 22 -j ACCEPT
    iptables -A INPUT -d `cat ng` -p TCP --sport 22 -j ACCEPT
    iptables -A INPUT -s `cat web` -d `cat ng` -p TCP --sport 80 -j ACCEPT
    iptables -A INPUT -d `cat ng` -p TCP --dport 80 -j ACCEPT
    iptables -A OUTPUT -s `cat ng` -p TCP --sport 22 -j ACCEPT
    iptables -A OUTPUT -s `cat ng` -p TCP --dport 22 -j ACCEPT
    iptables -A OUTPUT -s `cat ng` -d `cat web` -p TCP --dport 80 -j ACCEPT
    iptables -A OUTPUT -s `cat ng` -p TCP --sport 80 -j ACCEPT
    iptables -nvL
    sleep 5
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -nvL
    sleep 5
    iptables-save > /etc/iptables/rules.v4
}

check_nginx ()
{
    systemctl restart nginx
    if [ `echo $?` == 0 ]; then
        echo "Nginx Server is Already Installed. "
        read -p "Do you want to configure Server to Reverse_Proxy? (y/n) " answer
        if [ ${answer} == y ]; then
            config_proxy
        else
            echo "Good Lock!~ ."
        fi
    else
        nginx_reverse
        config_proxy
    fi
}

main ()
{
    check_root
    check_nginx
    iptable
}
main