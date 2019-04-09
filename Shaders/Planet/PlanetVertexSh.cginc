
/*******************
	Calcule height value from heighMap
*/
float3 CalcUVFromHM(float3 position, float2 uvCoor, float3 normPosition) {

	float3 worldPosition;
	float4 noiseValue = float4(0,0,0,0);

	float dist = (distance(float3(0,0,0),  _CameraPosition)) - _PlanetInfo.x;
	if (dist > _PlanetInfo.x * 0.5) {
		worldPosition = (position.xyz + normPosition * (tex2Dlod(_HeightTex, float4(uvCoor, 0.0, 0)) * _PlanetInfo.y));
	}
	else {
		float uMap = uvCoor.x * 4;
		int vMap = uvCoor.y > 0.5f ? 1 : 2;

		int xindex = int(uMap);

		int index = xindex + (uvCoor.y >= 0.5f ? 0 : 4);

		float uCoor2 = (uvCoor.x * 4 - (float(xindex)));
		float vCoor2 = (uvCoor.y - float(vMap) * 0.5f) * 2;  

		float4 c;
		if (uvCoor.y > 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapTop, float3(uCoor2, vCoor2, index), 0);
		}
		else {		
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapBottom, float3(uCoor2, vCoor2, index), 0);
		}

		if (_FlipNoise == 1 && c.y > _noiseHeight) {
			noiseValue = tex2Dlod(_noiseTexture, float4(uvCoor.x * _Tesss, uvCoor.y * _Tesss, 0.0, 0)) * _Tess;
		}
	

		worldPosition = (position.xyz + normPosition * (c.xyz + noiseValue.xyz) * _PlanetInfo.y);
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
	o.normal = float3(dx, dy, dz);

	worldPosition.xyz = float3(dx, dy, dz) * _PlanetInfo.x;

	//calcule UV of heightMap
	float3 n = normalize(float3(worldPosition.x, worldPosition.y, worldPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f; 
	float tessellation = transform.w * _TessMax;

	/**************************
	calcul if is water
	*****************/
	float specular = tex2Dlod(_SpecMap, float4(uCoor, vCoor, 0.0f, 0)).r;

	if (tessellation < _TessMin) {
		tessellation = _TessMin;
	}

	if (specular >= 0.5f) {
		tessellation = 1;
	}
	else {
		worldPosition.xyz = CalcUVFromHM(worldPosition, float2(uCoor, vCoor), n);
	}

	o.wordPosition = mul(UNITY_MATRIX_MV, float4(worldPosition, 1.0f));
	o.wordPosition = float4(worldPosition, 1.0f);
	o.vertex = float4(worldPosition, 1.0f);
	o.uv = float2(uCoor, vCoor);
	o.tess = tessellation;
	
	return o;

}