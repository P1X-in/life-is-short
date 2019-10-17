extends Spatial
class_name Chunk

export var TERRAIN_HEIGHT = 32
export var TERRAIN_VERT = .08
export var COLLIS = true
export var WATER_LEVEL = -16
export var CLOUDS_LEVEL = 64
export var ITEMS_AMOUNT = 16
export var ENEMIES_AMOUNT = 4

var models = [
	preload("res://models/shroom/shroom.tscn"), #0
	preload("res://models/arcade.tscn"),  #1
	
	preload("res://models/forest/tree3.tscn"), #2
	preload("res://models/forest/tree4.tscn"),
	preload("res://models/forest/tree5.tscn"),
	preload("res://models/forest/tree6.tscn"),
	
	preload("res://models/forest/bush1.tscn"), #6
	preload("res://models/forest/bush2.tscn"),
	preload("res://models/forest/bush3.tscn"),
	
	preload("res://models/blockers/antitank.tscn"), #9
	preload("res://models/blockers/antitank_multi.tscn"),
]

var active_terrain = 0
const TERRAIN_1_DIST = 6
const TERRAIN_2_DIST = 12
var terrains = [
	[
		-1,-1,-1,-1,	# no mans land
		-1,-1,-1,-1,	# no mans land
		-1,-1,-1,-1,	# no mans land
		0,				# shrooms
		6,6,7,7,8,8,	# bushes
		6,6,7,7,8,8,	# bushes
		9,9,10,10			# antitank
	],
	[
		-1,-1,-1,-1,		# no mans land
		-1,-1,-1,-1,		# no mans land
		0,					# shrooms
		2,3,4,5,			# trees
		6,6,6,7,7,7,8,8,8,	# bushes
		9,9,10,				# antitank
	],
	[
		-1,-1,-1,-1,		# no mans land
		0,0,0,				# shrooms
		1,					# arcade
		2,2,3,3,4,4,5,5,	# trees
		6,6,7,7,8,8,		# bushes
		9,10,				# antitank
	],
]

var dust = preload("res://scenes/small/dust.tscn")

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = false

func _init(noise, x, z, chunk_size):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	self.select_active_terrain()

func select_active_terrain():
	var dist = abs(x) + abs(z)
	if  dist > TERRAIN_2_DIST * chunk_size:
		self.active_terrain = 2
	elif dist > TERRAIN_1_DIST * chunk_size:
		self.active_terrain = 1
	else:
		self.active_terrain = 0

func _ready():
	seed("paradise".hash())
	#randomize()
	generate_chunk()
	generate_water_layer()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	var chunk_size_scaled = chunk_size * TERRAIN_VERT

	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size_scaled
	plane_mesh.subdivide_width = chunk_size_scaled

	plane_mesh.material = preload("res://vendors/p1x/infinite_terrain/terrain2.material")
	#plane_mesh.material.set_shader_param(
	#	"HEIGHTMAP_SIZE",
	#	Vector2(chunk_size, chunk_size))

	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	var pool_array = PoolVector3Array()

	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var noise_3d = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z)

		vertex.y = noise_3d * TERRAIN_HEIGHT
		data_tool.set_vertex(i, vertex)
		pool_array.append(vertex)

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	if COLLIS:
		mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

	add_child(mesh_instance)
	
	generate_coins(spawn_enemy(generate_vegetation(pool_array)))

func generate_vegetation(pool):
	for i in range(ITEMS_AMOUNT):
		var random_pool_id = randi() % pool.size()
		var random_model_id = terrains[active_terrain][(randi() % terrains[active_terrain].size())-1];
		if random_model_id >= 0:
			var object = models[random_model_id].instance()
			var dust_instance = dust.instance()
			
			
			var pos = pool[random_pool_id]
			var ran = 0.8 + randf()
			var sca = Vector3(ran,ran,ran)
	
			var body_node = "body"
			if random_model_id == 0:
				var types = [
				'Mushroom1', 'Mushroom2', 'Mushroom3', 'Mushroom4', 'Mushroom5',
				'Mushroom6', 'Mushroom7', 'Mushroom8', 'Mushroom9', 'Mushroom10']
				types.shuffle()
				body_node = types[0]
			var model_node = object.get_node(body_node)
			model_node.show()
			
			if random_model_id == 1:
				model_node.rotate_y(randf() * 360)
			if not random_model_id == 1:
				model_node.transform = model_node.transform.scaled(sca)
	
			object.translate(pos)
			add_child(object)
			
			dust_instance.translate(Vector3(0,WATER_LEVEL,0))
			add_child(dust_instance)
		pool.remove(random_pool_id)
	return pool

func generate_coins(pool):
	var coin_base = preload("res://models/coin/coin.tscn")

	for i in range(ITEMS_AMOUNT):
		var random_pool_id = randi() % pool.size()
		var pos = pool[random_pool_id]
		var object = coin_base.instance()
		object.translate(pos)
		add_child(object)
		pool.remove(random_pool_id)
	return pool

func spawn_enemy(pool):
	#var amiga_base = preload("res://models/amiga/amiga.tscn")
	var underwater_bomb_base = preload("res://models/bombs/underwater_mine.tscn")

	for i in range(ENEMIES_AMOUNT):
		var random_pool_id = randi() % pool.size()
		var pos = pool[random_pool_id]
		var object = underwater_bomb_base.instance()
		object.translate(pos)
		object.rotate_x(randf()*360.0)
		object.rotate_y(randf()*360.0)
		object.rotate_z(randf()*360.0)
		add_child(object)
		pool.remove(random_pool_id)
	return pool
		
func generate_water_layer():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * TERRAIN_VERT
	plane_mesh.subdivide_width = chunk_size * TERRAIN_VERT
	plane_mesh.material = preload("res://vendors/p1x/infinite_terrain/water.material")

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	mesh_instance.translate(Vector3(0,WATER_LEVEL,0))
	if COLLIS:
		mesh_instance.create_trimesh_collision()

	add_child(mesh_instance)

func generate_clouds_layer():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.material = preload("res://vendors/p1x/clouds/clouds.material")

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	mesh_instance.translate(Vector3(0,CLOUDS_LEVEL,0))

	add_child(mesh_instance)
