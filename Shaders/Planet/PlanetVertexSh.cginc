/*****************************************************************
				Planet Info
				x -> planet Radius -> (chunkSize - 1) * MaxScale
				y -> Max terrain height
		********************************************************************/
float3 _PlanetInfo;
float3 _CameraPosition;
sampler2D _noiseTexture;

UNITY_DECLARE_TEX2DARRAY(_PlanetHeightMapTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetHeightMapBottom);

struct APP_OUTPUT
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};


struct VS_OUTPUT
{
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float tess : TEXCOORD2;
};

StructuredBuffer<float4> positionBuffer;
StructuredBuffer<float4> directionsBuffer;


float3 CalcUVFromHM(float3 position) {
	float3 n = normalize(float3(position.x, position.y, position.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	float3 worldPosition;
	float4 noiseValue = float4(0,0,0,0);

	float dist = (distance(float3(0,0,0),  _CameraPosition)) - _PlanetInfo.x;
	if (dist > _PlanetInfo.x * 0.5) {
		worldPosition = (position.xyz + n * (tex2Dlod(_HeightTex, float4(uCoor, vCoor, 0.0, 0)) * _PlanetInfo.y));
	}
	else {
		float uMap = uCoor * 4;
		int vMap = vCoor >= 0.5f ? 1 : 2;

		int xindex = int(uMap);

		int index = xindex + (vCoor >= 0.5f ? 0 : 4);

		float uCoor2 = (uCoor * 4 - (float(xindex)));
		float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;

		//float3 worldPosition = (position.xyz + n * (tex2Dlod(_HeightTex, float4(uCoor, vCoor, 0.0, 0)) * _PlanetInfo.y));
		float4 c;
		if (vCoor >= 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapTop, float3(uCoor2, vCoor2, index), 0);
		}
		else {
			//c = float3(1, 1, 1);
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapBottom, float3(uCoor2, vCoor2, index), 0);
		}

		if (dist < 400 && _FlipNoise == 1) {
			noiseValue = tex2Dlod(_noiseTexture, float4(uCoor * _Tesss, vCoor * _Tesss, 0.0, 0)) * _Tess;
		}
	

		worldPosition = (position.xyz + n * (c.xyz + noiseValue.xyz) * _PlanetInfo.y);
	}

	return worldPosition;
}

VS_OUTPUT VS(APP_OUTPUT v, uint instanceID : SV_InstanceID)
{
	VS_OUTPUT o;

	float4 data = positionBuffer[instanceID];
	float4 transform = directionsBuffer[instanceID];

	float4 pos = v.vertex;

	if (transform.x != 0) {
		v.vertex.y = mul(transform.x, pos.z);
		v.vertex.z = 0;
	}
	else if (transform.y != 0) {
		v.vertex.y = mul(transform.y, pos.x);
		v.vertex.x = 0;
	}
	else if (transform.z == -1) {
		v.vertex.x = -pos.x;
	}

	float3 localPosition = v.vertex.xyz * data.w;
	float3 worldPosition = data.xyz + localPosition;
	float3 worldNormal = v.normal;


	float x = worldPosition.x / _PlanetInfo.x;;
	float y = worldPosition.y / _PlanetInfo.x;;
	float z = worldPosition.z / _PlanetInfo.x;;

	float dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
	float dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
	float dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));

	worldPosition.xyz = float3(dx, dy, dz) * _PlanetInfo.x;;

	worldPosition.xyz = CalcUVFromHM(worldPosition);

	o.wordPosition = mul(UNITY_MATRIX_MV, float4(worldPosition, 1.0f));
	o.wordPosition = float4(worldPosition, 1.0f);
	o.vertex = float4(worldPosition, 1.0f);
	o.normal = v.normal;
	o.uv = v.uv;
	o.tess = transform.w;
	return o;

}