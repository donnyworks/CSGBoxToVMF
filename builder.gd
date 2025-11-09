extends Object
class_name CSGBoxToVMF

const mscale = 16
# Called when the node enters the scene tree for the first time.
static func CSGtoVMF(box_root:Node):
	var vmf = """versioninfo
{
	"editorversion" "400"
	"editorbuild" "8870"
	"mapversion" "2"
	"formatversion" "100"
	"prefab" "0"
}
visgroups
{
}
viewsettings
{
	"bSnapToGrid" "0"
	"bShowGrid" "1"
	"bShowLogicalGrid" "0"
	"nGridSpacing" "64"
}
world
{
	"id" "1"
	"mapversion" "2"
	"classname" "worldspawn"
	"message" "This map generated with CSGBoxToVMF"
	"detailmaterial" "detail/detailsprites"
	"detailvbsp" "detail.vbsp"
	"maxpropscreenwidth" "-1"
	"skyname" "sky_day01_01" """
	var lastSolidID = 2
	var lastFaceID = 0
	var eof_notes = "\n"
	var solidscan = _solidscan(box_root,lastSolidID,lastFaceID,vmf,eof_notes)
	vmf = solidscan[2]
	eof_notes = solidscan[3]
	vmf += """
}
$entities
cameras
{
	"activecamera" "0"
	camera
	{
		"position" "[-48.9031 17.8579 168.699]"
		"look" "[-48.9031 17.8579 -4.10112]"
	}
}
cordons
{
	"active" "0"
}""".replace("$entities",eof_notes)
	return vmf
	pass # Replace with function body.

static func BuildVMF(filename:String,box_root:Node):
	var fout = FileAccess.open(filename,FileAccess.WRITE)
	fout.store_string(CSGtoVMF(box_root))
	fout.close()

static func _solidscan(root_node:Node,lastSolidID,lastFaceID,vmf,eof_notes):
	for solid in root_node.get_children():
		
		if solid is CSGBox3D and not solid is ValveBrushEntity:
			var matpath = "dev/dev_measurewall01"
			if solid.material != null:
				matpath = solid.material.resource_path.replace("materials/","").replace("material/","").replace("res://","").replace("user://","").replace(".tres","")
			var data = _BuildSolidFromFaces(lastSolidID,lastFaceID,solid.global_position,solid.size,matpath)
			lastSolidID += 7
			lastFaceID = data[1]
			vmf += data[0]
		if solid is ValveBrushEntity:
			var entitybuilder = """entity
{
	"id" "$EID"
	"classname" "$VPE_CN"
	"origin" "$POX $POY $POZ"
	"spawnflags" "$VPE_FLAGSID"
	"StartDisabled" "$VPE_DISABLED"
	"targetname" "$VPE_NAME"
	connections
	{$VPE_BUILDCONNECTIONS	}"""
			entitybuilder = entitybuilder.replace("$EID",str(lastFaceID+1)).replace("$VPE_NAME",solid.name).replace("$VPE_CN",solid.classname)
			entitybuilder = entitybuilder.replace("$VPE_FLAGSID",str(solid.flags))
			entitybuilder = entitybuilder.replace("$VPE_DISABLED","1" if solid.start_disabled else "0")
			var connections = "\n"
			for connection in solid.connections:
				connections += "		\"On" + connection.connection + "\" \"" + connection.connected + "," + connection.callable + "," + connection.arguments + "," + str(connection.delay) + "," + str(connection.max_amount) + "\"\n"
			entitybuilder = entitybuilder.replace("$VPE_BUILDCONNECTIONS",connections)
			var matpath = "dev/dev_measurewall01"
			if solid.material != null:
				matpath = solid.material.resource_path.replace("materials/","").replace("material/","").replace("res://","").replace("user://","").replace(".tres","")
			var data = _BuildSolidFromFaces(lastSolidID,lastFaceID,solid.global_position,solid.size,matpath)
			lastSolidID += 7
			lastFaceID = data[1]
			entitybuilder += data[0]
			entitybuilder += "}\n"
			eof_notes += entitybuilder # "		\"OnStartTouch\" \"connections_example,Open,,0,-1\""
		if solid is ValvePointEntity:
			var keyvalues = ""
			for key in solid.parameters.keys():
				keyvalues += "	\"" + key + "\" \"" + solid.parameters[key] + "\""
			var connections = "\n"
			for connection in solid.connections:
				connections += "		\"On" + connection.connection + "\" \"" + connection.connected + "," + connection.callable + "," + connection.arguments + "," + str(connection.delay) + "," + str(connection.max_amount) + "\"\n"
			eof_notes += """entity
{
	"id" "$EID"
	"classname" "$VPE_CN"
	"targetname" "$VPE_NAME"
$KVP	"angles" "$AX $AZ $AY"
	"origin" "$PX $PZ $PY"
	connections
	{$VPE_BUILDCONNECTIONS	}
}
""".replace("$EID",str(lastFaceID+1)).replace("$VPE_BUILDCONNECTIONS",connections).replace("$KVP",keyvalues).replace("$VPE_NAME",solid.name).replace("$AX",str(solid.rotation_degrees.x)).replace("$VPE_CN",solid.classname).replace("$AY",str(solid.rotation_degrees.y)).replace("$AZ",str(solid.rotation_degrees.z)).replace("$PX",str(-solid.position.x*mscale*2)).replace("$PY",str(solid.position.y*mscale*2)).replace("$PZ",str(solid.position.z*mscale*2))
			lastFaceID += 2
		if solid is ValvePropEntity:
			eof_notes += """entity
{
	"id" "$EID"
	"classname" "$VPE_CN"
	"model" "$VPE_MODEL"
	"targetname" "$VPE_NAME"
	"angles" "$AX $AZ $AY"
	"origin" "$PX $PZ $PY"
}
""".replace("$EID",str(lastFaceID+1)).replace("$VPE_MODEL",solid.model).replace("$VPE_NAME",solid.name).replace("$AX",str(solid.rotation_degrees.x)).replace("$VPE_CN",solid.classname).replace("$AY",str(solid.rotation_degrees.y)).replace("$AZ",str(solid.rotation_degrees.z)).replace("$PX",str(-solid.position.x*mscale*2)).replace("$PY",str(solid.position.y*mscale*2)).replace("$PZ",str(solid.position.z*mscale*2))
			lastFaceID += 2
		var ss = _solidscan(solid,lastSolidID,lastFaceID,vmf,eof_notes)
		lastSolidID = ss[0]
		lastFaceID = ss[1]
		vmf = ss[2]
		eof_notes = ss[3]
	return [lastSolidID,lastFaceID,vmf,eof_notes]

