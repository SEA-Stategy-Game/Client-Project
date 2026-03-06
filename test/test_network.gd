# test_network_manager.gd
extends GutTest

func test_getAvailableRooms() -> void:
	var lc = preload("res://networking/client.gd")
	var client = lc.LobbyClient.new()
	
	var rooms = client.getAvailableRooms()
	
	assert_eq(rooms, [])
	
	
	
