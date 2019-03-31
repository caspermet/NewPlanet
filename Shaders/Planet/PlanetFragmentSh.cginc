fixed4 FS(DS_OUTPUT i) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI - 0.5f;

	float uMap = i.uv.x * 4;
	int vMap = i.uv.y >= 0.5f ? 1 : 2;

	int xindex = int(uMap);

	int index = xindex + (i.uv.y >= 0.5f ? 0 : 4);

	float uCoor2 = (uCoor - (float(xindex) - 1.0f) * 0.25f) * 4;
	float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;

	//fixed4 c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTextures, float3(float2(uCoor2, vCoor2), index));
	fixed4 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	fixed4 albedo = c;

	return c;
}