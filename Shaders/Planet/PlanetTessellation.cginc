

struct HS_CONSTANT_OUTPUT
{
	float edges[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};


/*******
Vypoèítá teselaèní faktory pro hrany podle velikosti  hrany a vzdálenosti od kamery

Zmìna dlaždice na vyšší úroveò detailu se provede když --> scale * 2 > dist 

proto len musí být vynásobeno scale, který je defaultnì urèen jako 16 + vynásobit tesselaèním faktorem

********/
double EdgeTess(double3 wpos0, double3 wpos1, double edgeLen)
{
	// vzdálenost kamery od støedu hrany
	double dist = distance(0.5 * (wpos0 + wpos1), _CameraPosition);

	// délka hrany
	double len = distance(wpos0, wpos1);

	// výpoèet samotného tesselaèního faktoru
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


HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> v)
{
	HS_CONSTANT_OUTPUT o;
	VS_OUTPUT vi[3];
	double4 tf;

	vi[0].vertex = v[0].vertex;
	vi[1].vertex = v[1].vertex;
	vi[2].vertex = v[2].vertex;

	if (_IsTessellation == 1) {
		tf = edgee(vi[0].vertex, vi[1].vertex, vi[2].vertex, 6);
		o.edges[0] = tf.x; o.edges[1] = tf.y; o.edges[2] = tf.z; o.inside = tf.w;
	}
	else {
		o.edges[0] = 1; o.edges[1] = 1; o.edges[2] = 1; o.inside = 1;
	}

	return o;
}



/*******
Hull shader

	ip - vstupej je polygon
	id - id vertexu

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
	o.height = ip[id].height;

	return o;
}
#ifdef UNITY_CAN_COMPILE_TESSELLATION

/*******
Domain shader 

	b  - barycentrická souøadnice
	ip - Pùvodní vertexy

********/

[UNITY_domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> ip, float3 b : SV_DomainLocation)
{
	// interpolace pùvodního polygonu barycentrickou souøadnicí
	DS_OUTPUT o;
	double3 vertex = ip[0].vertex*b.x + ip[1].vertex*b.y + ip[2].vertex*b.z;
	o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
	o.normal = normalize(ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z);
	o.normal2 = ip[0].normal2*b.x + ip[1].normal2*b.y + ip[2].normal2*b.z;
	o.height = ip[0].height*b.x + ip[1].height*b.y + ip[2].height*b.z;

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