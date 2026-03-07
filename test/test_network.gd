# test_network_manager.gd
extends GutTest

const LobbyClient = preload("res://networking/lobby_client.gd")

	
	
func test_parseAvailableRooms() -> void:
	var lc = LobbyClient.new()
	var data = [{"roomId": "123", "capacity": 10, "players": 5}]
	
	var parsed = lc._parseAvailableRooms(JSON.stringify(data))
	var expected = lc.RoomInfo.new("123", 10, 5).to_dict()
	assert_eq(parsed.map(func(r): return r.to_dict()), [expected])
	
	
	
