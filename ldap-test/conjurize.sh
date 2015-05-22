#!/bin/sh
set -e

# Implementation note: 'tee' is used as a sudo-friendly 'cat' to populate a file with the contents provided below.

tee /etc/conjur.conf > /dev/null << CONJUR_CONF
account: joshops
appliance_url: https://ec2-52-6-6-244.compute-1.amazonaws.com/api
cert_file: /etc/conjur-joshops.pem
netrc_path: /etc/conjur.identity
plugins: []
CONJUR_CONF

tee /etc/conjur-joshops.pem > /dev/null << CONJUR_CERT
-----BEGIN CERTIFICATE-----
MIIDijCCAnKgAwIBAgIJAOYgUxqsKrSyMA0GCSqGSIb3DQEBBQUAMDExLzAtBgNV
BAMTJmVjMi01Mi02LTYtMjQ0LmNvbXB1dGUtMS5hbWF6b25hd3MuY29tMB4XDTE1
MDUxMjE3MzAwMVoXDTI1MDUwOTE3MzAwMVowMTEvMC0GA1UEAxMmZWMyLTUyLTYt
Ni0yNDQuY29tcHV0ZS0xLmFtYXpvbmF3cy5jb20wggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQCwJVFkEP/H2NOZcqElysqAqDuT6JM/m7YXSV2Md/JFFUsN
ckhJep9+KcsSV5m0LcT5vvoIuJgoTqdIsV5yO8AERlPhmXLaSYhAhl7Wl5C7XmmI
2+V0G8ybQLshwKdKKO3UnVekxyvsB/d2O0wzfU1HKYsjC+hBpaKldxZrqWa7wzeJ
7MdUuEP9S8EDpGpnv4qro+DRPkLV2bfocM5hy8xRN4Go+oqDoZgHeiYicvFbBkzR
3w2MFDfM57kHpiGuhgcQGTzLOIWJUcLUofyRao7qbOiSdc8q6cIPF7DndQUv+Sxm
OjBPrwGBaQ4/abbAKggxmaqIhtIgJLcG5iAc6nJvAgMBAAGjgaQwgaEwRAYDVR0R
BD0wO4IJbG9jYWxob3N0ggZjb25qdXKCJmVjMi01Mi02LTYtMjQ0LmNvbXB1dGUt
MS5hbWF6b25hd3MuY29tMB0GA1UdDgQWBBTBZbBeRO6fyJaCJicRCsO4DYBlIzAf
BgNVHSMEGDAWgBTBZbBeRO6fyJaCJicRCsO4DYBlIzAMBgNVHRMEBTADAQH/MAsG
A1UdDwQEAwIB5jANBgkqhkiG9w0BAQUFAAOCAQEAkKbJ2nc4MT0Mworv7BB3+7mL
xzXUTShhKcQ7cadKzRc/6kfvh5Cz8qIFmVFiCXwA6P85YEDMXjCrG0kMeoUA6MAn
joZqVNTaFF4TVNyn0FUjpnYUwxC18+N87Z1/DZOg0F/tBYJ0bpCCGB6fK6eN923Q
DZ3PJ+1kAEuzS7PnqBu5rZ/DmRlmdW1rJbIxX8DVrUaKPCzVIP1Mqb5z+uw9lyGB
TAaeEY+I563IxDQzp+94jm2cGenaye+jJFvb26c600UJghSQgEg85dU6yAFqH1Xp
or74EzX5DjV76VWjD0d9YYRjVRTWuLcoTV0uDSoCekjJj9Ch9b7LsWW+HtlNrQ==
-----END CERTIFICATE-----
CONJUR_CERT

tee /etc/conjur.identity > /dev/null << CONJUR_IDENTITY
machine https://ec2-52-6-6-244.compute-1.amazonaws.com/api/authn
  login host/development/ldap-1.0/tomcatserver2
  password 2pxng1t21vm09k7q7t4w294msz3x7wk0c3y9rckj14g4het2tkgk9b
CONJUR_IDENTITY
chmod 0600 /etc/conjur.identity
