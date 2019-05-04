
/*******************
	Calcule height value from heighMap
*/
float3 CalcUVFromHM(float3 position, float2 uvCoor, float3 normPosition, float height) {
	 
	float3 worldPosition;
	float4 noiseValue = float4(0,0,0,0);

	float dist = (distance(float3(0,0,0),  _CameraPosition)) - _PlanetInfo.x;
	
	worldPosition = (position.xyz + normPosition * (height * _PlanetInfo.y));

/*	if (dist > _PlanetInfo.x * 0.5) {
		worldPosition = (position.xyz + normPosition * (tex2Dlod(_HeightTex, float4(uvCoor, 0.0, 0)) * _PlanetInfo.y));
	}
	else {
		float uMap = uvCoor.x * 4;
		int vMap = int(uvCoor.y >= 0.5f ? 1 : 0);

		int xindex = int(uMap);

		int index = xindex;// +(uvCoor.y >= 0.5f ? 0 : 4);

		float uCoor2 = (uvCoor.x * 4 - (float(xindex)));
		float vCoor2 = (uvCoor.y - float(vMap) * 0.5f) * 2;
		uCoor2 = uCoor2 < 0 ? 0 : uCoor2;
		uCoor2 = uCoor2 > 1 ? 1 : uCoor2;
		vCoor2 = vCoor2 > 1 ? 1 : vCoor2;
		vCoor2 = vCoor2 < 0 ? 0 : vCoor2;

		/*if (uCoor2 >= 0.998) {
			uCoor2 = 0.997;
		}
		if (vCoor2 >= 0.998) {
			vCoor2 = 0.997;
		}
		if (uCoor2 <= 0.001) {
			uCoor2 = 0.002;
		}
		if (vCoor2 <= 0.001) {
			vCoor2 = 0.002;
		}

		float4 c;
		if (uvCoor.y >= 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapTop, float3(uCoor2, vCoor2, index ), 0);
		}
		else {		
			c = UNITY_SAMPLE_TEX2DARRAY_LOD(_PlanetHeightMapBottom, float3(uCoor2, vCoor2, index), 0);
		}

		if (_FlipNoise == 1 && c.y > _noiseHeight) {
			//noiseValue = tex2Dlod(_noiseTexture, float4(uvCoor.x * _Tesss, uvCoor.y * _Tesss, 0.0, 0)) * _Tess;
		}
	

		worldPosition = (position.xyz + normPosition * (c.xyz + noiseValue.xyz) * _PlanetInfo.y);
	}*/

	return worldPosition;
}

float mapp(float3 vertex) {

	float3 n = normalize(vertex);
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;

	return tex2Dlod(_HeightTex, float4(float2(uCoor, vCoor), 0.0, 0));
	
}

float3 CalculePoinOnCube(float3 worldPosition) {
	float x = worldPosition.x / _PlanetInfo.x;;
	float y = worldPosition.y / _PlanetInfo.x;;
	float z = worldPosition.z / _PlanetInfo.x;;

	float dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
	float dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
	float dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));


	return float3(dx, dy, dz) * _PlanetInfo.x;
}

float3 calculateNormal(float3 vertex, float scale)
{


	float h = 0.1;
	float3 normal;

	normal.x = mapp(CalculePoinOnCube(vertex + float3(h, 0, 0))) - mapp(CalculePoinOnCube(vertex - float3(h, 0, 0)));
	normal.y = mapp(CalculePoinOnCube(vertex + float3(0, h, 0))) - mapp(CalculePoinOnCube(vertex - float3(0, h, 0)));
	normal.z = mapp(CalculePoinOnCube(vertex + float3(0, 0, h))) - mapp(CalculePoinOnCube(vertex - float3(0, 0, h)));
	return normalize(normal);
}

float3 filterNormalLod(float4 uv, float scale, float3 normal)
{
	float4 h;
	float texelSize = 0.000001;

	h[0] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(0, -1), 0, 0)).x * _PlanetInfo.y;
	h[1] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(-1, 0), 0, 0)).x *  _PlanetInfo.y;
	h[2] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(1, 0), 0, 0)).x * _PlanetInfo.y;
	h[3] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(0, 1), 0, 0)).x * _PlanetInfo.y;

	float3 n;
	n.z = h[0] - h[3];
	n.x = h[1] - h[2];
	n.y = 2; 

	return   normalize(normalize(n) + normal * 2);
}


float3x3 RotateAroundYInDegrees(float degrees)
{
	float alpha = degrees * UNITY_PI / 180.0;
	float sina, cosa;
	sincos(alpha, sina, cosa);


	return float3x3(
		cosa, 0, -sina,
		0, 1, 0,
		sina, 0, cosa);
}

VS_OUTPUT VS(APP_OUTPUT v, uint instanceID : SV_InstanceID)
{
	VS_OUTPUT o;

	float4 data = positionBuffer2[instanceID];
	float4 transform = directionsBuffer2[instanceID];

	v.vertex.xyz = mul(RotateAroundYInDegrees(_rotate), v.vertex.xyz);
	float3 pos = v.vertex.xyz;
	
	if (transform.z != 0 && transform.y != 0) {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w   + transform.z * 90), v.vertex.xyz);

		pos = v.vertex.xyz;
		v.vertex.y = mul(transform.z * -1, pos.x);
		v.vertex.x = 0;
	}
	else if (transform.x != 0 && transform.y != 0) {

		if (transform.x == 1) {
			v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w), v.vertex.xyz);
		}
		else {
			v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w + 180), v.vertex.xyz);
		}
	
		pos = v.vertex.xyz;
		v.vertex.y = mul(transform.x, pos.z);
		v.vertex.z = 0;
	}
	else if (transform.x == -1 && transform.z != 0) {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w + _rotate), v.vertex.xyz);
		pos = v.vertex.xyz;
		v.vertex.x = -pos.x;
	}
	else {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w ), v.vertex.xyz);
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
	o.normal = n;
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f; 
	float tessellation = data.w;

	//o.normal2 = filterNormalLod(uvlod, data.w, o.normal, worldPosition);
	o.normal2 = filterNormalLod(float4(uCoor, vCoor,0, 1.0), data.w, n);

	float height = tex2Dlod(_PlanetHeightMap, float4(float2(uCoor, vCoor), 0.0, 0));
	worldPosition.xyz = (worldPosition + n * (height * _PlanetInfo.y));
	
	o.wordPosition = float4(worldPosition, 1.0f);
	o.vertex = float4(worldPosition, 1.0f);
	o.uv = float2(uCoor, vCoor);
	o.tess = tessellation;
	o.height = tessellation;
	
	return o;

}