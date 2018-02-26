#!/bin/bash

source /etc/openvpn/easy-rsa/vars
./build-key "{{ username }}"
google-authenticator --time-based --disallow-reuse --force --rate-limit=3 --rate-time=30 --window-size=3 -l "${KEY_NAME}" -s /etc/openvpn/otp/"{{ username }}".google_authenticator
./build-key "{{ username }}"
