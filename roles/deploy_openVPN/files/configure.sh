#!/bin/bash
cd /etc/openvpn/easy-rsa/
source vars
./clean-all
./build-ca
./build-key-server $VPN_HOSTNAME
./build-dh
openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key
gzip -d /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz -c > /etc/openvpn/server.conf

sed -i "s/ca ca.crt/ca easy-rsa\/keys\/ca.crt/g" /etc/openvpn/server.conf
sed -i "s/cert server.crt/cert easy-rsa\/keys\/${VPN_HOSTNAME}.crt/g" /etc/openvpn/server.conf
sed -i "s/key server.key/key easy-rsa\/keys\/${VPN_HOSTNAME}.key/g" /etc/openvpn/server.conf
sed -i "s/dh dh2048.pem/dh easy-rsa\/keys\/dh2048.pem/g" /etc/openvpn/server.conf
sed -i "s/tls-auth ta.key/tls-auth easy-rsa\/keys\/ta.key/g" /etc/openvpn/server.conf

##
##
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE


echo >> /etc/openvpn/server.conf
echo "# Google Authenticator PAM configuration"
echo "plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn" >> /etc/openvpn/server.conf
echo "reneg-sec 0" >> /etc/openvpn/server.conf

mkdir /etc/openvpn/otp

echo 'auth required pam_google_authenticator.so secret=/etc/openvpn/otp/${USER}.google_authenticator user=root' >> /etc/pam.d/openvpn
echo 'account sufficient pam_permit.so' >> /etc/pam.d/openvpn
