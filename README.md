
Mini Wireguard Server

The configuration below turns a small Mikrotik router e.g. an RB951Ui-2nD hAP
into a cheap, easy to deploy, low power Wireguard server. I think it could be
useful in some scenarios, where no other options are available, e.g. the actual
router is not wireguard or other VPN capable, and you do not want to replace it
for some reason.

Apply this config to a small Mikrotik router, connect it to your actual router
with just one cable and you are good to go.

I refer to this new router as "server" or "Wireguard server" in the text.


How it works:

The Wireguard server receives traffic through your original router.
It forwards this traffic to destinations on your LAN. It masquerades this
traffic, so you do not have to configure anything on your LAN hosts.
Your LAN hosts will be unaware that they coversate with distant hosts.

To make things work, you have to create a port forward rule (or destination NAT)
on your existing router, and prepare a few other things:

- Prepare a client config on your client machine or at least generate
private and public keys. You will need the client's public key soon.

- Select a port for Wireguard to communicate. In this config I preset
the default wireguard port, 51821.

- You have to preselect an IP subnet for wireguard for communications that
differs from your LAN subnets on either end. I chose 172.16.0.0/24.
Feel free to change it according to your needs.

- Pick an IP address from the communications subnet for your Wireguard server.
172.16.0.1/24 should be a good choice. Select the next available address
for your first peer (client), in our example it is 172.16.0.2/24.

- Select a valid IP address on your LAN for your Wireguard server. In this
configuration our LAN subnet is 192.168.10.0/24 and the chosen IP address
is 192.168.10.9/24.

Please spot these sections and modify them or leave them as they are :

----

/interface wireguard
add comment="WG interface. DNAT to this port on external router." \
    listen-port=51821 mtu=1420 name=wireguard1

Subject of interest : listen-port

---- 

/ip address
add address=172.16.0.1/24 comment="Address from interconnecting subnet." \
    interface=wireguard1 network=172.16.0.0

Subject of interest : address, network

----

/interface wireguard peer
add allowed-address=172.16.0.2/32 comment="WG peer #1" interface=wireguard1 \
   public-key=""

Subject of interest : public-key

----

/ip address
add address=192.168.10.9/24 comment="Manually assigned IP to bridge from LAN s\
    ubnet. DNAT to this IP on the external router." interface=bridge1 \
    network=192.168.10.0

Subject of interest : address, network

----

/ip firewall nat
add action=masquerade chain=srcnat comment="SNAT traffic from WGs interconnect\
    ing subnet to LAN subnet, replace with IP address of the bridge." \
    dst-address=192.168.10.0/24 log=yes src-address=172.16.0.0/24

Subject of interest : dst-address, src-address

----

/ip route
add comment="Default gateway." disabled=no distance=1 dst-address=0.0.0.0/0 \
    gateway=192.168.10.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10

Subject of interest : gateway

EOF
