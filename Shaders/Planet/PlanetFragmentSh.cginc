UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesBottom);

fixed4 FS(DS_OUTPUT i) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	int xindex;
	float dist = distance(_CameraPosition, float3(0, 0, 0)) - _PlanetInfo.x;
	fixed4 c;
	float uCoor2;
	if (dist > float(_PlanetInfo.x) * 20) {
		 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));
	}
	else {
		float uMap = uCoor * 4;
		int vMap = vCoor >= 0.5f ? 1 : 2;

		 xindex = int(uMap);

		int index = xindex + (vCoor >= 0.5f ? 0 : 4);


		uCoor2 = (uCoor * 4 - (float(xindex)));
		float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;
		
		if (vCoor >= 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesTop, float3(float2(uCoor2, vCoor2), xindex));
		}
		else {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesBottom, float3(float2(uCoor2, vCoor2), xindex));
		}
		//fixed4 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	}

	return c;
}