
/*******************
	Calcule height value from heighMap
*/
float3 CalcUVFromHM(float3 position, float2 uvCoor, float3 normPosition, float height) {
	 
	float3 worldPosition;
	float4 noiseValue = float4(0,0,0,0);

	float dist = (distance(float3(0,0,0),  _CameraPosition)) - _PlanetInfo.x;
	
	worldPosition = (position.xyz + normPosition * (height * _PlanetInfo.y));

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
	float texelSize = 0.00001;

	h[0] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(0, -1), 0, 0)).x * _PlanetInfo.y;
	h[1] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(-1, 0), 0, 0)).x *  _PlanetInfo.y;
	h[2] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(1, 0), 0, 0)).x * _PlanetInfo.y;
	h[3] = tex2Dlod(_PlanetHeightMap, uv + float4(texelSize * float2(0, 1), 0, 0)).x * _PlanetInfo.y;

	float3 n;
	n.z = h[0] - h[3];
	n.x = h[1] - h[2];
	n.y = 2; 

	return   normalize(float3(0, 1, 0) - normalize(n) + normal);
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

	float4 data = positionBuffer[instanceID];
	float4 transform = directionsBuffer[instanceID];

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
	if (data.x < 0) {
		data.x = data.x - 500;
	}
	if (data.y < 0) {
		data.y = data.y - 500;
	}

	float3 localPosition = v.vertex.xyz * data.w;
	float3 worldPosition = data.xyz + localPosition ;

	float x = worldPosition.x / _PlanetInfo.x;;
	float y = worldPosition.y / _PlanetInfo.x;;
	float z = worldPosition.z / _PlanetInfo.x;;
	
	float dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
	float dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
	float dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));

	o.normal = float3(dx, dy, dz);

	//worldPosition.xyz = float3(dx, dy, dz) * _PlanetInfo.x;



	//calcule UV of heightMap
	float3 n = normalize(float3(worldPosition.x, worldPosition.y, worldPosition.z));
	o.normal = n;
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f; 
	float tessellation = data.w;

//	o.normal2 = filterNormalLod(uvlod, data.w, o.normal, worldPosition);
	o.normal2 = filterNormalLod(float4(uCoor, vCoor,0, 1.0), data.w, n);

	//o.normal2 = normalize(o.normal * 2 - tex2Dlod(_PlanetNormalMap, float4(float2(uCoor, vCoor), 0.0, 0)));

	//float height = tex2Dlod(_PlanetHeightMap, float4(float2(uCoor, vCoor), 0.0, 0));
	//worldPosition.xyz = (worldPosition + n * (height * _PlanetInfo.y));
	
	o.wordPosition = float4(worldPosition, 1.0f);
	o.vertex = float4(worldPosition, 1.0f);
	o.uv = float2(uCoor, vCoor);
	o.tess = tessellation;
	o.height = tessellation;
	
	return o;

}