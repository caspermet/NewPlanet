struct HS_OUTPUT
{
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float tess : TEXCOORD2;
};

struct DS_OUTPUT
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
};

float4 tessDistance(APP_OUTPUT v0, APP_OUTPUT v1, APP_OUTPUT v2) {
	float minDist = 10.0;
	float maxDist = 70.0;
	return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
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
	float4 tf;

	APP_OUTPUT vi[3];
	vi[0].vertex = v[0].vertex;
	vi[1].vertex = v[1].vertex;
	vi[2].vertex = v[2].vertex;

	tf = tessDistance(vi[0], vi[1], vi[2]);
	o.edges[0] = tf.x; o.edges[1] = tf.y; o.edges[2] = tf.z; o.inside = tf.w;

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
	o.tangent = ip[id].tangent;
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
	o.normal = ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z;
	o.tangent = ip[0].tangent*b.x + ip[1].tangent*b.y + ip[2].tangent*b.z;
	o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
	o.wordPosition = ip[0].wordPosition*b.x + ip[1].wordPosition*b.y + ip[2].wordPosition*b.z;
	o.vertex = UnityObjectToClipPos(o.vertex);
	return o;
}
#endif