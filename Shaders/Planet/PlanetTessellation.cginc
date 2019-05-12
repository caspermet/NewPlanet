
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles

double4 tessDistance(APP_OUTPUT v0, APP_OUTPUT v1, APP_OUTPUT v2, double scale) {
	double minDist = scale * 0.5;
	double maxDist = scale * 2;
	return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, 2);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
struct HS_CONSTANT_OUTPUT
{
	float edges[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};


double EdgeTess(double3 wpos0, double3 wpos1, double edgeLen)
{
	// distance to edge center
	double dist = distance(0.5 * (wpos0 + wpos1), _CameraPosition);
	// length of the edge
	double len = distance(wpos0, wpos1);
	// edgeLen is approximate desired size in pixels
	double f = max(len * 32 * 2.8f / ( dist), 1.0);
	return f;
}

double4 edgee(double4 v0, double4 v1, double4 v2, double edgeLength)
{
	double3 pos0 = mul(unity_ObjectToWorld, v0).xyz;
	double3 pos1 = mul(unity_ObjectToWorld, v1).xyz;
	double3 pos2 = mul(unity_ObjectToWorld, v2).xyz;
	double4 tess;
	tess.x = EdgeTess(pos1, pos2, edgeLength);
	tess.y = EdgeTess(pos2, pos0, edgeLength);
	tess.z = EdgeTess(pos0, pos1, edgeLength);
	

	
	tess.w = (tess.x + tess.y + tess.z) / 2.5f;

	return tess;
}



double4 tessEdge(VS_OUTPUT v0, VS_OUTPUT v1, VS_OUTPUT v2)
{
	return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, 9);
}

HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> v)
{
	HS_CONSTANT_OUTPUT o;
	VS_OUTPUT vi[3];
	double4 tf;

	vi[0].vertex = v[0].vertex;
	vi[1].vertex = v[1].vertex;
	vi[2].vertex = v[2].vertex;

	tf = edgee(vi[0].vertex, vi[1].vertex, vi[2].vertex, 6);
	o.edges[0] = tf.x; o.edges[1] = tf.y; o.edges[2] = tf.z; o.inside = tf.w;
	//o.edges[0] = 5; o.edges[1] =5; o.edges[2] = 5; o.inside = 5;
	return o;
}



/*******
Hull shader

	b  - barycentrická souøadnice
	ip - Pùvodní vertexy

********/

[UNITY_domain("tri")]
[UNITY_partitioning("fractional_odd")]
[UNITY_outputtopology("triangle_cw")]
[UNITY_outputcontrolpoints(3)]
[UNITY_patchconstantfunc("HSConst")]
HS_OUTPUT HS(InputPatch<VS_OUTPUT, 3> ip, uint id : SV_OutputControlPointID)
{
	HS_OUTPUT o;
	o.vertex = ip[id].vertex;
	o.normal = ip[id].normal;
	o.normal2 = ip[id].normal2;
	o.uv = ip[id].uv;
	o.wordPosition = ip[id].wordPosition;
	o.tess = ip[id].tess;
	o.height = ip[id].height;
	o.angle = ip[id].angle;

	return o;
}


/*******
Domain shader 

	b  - barycentrická souøadnice
	ip - Pùvodní vertexy

********/

[UNITY_domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> ip, float3 b : SV_DomainLocation)
{
	DS_OUTPUT o;
	double3 vertex = ip[0].vertex*b.x + ip[1].vertex*b.y + ip[2].vertex*b.z;
	o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
	o.normal = normalize(ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z);
	o.normal2 = ip[0].normal2*b.x + ip[1].normal2*b.y + ip[2].normal2*b.z;
	o.height = ip[0].height*b.x + ip[1].height*b.y + ip[2].height*b.z;
	o.angle = ip[0].angle*b.x + ip[1].angle*b.y + ip[2].angle*b.z;

	/// Výpoèet UV souøadnic 
	double3 normal = normalize(double3(vertex.x, vertex.y, vertex.z));
	o.normal = normal;
	double uCoor = atan2(normal.z, normal.x) / (2 * PI) + 0.5f;
	double vCoor = asin(normal.y) / PI + 0.5f;

	double height = tex2Dlod(_PlanetHeightMap, double4(uCoor, vCoor, 0.0, 0)); //vypoèítaná výška podle uv souøadnic z výškové mapy

	o.vertex = double4((o.normal * _PlanetInfo.x  + o.normal * (height * _PlanetInfo.y)),1.0);
	o.wordPosition = o.vertex;
	o.vertex = UnityObjectToClipPos(o.vertex);
	return o;
}
#endif