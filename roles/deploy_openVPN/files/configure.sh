#!/bin/bash
cd /etc/openvpn/easy-rsa/
source /etc/openvpn/easy-rsa/vars
cd /etc/openvpn/easy-rsa/ && ./clean-all
cd /etc/openvpn/easy-rsa/ && ./build-ca
cd /etc/openvpn/easy-rsa/ && ./build-key-server $VPN_HOSTNAME
cd /etc/openvpn/easy-rsa/ && ./build-dh

pwd

openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key
gzip -d /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz -c > /etc/openvpn/server.conf

sed -i "s/ca ca.crt/ca easy-rsa\/keys\/ca.crt/g" /etc/openvpn/server.conf
sed -i "s/cert server.crt/cert easy-rsa\/keys\/${VPN_HOSTNAME}.crt/g" /etc/openvpn/server.conf
sed -i "s/key server.key/key easy-rsa\/keys\/${VPN_HOSTNAME}.key/g" /etc/openvpn/server.conf
sed -i "s/dh dh2048.pem/dh easy-rsa\/keys\/dh2048.pem/g" /etc/openvpn/server.conf
sed -i "s/tls-auth ta.key/tls-auth easy-rsa\/keys\/ta.key/g" /etc/openvpn/server.conf

##
echo >> /etc/openvpn/server.conf
echo '# Routing' >> /etc/openvpn/server.conf
echo 'push "route 10.0.1.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.2.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.3.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.4.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.5.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.6.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.7.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'push "route 10.0.8.0 255.255.255.192"' >> /etc/openvpn/server.conf
echo 'status /var/log/openvpn-status.log'    >> /etc/openvpn/server.conf
echo 'log /var/log/openvpn.log'              >> /etc/openvpn/server.conf

##
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -s 10.8.0.0/8 -o ens3 -j MASQUERADE

echo >> /etc/openvpn/server.conf
echo "# Google Authenticator PAM configuration"
echo "plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn" >> /etc/openvpn/server.conf
echo "reneg-sec 0" >> /etc/openvpn/server.conf

mkdir /etc/openvpn/otp

echo 'auth required pam_google_authenticator.so secret=/etc/openvpn/otp/${USER}.google_authenticator user=root' >> /etc/pam.d/openvpn
echo 'account sufficient pam_permit.so' >> /etc/pam.d/openvpn
