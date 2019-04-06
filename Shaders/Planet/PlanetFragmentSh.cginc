UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesBottom);
UNITY_DECLARE_TEX2DARRAY(_SurfaceTexture);

float3 calcColor2(DS_OUTPUT input, float3 textureColor) {

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

fixed4 FS(DS_OUTPUT i) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	int xindex;
	float dist = distance(_CameraPosition, float3(0, 0, 0)) - _PlanetInfo.x;
	fixed4 c;
	float uCoor2;

	if (dist > float(_PlanetInfo.x)  * 0.5) {
		 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));
	}

	else {
		float uMap = uCoor * 4;
		int vMap = vCoor > 0.5f ? 1 : 2;

		 xindex = int(uMap);

		int index = xindex + (vCoor >= 0.5f ? 0 : 4);


		uCoor2 = (uCoor * 4 - (float(xindex)));
		float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;
		
		if (vCoor > 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesTop, float3(float2(uCoor2, vCoor2), xindex));
		}
		else {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesBottom, float3(float2(uCoor2, vCoor2), xindex));
		}

		//c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	
		if (dist < float(_PlanetInfo.x)  * 0.2) {
			if (c.x > 0.2 && c.y > 0.2 && c.z < 0.2) {

				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, 0.9);
			}
			else if (c.x > 0.7 && c.y > 0.7 && c.z > 0.7) {
				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 3)), c, 0.5);
			}
		}
	
		//fixed4 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	}

	float3 calc = calcColor2(i, c.xyz);

	return float4(calc, 1.0);
}