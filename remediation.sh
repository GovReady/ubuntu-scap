#!/bin/bash

# Some tests can be fixed by removing packages that violate the rules.
# These packages are not depended on by other packages in a default
# Ubuntu server installation and so I think are safe to remove. The
# test names that they caused to fail are given in the comments.

apt-get purge libtirpc1 # xccdf_org.ssgproject.content_rule_network_ipv6_disable_rpc
apt-get purge uuid-runtime # xccdf_org.ssgproject.content_rule_file_ownership_binary_dirs
apt-get purge at # xccdf_org.ssgproject.content_rule_file_ownership_binary_dirs

# Disable various kernel modules that cause the following tests to fail:
# xccdf_org.ssgproject.content_rule_kernel_module_cramfs_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_freevxfs_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_jffs2_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_hfs_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_hfsplus_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_squashfs_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_udf_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_bluetooth_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_dccp_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_sctp_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_rds_disabled
# xccdf_org.ssgproject.content_rule_kernel_module_tipc_disabled
cat <<EOF > /etc/modprobe.d/ubuntu_scap.conf;
install cramfs /bin/false
install freevxfs /bin/false
install jffs2 /bin/false
install hfs /bin/false
install hfsplus /bin/false
install squashfs /bin/false
install udf /bin/false
install net-pf-31 /bin/false
install bluetooth /bin/false
install dccp /bin/false
install sctp /bin/false
install rds /bin/false
install tipc /bin/false
EOF

function set_sysctl {
	sysctl -q -n -w $1=$2
	if grep --silent ^$1 /etc/sysctl.conf ; then
		sed -i 's/^$1.*/$1 = $2/g' /etc/sysctl.conf
	else
		echo "" >> /etc/sysctl.conf
		echo "$1 = $2" >> /etc/sysctl.conf
	fi
}

# Disable Core Dumps for All Users / for SUID programs
# xccdf_org.ssgproject.content_rule_disable_users_coredumps
if ! grep -q "*     hard   core    0" /etc/security/limits.conf; then
	echo "*     hard   core    0" >> /etc/security/limits.conf
fi
# xccdf_org.ssgproject.content_rule_sysctl_fs_suid_dumpable
set_sysctl fs.suid_dumpable 0

# Enable Randomized Layout of Virtual Address Space
# This seems to be the default, but the test fails if it's not explicit in the config.
set_sysctl kernel.randomize_va_space 2

# Set Password Minimum Age
# xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs
var_accounts_minimum_age_login_defs="1"
grep -q ^PASS_MIN_DAYS /etc/login.defs && \
  sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS     $var_accounts_minimum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MIN_DAYS      $var_accounts_minimum_age_login_defs" >> /etc/login.defs
fi

# Set Password Maximum Age
# xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs
var_accounts_maximum_age_login_defs="60"
grep -q ^PASS_MAX_DAYS /etc/login.defs && \
  sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $var_accounts_maximum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MAX_DAYS      $var_accounts_maximum_age_login_defs" >> /etc/login.defs
fi

# Ensure the Default Umask is Set Correctly in login.defs
# xccdf_org.ssgproject.content_rule_accounts_umask_login_defs
var_accounts_user_umask="077"
grep -q UMASK /etc/login.defs && \
  sed -i "s/UMASK.*/UMASK $var_accounts_user_umask/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "UMASK $var_accounts_user_umask" >> /etc/login.defs
fi

# Disable Kernel Parameter for Sending ICMP Redirects by Default / for All Interfaces
# Disable Kernel Parameter for Accepting ICMP Redirects by Default / for All Interfaces
# Disable Kernel Parameter for Accepting Secure Redirects by Default / for All Interfaces
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_send_redirects
# xccdf_org.ssgproject.content_rule_sysctl_ipv4_all_send_redirects
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_accept_redirects
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_accept_redirects
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_secure_redirects
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_secure_redirects
set_sysctl net.ipv4.conf.default.send_redirects 0
set_sysctl net.ipv4.conf.all.send_redirects 0
set_sysctl net.ipv4.conf.all.accept_redirects 0
set_sysctl net.ipv4.conf.all.secure_redirects 0
set_sysctl net.ipv4.conf.default.secure_redirects 0
set_sysctl net.ipv4.conf.default.accept_redirects 0

# Disable Kernel Parameter for IP Forwarding
# xccdf_org.ssgproject.content_rule_sysctl_ipv4_ip_forward
set_sysctl net.ipv4.ip_forward 0

# Disable Kernel Parameter for Accepting Source-Routed Packets for All Interfaces
# Disable Kernel Parameter for Accepting Source-Routed Packets By Default
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_accept_source_route
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_accept_source_route
set_sysctl net.ipv4.conf.all.accept_source_route 0
set_sysctl net.ipv4.conf.default.accept_source_route 0

# Enable Kernel Parameter to Log Martian Packets
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_log_martians
set_sysctl net.ipv4.conf.all.log_martians 1

# Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests
# Enable Kernel Parameter to Ignore Bogus ICMP Error Responses
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_icmp_echo_ignore_broadcasts
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_icmp_ignore_bogus_error_responses
set_sysctl net.ipv4.icmp_echo_ignore_broadcasts 1
set_sysctl net.ipv4.icmp_ignore_bogus_error_responses 1

# Enable Kernel Parameter to Use TCP Syncookies
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_tcp_syncookies
set_sysctl net.ipv4.tcp_syncookies 1

# Enable Kernel Parameter to Use Reverse Path Filtering by Default / for All Interfaces
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_rp_filter
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_rp_filter
set_sysctl net.ipv4.conf.default.rp_filter 1
set_sysctl net.ipv4.conf.all.rp_filter 1

# Disable Accepting IPv6 Router Advertisements
# xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_default_accept_ra
set_sysctl net.ipv6.conf.default.accept_ra 0

# Disable Accepting IPv6 Redirects
# xccdf_org.ssgproject.content_rule_sysctl_ipv6_default_accept_redirects
set_sysctl net.ipv6.conf.default.accept_redirects 0