static func _BuildSolidFromFaces(solidID,lastFaceID,solid_position,size,matpath):
	var newface = _boxsolid
	newface = newface.replace("$SID",str(solidID))
	newface = newface.replace("$S1",str(lastFaceID+1))
	newface = newface.replace("$S2",str(lastFaceID+2))
	newface = newface.replace("$S3",str(lastFaceID+3))
	newface = newface.replace("$S4",str(lastFaceID+4))
	newface = newface.replace("$S5",str(lastFaceID+5))
	newface = newface.replace("$S6",str(lastFaceID+6))
	newface = newface.replace("$S+X",str(-solid_position.x*mscale*2 + size.x*mscale))
	newface = newface.replace("$S+Y",str(solid_position.z*mscale*2 + size.z*mscale))
	newface = newface.replace("$S+Z",str(solid_position.y*mscale*2 + size.y*mscale))
	newface = newface.replace("$S-X",str(-solid_position.x*mscale*2 - size.x*mscale))
	newface = newface.replace("$S-Y",str(solid_position.z*mscale*2 - size.z*mscale))
	newface = newface.replace("$S-Z",str(solid_position.y*mscale*2 - size.y*mscale))
	newface = newface.replace("$MATERIAL",matpath)
	return [newface,lastFaceID+6]

# $SID = lastSideID*2 + 6

# position = Vector3(mscale*x,mscale*y,mscale*z)

# size = Vector3(mscale*x,mscale*y,mscale*z

static var _boxsolid = """
	solid
	{
		"id" "$SID"
		side
		{
			"id" "$S1"
			"plane" "($S-X $S+Y $S+Z) ($S+X $S+Y $S+Z) ($S+X $S-Y $S+Z)"
			"material" "$MATERIAL"
			"uaxis" "[1 0 0 128] 0.25"
			"vaxis" "[0 -1 0 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "$S2"
			"plane" "($S-X $S-Y $S-Z) ($S+X $S-Y $S-Z) ($S+X $S+Y $S-Z)"
			"material" "$MATERIAL"
			"uaxis" "[1 0 0 128] 0.25"
			"vaxis" "[0 -1 0 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "$S3"
			"plane" "($S-X $S+Y $S+Z) ($S-X $S-Y $S+Z) ($S-X $S-Y $S-Z)"
			"material" "$MATERIAL"
			"uaxis" "[0 1 0 128] 0.25"
			"vaxis" "[0 0 -1 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "$S4"
			"plane" "($S+X $S+Y $S-Z) ($S+X $S-Y $S-Z) ($S+X $S-Y $S+Z)"
			"material" "$MATERIAL"
			"uaxis" "[0 1 0 128] 0.25"
			"vaxis" "[0 0 -1 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "$S5"
			"plane" "($S+X $S+Y $S+Z) ($S-X $S+Y $S+Z) ($S-X $S+Y $S-Z)"
			"material" "$MATERIAL"
			"uaxis" "[1 0 0 128] 0.25"
			"vaxis" "[0 0 -1 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "$S6"
			"plane" "($S+X $S-Y $S-Z) ($S-X $S-Y $S-Z) ($S-X $S-Y $S+Z)"
			"material" "$MATERIAL"
			"uaxis" "[1 0 0 128] 0.25"
			"vaxis" "[0 0 -1 -128] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
	}"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
