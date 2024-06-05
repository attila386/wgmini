/interface bridge
add comment="All ports are bridged by this bridge." name=bridge1
/interface ethernet
set [ find default-name=ether2 ] comment=\
    "The one and only iface to connect to LAN."
/interface wireguard
add comment="WG interface. DNAT to this port on external router." \
    listen-port=51821 mtu=1420 name=wireguard1
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/routing bgp template
set default disabled=no output.network=bgp-networks
/routing ospf instance
add disabled=no name=default-v2
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
/interface bridge port
add bridge=bridge1 interface=all
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface ovpn-server server
set auth=sha1,md5
/interface wireguard peers
add allowed-address=172.16.0.2/32 comment="WG peer #1" interface=wireguard1 \
    public-key=""
/ip address
add address=192.168.10.9/24 comment="Manually assigned IP to bridge from LAN s\
    ubnet. DNAT to this IP on the external router." interface=bridge1 \
    network=192.168.10.0
add address=172.16.0.1/24 comment="Address from interconnecting subnet." \
    interface=wireguard1 network=172.16.0.0
/ip firewall nat
add action=masquerade chain=srcnat comment="SNAT traffic from WGs interconnect\
    ing subnet to LAN subnet, replace with IP address of the bridge." \
    dst-address=192.168.10.0/24 log=yes src-address=172.16.0.0/24
/ip route
add comment="Default gateway." disabled=no distance=1 dst-address=0.0.0.0/0 \
    gateway=192.168.10.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bfd configuration
add disabled=no interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/system identity
set name=WireguardSrv
/system note
set show-at-login=no
