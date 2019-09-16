extends Spatial
class_name Chunk

export var TERRAIN_HEIGHT = 48
export var TERRAIN_VERT = .25
export var COLLIS = true
export var WATER_LEVEL = -16
export var ITEMS_AMOUNT = 3
export var SHROOMS_CHANCE = 0.005
export var SHROOMS_ELEVATION = 1

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
	
func _ready():
	generate_chunk()
	generate_water_layer()
	
func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * TERRAIN_VERT
	plane_mesh.subdivide_width = chunk_size * TERRAIN_VERT
	plane_mesh.material = preload("res://vendors/p1x/infinite_terrain/terrain.material")
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	var pool_array = PoolVector3Array()
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * TERRAIN_HEIGHT
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
	generate_vegetation(pool_array)
	generate_coins(pool_array)
	
func generate_vegetation(pool):
	var models = [
		preload("res://models/shroom/shroom.tscn"),
		preload("res://models/forest/tree1.tscn"),
		preload("res://models/forest/tree2.tscn"),
		preload("res://models/forest/tree3.tscn")
	]
	
	for i in range(ITEMS_AMOUNT):
		var random_model_id = randi() % models.size();
		var object = models[random_model_id].instance()
		
		var pos = pool[randi() % pool.size()]
		var ran = 0.5 + randf()
		var sca = Vector3(ran,ran,ran)
		
		var body_node = "body"
		if random_model_id == 0:
			var types = ['type1', 'type2', 'type3']
			types.shuffle()
			body_node = types[0]
		var model_node = object.get_node(body_node)
		model_node.show()
		model_node.transform = model_node.transform.scaled(sca)
			
		object.translate(pos)
		add_child(object)
		
func generate_coins(pool):
	var coin_base = preload("res://models/coin/coin.tscn")

	for i in range(ITEMS_AMOUNT):
		var pos = pool[randi() % pool.size()]
		var object = coin_base.instance()
		object.translate(pos)
		add_child(object)
	
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

