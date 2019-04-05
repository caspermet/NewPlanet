UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesBottom);
UNITY_DECLARE_TEX2DARRAY(_SurfaceTexture);


float3 calcColor(DS_OUTPUT i) {
	float3 normalDirection = i.normal;
	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.wordPosition.xyz);
	float lightDirection = normalize(_WorldSpaceLightPos0.xyz);
	float atten = 1.0;

	float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
	float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

	float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
	float rimLighting = atten * _LightColor0.xyz  * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
	float3 lightFinal = rimLighting + diffuseReflection + specularReflection +UNITY_LIGHTMODEL_AMBIENT.rgb;

	return float3(lightFinal);
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
		int vMap = vCoor >= 0.5f ? 1 : 2;

		 xindex = int(uMap);

		int index = xindex + (vCoor >= 0.5f ? 0 : 4);


		uCoor2 = (uCoor * 4 - (float(xindex)));
		float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;
		
		/*if (vCoor >= 0.5f) {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesTop, float3(float2(uCoor2, vCoor2), xindex));
		}
		else {
			c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTexturesBottom, float3(float2(uCoor2, vCoor2), xindex));
		}*/

		c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

	
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



	return float4(calcColor(i).xyz * c.xyz, 1.0);
}