>Interfaces

Reticulum supports using many kinds of devices as networking interfaces, and allows you to mix and match them in any way you choose.

The number of distinct network topologies you can create with Reticulum is more or less endless, but common to them all is that you will need to define one or more interfaces for Reticulum to use.

The `![ Interfaces ]`! section of NomadNet lets you add, monitor, and update interfaces configured for your Reticulum instance.

If you are starting NomadNet for the first time you will find that an `!AutoInterface`! has been added by default. This interface will try to use your available network device to communicate with other peers discovered on your local network.

Interfaces come in many different types and can interact with physical mediums like LoRa radios or standard IP networks.

>>Viewing Interfaces

To view more info about an interface, navigate using the `!Up`! and `!Down`! arrow keys or by clicking with the mouse. Pressing `! < Enter >`! on a selected interface will bring you to a detailed interface view, which will show configuration parameters and realtime charts. From here you can also disable or edit the interface. To change the orientation of the TX/RX charts, press `!< V >`! for a vertical layout, and `!< H >`! for a horizontal view.

>>Updating Interfaces

To edit an interface, select the interface and press `!< Ctrl + E >`!.

To remove an interface, select the interface and press `!< Ctrl + X >`!. You can also perform both of these actions  from the details view.

>>Adding Interfaces

To add a new interface, press `!< Ctrl + A >`!. From here you can select which type of interface you want to add. Each unique interface type will have different configuration options.

`Ffff`! (!) Note:`! After adding or modifying interfaces, you will need to restart NomadNet or your Reticulum instance for changes to take effect.`f`b


>Interface Profiles

Interface profiles let you save different combinations of enabled interfaces and switch between them quickly. For example, you might keep a `!Home`! profile that uses a local AutoInterface, and a `!Travel`! profile that reaches out over a TCP gateway instead.

Press `!< Tab >`! from the `![ Interfaces ]`! section to move between the `!Interfaces`! and `!Profiles`! tabs.

To save your current set of enabled interfaces as a new profile, press `!< Ctrl + S >`!. To assign an interface to one or more profiles, edit it with `!< Ctrl + E >`! and use the profile checkboxes in the edit form. You can also toggle the selected interface on or off directly with `!< Ctrl + O >`!, and filter the list by All, Enabled or Disabled with `!< Ctrl + F >`!.

`Ffff`! (!) Note:`! Switching profiles changes which interfaces are enabled, so a restart of NomadNet or your Reticulum instance is required for the change to take effect.`f`b


>Interface Types

Jump to a specific interface type:

 `F79d`_`[AutoInterface`#autointerface]`_`f
 `F79d`_`[TCPClientInterface`#tcpclientinterface]`_`f
 `F79d`_`[TCPServerInterface`#tcpserverinterface]`_`f
 `F79d`_`[UDPInterface`#udpinterface]`_`f
 `F79d`_`[I2PInterface`#i2pinterface]`_`f
 `F79d`_`[RNodeInterface`#rnodeinterface]`_`f
 `F79d`_`[RNodeMultiInterface`#rnodemultiinterface]`_`f
 `F79d`_`[SerialInterface`#serialinterface]`_`f
 `F79d`_`[KISSInterface`#kissinterface]`_`f
 `F79d`_`[PipeInterface`#pipeinterface]`_`f

>>AutoInterface

The Auto Interface enables communication with other discoverable Reticulum nodes over autoconfigured IPv6 and UDP. It does not need any functional IP infrastructure like routers or DHCP servers, but will require at least some sort of switching medium between peers (a wired switch, a hub, a WiFi access point or similar).

```
Required Parameters:
Interface Name

Optional Parameters:
Devices: Specific network devices to use
Ignored Devices: Network devices to exclude
Group ID: Create isolated networks on the same physical LAN
Discovery Scope: Can set to link, admin, site, organisation or global
```

The AutoInterface is ideal for quickly connecting to other Reticulum nodes on your local network without complex configuration.

>>TCPClientInterface

The TCP Client interface connects to remote TCP server interfaces, enabling communication over the Internet or private networks.

```
Required Parameters:
Target Host: Hostname or IP address of the server
Target Port: Port number to connect to

Optional Parameters:
I2P Tunneled: Enable for connecting through I2P
KISS Framing: Enable for KISS framing for software modems
```

This interface is commonly used to connect to Reticulum gateways or other persistent nodes on the Internet.

>>TCPServerInterface

