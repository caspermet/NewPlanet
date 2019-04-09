

float4 tessDistance(APP_OUTPUT v0, APP_OUTPUT v1, APP_OUTPUT v2, float scale) {
	float minDist = scale * 0.5;
	float maxDist = scale * 2;
	return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, 2);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
struct HS_CONSTANT_OUTPUT
{
	float edges[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> v)
{
	HS_CONSTANT_OUTPUT o;

	o.edges[0] = v[0].tess;
	o.edges[1] = v[0].tess;
	o.edges[2] = v[0].tess;
	o.inside   = v[0].tess;

	return o;
}


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
	o.uv = ip[id].uv;
	o.wordPosition = ip[id].wordPosition;
	o.tess = ip[id].tess;

	return o;
}


[UNITY_domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> ip, float3 b : SV_DomainLocation)
{
	DS_OUTPUT o;
	o.vertex = ip[0].vertex*b.x + ip[1].vertex*b.y + ip[2].vertex*b.z;
	o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
	o.wordPosition = ip[0].wordPosition*b.x + ip[1].wordPosition*b.y + ip[2].wordPosition*b.z;
	o.normal = ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z;
	o.vertex = UnityObjectToClipPos(o.vertex);
	return o;
}
#endif