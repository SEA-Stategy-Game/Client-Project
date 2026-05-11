# Core-Interface

---

## What Has Been Done

### Transport Layer
- ENet peer-to-peer connection established on **port 12345**
- Server supports up to **32 concurrent clients** but this can be changed
- Client connects via IP address (currently `127.0.0.1` for local, configurable for LAN/WAN)
- Connection lifecycle signals are handled: connected, failed, disconnected

### State Synchronisation
- **Static state** (units, objects, buildings) is sent once on client connect via a pull request
- Static state is **GZIP compressed** before sending to reduce packet size
- **Dynamic state** (currently only tick updates - we will work on this) is broadcast to all peers from the server on every simulation tick
- Delta compression is in place to only send what has changed

### RPC Architecture
- All RPC function signatures are **mirrored on both client and server** to satisfy Godot's checksum requirement
- Server-only functions are stubbed on the client and vice versa, with clear comments marking intent
- Reliable transport is used for critical state (static sync, events)
- Unreliable transport is used for high-frequency tick updates

### Serialisation
- Units, objects, and buildings are serialised into transmittable dictionaries
- All code is documented using Godot's `##` docstring format

---

## Handoff to Client Team

The following RPC interface is currently in use:

| Function | Transport | Direction | Description |
|---|---|---|---|
| `receive_state(state: Dictionary)` | Unreliable | Server → Client | Delta tick update |
| `receive_static_state(data: PackedByteArray)` | Reliable | Server → Client | Full compressed world state on connect |
| `on_static_state_requested()` | Reliable | Client → Server | Client requests full static state |

(OBS: "receive_state(state: Dictionary)" is not finished and only returns the current TICK)

The static state payload has the following structure after decompression:
```
json
{
	"objects": [
		{
			"amount": 3.0,
			"meta_values": {
				"entity_id": -1.0,
				"max_health": 100.0,
				"player_id": -1.0,
				"position": "(-34.0, -60.0)"
			},
			"resource_name": "ressource_stone"
		},
		{
			"amount": 1.0,
			"meta_values": {
				"entity_id": -1.0,
				"max_health": 100.0,
				"player_id": -1.0,
				"position": "(194.0, 132.0)"
			},
			"resource_name": "ressource_tree"
		}
	],
	"units": [
		{
			"attack_cooldown": 1.0,
			"attack_damage": 10.0,
			"current_health": 100.0,
			"meta_values": {
				"entity_id": -1.0,
				"max_health": 100.0,
				"player_id": 0.0,
				"position": "(-56.0, 55.0)"
			}
		}
	]
}
```