The TCP Server interface listens for incoming connections, allowing other Reticulum peers to connect to your node using TCPClientInterface.

```
Required Parameters:
Listen IP: IP address to bind to (0.0.0.0 for all interfaces)
Listen Port: Port number to listen on

Optional Parameters:
Prefer IPv6: Bind to IPv6 address if available
I2P Tunneled: Enable for I2P tunnel support
Device: Specific network device to use (e,g
```

Useful when you want other nodes to be able to connect to your Transport instance over TCP/IP.

>>UDPInterface

The UDP interface allows communication over IP networks using UDP packets.

```
Required Parameters:
Listen IP: IP address to bind to
Listen Port: Port to listen on
Forward IP: IP address to forward to (Can be broadcast address)
Forward Port: Port to forward to

Optional Parameters:
Device: Specific network device to use
```

>>I2PInterface

The I2P interface enables connections over the Invisible Internet Protocol. The I2PInterface requires an I2P daemon to be running on your system, such as `!i2pd`!

```
Optional Parameters:
Peers: I2P addresses to connect to (Can be left as none if running as a Transport)
```


>>RNodeInterface

The RNode interface allows using LoRa transceivers running RNode firmware as Reticulum network interfaces.

```
Required Parameters:
Port: Serial port or BLE device path
Frequency: Operating frequency in MHz
Bandwidth: Channel bandwidth
TX Power: Transmit power in dBm
Spreading Factor: LoRa spreading factor (7-12)
Coding Rate: LoRa coding rate (4:5-4:8)

Optional Parameters:
ID Callsign: Station identification
ID Interval: Identification interval in seconds
Airtime Limits: Control duty cycle
```

The interface includes a parameter calculator to estimate link budget, sensitivity, and data rate on the air based on your settings.

>>RNodeMultiInterface

The RNode Multi Interface is designed for use with specific hardware platforms that support multiple subinterfaces or virtual radios. For most LoRa hardware platforms, you will want to use the standard `!RNodeInterface`! instead.

```
Required Parameters:
Port: Serial port or BLE device path
Subinterfaces: Configuration for each subinterface / virtual radio port

```

>>SerialInterface

The Serial interface enables using direct serial connections as Reticulum interfaces.

```
Required Parameters:
Port: Serial port path
Speed: Baud rate of serial device
Databits: Number of data bits
Parity: Parity setting
Stopbits: Number of stop bits
```

>>KISSInterface

The KISS interface supports packet radio modems and TNCs using the KISS protocol.

```
Required Parameters:

Port: Serial port path
Speed: Baud rate of serial device
Databits: Number of data bits
Parity: Parity setting
Stopbits: Number of stop bits
Preamble: Modem preamble in milliseconds
TX Tail: Transmit tail in milliseconds
Slottime: CSMA slottime in milliseconds
Persistence: CSMA persistence value

Optional Parameters:

ID Callsign: Station identification
ID Interval: Identification interval in seconds
Flow Control: Enable packet flow control
```

>>PipeInterface

The Pipe interface allows using external programs as Reticulum interfaces via stdin and stdout.

```
Required Parameters:

Command: External command to execute

Optional Parameters:
Respawn Delay: Seconds to wait before restarting after failure
```

<
>>
-∿
  For more information and to view the full Interface documentation consult the Reticulum   manual or visit  https://reticulum.network/manual/interfaces.html (Requires external Internet connection)


>Interface Access Code (IFAC) Settings

Interface Access Codes create private networks and securely segment network traffic. Under `!Show more options`!, you'll find these IFAC settings:

`!Virtual Network Name`! (network_name):
When added, creates a logical network that only communicates with other interfaces using the same name. This allows multiple separate Reticulum networks to exist on the same physical channel or medium.

`!IFAC Passphrase`! (passphrase):
Sets an authentication passphrase for the interface. Only interfaces configured with the same passphrase will be able to communicate. Can be used with or without a network name.

`!IFAC Size`! (ifac_size):
Controls the length of Interface Authentication Codes (8-512 bits). Larger sizes provide stronger security but add overhead to each packet. The default of `!8`! is usually appropriate for most uses.

>Interface Modes

When running a Transport node, you can configure interface modes that affect how Reticulum selects paths, propagates announces, and discovers routes:

`!full`!: Default mode with all discovery, meshing and transport functionality
`!gateway`!: Discovers paths on behalf of other nodes
`!access_point`!: Operates as a network access point
`!roaming`!: For physically mobile interfaces
`!boundary`!: For interfaces connecting different network segments

