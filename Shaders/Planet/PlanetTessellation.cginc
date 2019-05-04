
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles

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
/**
float4 edgee(float4 v0, float4 v1, float4 v2, float edgeLength)
{
	float3 pos0 = mul(unity_ObjectToWorld, v0).xyz;
	float3 pos1 = mul(unity_ObjectToWorld, v1).xyz;
	float3 pos2 = mul(unity_ObjectToWorld, v2).xyz;
	float4 tess;
	tess.x = UnityCalcEdgeTessFactor(pos1, pos2, edgeLength);
	tess.y = UnityCalcEdgeTessFactor(pos2, pos0, edgeLength);
	tess.z = UnityCalcEdgeTessFactor(pos0, pos1, edgeLength);
	tess.w = (tess.x + tess.y + tess.z) / 3.0f;
	return tess;
}*/

float4 tessEdge(VS_OUTPUT v0, VS_OUTPUT v1, VS_OUTPUT v2)
{
	return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, 10);
}

HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> v)
{
	HS_CONSTANT_OUTPUT o;
	VS_OUTPUT vi[3];
	float4 tf;

	vi[0].vertex = v[0].vertex;



	vi[1].vertex = v[1].vertex;



	vi[2].vertex = v[2].vertex;


	tf = tessEdge(vi[0], vi[1], vi[2]);
	//o.edges[0] = tf.x; o.edges[1] = tf.y; o.edges[2] = tf.z; o.inside = tf.w;
	o.edges[0] = 1; o.edges[1] =1; o.edges[2] = 1; o.inside = 1;
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
	o.normal2 = ip[id].normal2;
	o.uv = ip[id].uv;
	o.wordPosition = ip[id].wordPosition;
	o.tess = ip[id].tess;
	o.height = ip[id].height;

	return o;
}


[UNITY_domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> ip, float3 b : SV_DomainLocation)
{
	DS_OUTPUT o;
	o.vertex = ip[0].vertex*b.x + ip[1].vertex*b.y + ip[2].vertex*b.z;
	o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
	o.wordPosition = ip[0].wordPosition*b.x + ip[1].wordPosition*b.y + ip[2].wordPosition*b.z;
	o.normal = normalize(ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z);
	o.normal2 = ip[0].normal2*b.x + ip[1].normal2*b.y + ip[2].normal2*b.z;
	o.height = ip[0].height*b.x + ip[1].height*b.y + ip[2].height*b.z;

	float height = tex2Dlod(_PlanetHeightMap, float4(o.uv, 0.0, 0));
	o.vertex = float4((o.normal * _PlanetInfo.x  + o.normal * (height * _PlanetInfo.y)),1.0);
	o.vertex = UnityObjectToClipPos(o.vertex);
	return o;
}
#endif