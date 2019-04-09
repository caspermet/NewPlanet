
float3 calcColor2(DS_OUTPUT input, float3 textureColor,float3 normalDirection) {

	//float3 normalDirection = input.normal;

	float3 viewDirection = normalize(_WorldSpaceCameraPos - input.wordPosition.xyz);
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

	float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
	float3 spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

	// DIFFUSE + NORMAL

	float3 c = diff * pow(textureColor, _Gamma);
	// SPECULAR
//	c += spec * diff * pow(tex2D(_SpecMap, input.uv.xy).r, _Gamma);

	// EXPOSURE
	c = 1.0 - exp(c * -fHdrExposure);
	// GAMMA CORRECTION
	c = pow(c, 1 / _Gamma);

	return c;
}


float3 FlowUVW(
	float2 uv, float2 flowVector,
	float flowOffset, float tiling, float time, bool flowB
) {
	float phaseOffset = flowB ? 0.5 : 0;
	float progress = frac(time + phaseOffset);
	float3 uvw;
	uvw.xy = uv - flowVector * (progress + flowOffset);
	uvw.xy *= tiling;
	uvw.xy += phaseOffset;
	uvw.xy += (time - progress);
	uvw.z = 1 - abs(1 - 2 * progress);
	return uvw;
}

float3 UnpackDerivativeHeight(float4 textureData) {
	float3 dh = textureData.agb;
	dh.xy = dh.xy * 2 - 1;
	return dh;
}
/*
float4 Water(DS_OUTPUT i, float4 WaterColor) {
	float2 newUV = i.uv * _Value;
	float2 flowVector = tex2D(_WaterFlowMap, newUV).rg * 2 - 1;
	flowVector *= _WaterFlowStrength;
	float noise = tex2D(_WaterFlowMap, newUV).a;
	float time = _Time.y * _WaterSpeed + noise;

	float3 uvwA = FlowUVW(newUV, flowVector, _WaterFlowOffset, _WaterTiling, time, false);
	float3 uvwB = FlowUVW(newUV, flowVector, _WaterFlowOffset, _WaterTiling, time, true);

	float3 dhA =
		UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) *
		(uvwA.z * finalHeightScale);
	float3 dhB =
		UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) *
		(uvwB.z * finalHeightScale);
	float3 normalDirection = normalize(float3(-(dhA.xy + dhB.xy), 1));
//	float3 normalDirection = normalize(normalA + normalB);



	fixed4 texA = tex2D(_WaterMainTex, uvwA.xy) * uvwA.z;
	fixed4 texB = tex2D(_WaterMainTex, uvwB.xy) * uvwB.z;

	fixed4 albedo = (texA + texB) * WaterColor;

	normalDirection = normalize(normalDirection * 2 - 1);;


	return float4(calcColor2(i, albedo, normalDirection),1);
	
}
*/
fixed4 FS(DS_OUTPUT i) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	int xindex;
	float dist = distance(_CameraPosition, float3(0, 0, 0)) - _PlanetInfo.x;
	fixed4 c;
	float uCoor2;
	float spectrum = tex2D(_SpecMap,float2(uCoor, vCoor)).r;


/*	if (spectrum >= 0.5) {
		c = Water(i, tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0)));
		return c;
	}*/
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


		if (dist < float(_PlanetInfo.x)  * 0.2) {
			if (c.x > 0.2 && c.y > 0.2 && c.z < 0.2) {

				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, 0.8);
			}
			else if (c.x > 0.6 && c.y > 0.6 && c.z > 0.6) {
				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 3)), c, 0.5);
			}
		}

	}

	float3 calc = calcColor2(i, c.xyz, i.normal);

	return float4(calc, 1.0);
}