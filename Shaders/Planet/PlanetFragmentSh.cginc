[maxvertexcount(3)]
void geom(triangle DS_OUTPUT IN[3], inout TriangleStream<GM_OUTPUT> tristream)
{
	GM_OUTPUT o;

	//color vertices based on the angle
	for (int i = 0; i < 3; i++)
	{
		//o.normal = normall;
		o.vertex = IN[i].vertex;
		o.normal = IN[i].normal;
	
		o.uv = IN[i].uv;
		o.wordPosition = IN[i].wordPosition;
		o.height = IN[i].height;
		tristream.Append(o);
	}
}





float3 calcColor2(GM_OUTPUT input, float3 textureColor) {

	float3 normalDirection = input.normal;

	float3 viewDirection = normalize(_WorldSpaceCameraPos - input.wordPosition.xyz);
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

	float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
	float3 spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

	// DIFFUSE + NORMAL
	float3 c = diff * pow(textureColor, _Gamma);

	// SPECULAR
	c += spec * diff * pow(tex2D(_SpecMap, input.uv.xy).r, _Gamma);

	// EXPOSURE
	c = 1.0 - exp(c * -fHdrExposure);

	// GAMMA CORRECTION
	c = pow(c, 1 / _Gamma);

	return c;
}

fixed4 FS(GM_OUTPUT i) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	int xindex;
	float dist = distance(_CameraPosition, float3(0, 0, 0)) - _PlanetInfo.x;
	fixed4 c;
	float uCoor2;
	float spectrum = tex2D(_SpecMap,float2(uCoor, vCoor)).r;
	float height = i.height;
	c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	if (dist < float(_PlanetInfo.x)  * 0.2f) {
		float ii = 1;

	/*	int index = 0;

		for (int o = 0; o < _TexturesArrayLength; o++) {
			if (1 - i.height >= _TexturesArray[o]) {
				index = o;
				break;
			}
		}*/

		if (dist < float(_PlanetInfo.x)  * 0.05f) {
			ii = 0.6f;
		}
		else {
			ii = ((dist - float(_PlanetInfo.x)  * 0.05f) * 0.4f) / (float(_PlanetInfo.x)  * 0.15f) + 0.6f;
		} 


		if (c.x < 0.2 && c.y > 0.2 && c.z < 0.2) {

			c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, ii);
		}
		else if (i.height < 0.2f) {
			c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, ii);
		}
		else if (c.x > 0.6 && c.y > 0.6 && c.z > 0.6) {
			c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 3)), c, ii);
		}
		else if (c.y - c.x > 5 && c.z < 0.6) {
			c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 3)), c, ii);
		}
	}

	float3 calc = calcColor2(i, c.xyz);

	return float4(calc, 1.0);
}