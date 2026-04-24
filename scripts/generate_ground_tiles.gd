@tool
extends EditorScript

# This script generates a simple grass ground layer for the tutorial village
# Tiles are 16x16, using grass tile at atlas position (1,10)

func _run():
	# Create a rectangular grass area
	# From tile coordinates (0,0) to (100,45) - covers 1600x720 pixels
	var tile_data = PackedByteArray()
	
	# Grass tile is at atlas position (1,10) = tile ID 1,10,0
	# Format: x_coord, y_coord, source_id, atlas_x, atlas_y, alternative_tile
	
	for y in range(0, 50):  # 50 tiles high (800 pixels)
		for x in range(0, 100):  # 100 tiles wide (1600 pixels)
			# Add tile at position (x, y) using grass tile (1,10)
			tile_data.append_array(_encode_tile(x, y, 0, 1, 10, 0))
	
	print("Generated tile data length: ", tile_data.size())
	print("Tile data (first 200 bytes): ", tile_data.slice(0, 200))
	print("\nCopy this to your GroundLayer tile_map_data:")
	print('tile_map_data = PackedByteArray("', tile_data.hex_encode(), '")')

func _encode_tile(x: int, y: int, source: int, atlas_x: int, atlas_y: int, alt: int) -> PackedByteArray:
	var data = PackedByteArray()
	# Godot's tile encoding format (simplified)
	# This is a basic encoding - actual format may vary
	data.append(x & 0xFF)
	data.append((x >> 8) & 0xFF)
	data.append(y & 0xFF)
	data.append((y >> 8) & 0xFF)
	data.append(source)
	data.append(atlas_x)
	data.append(atlas_y)
	data.append(alt)
	return data
