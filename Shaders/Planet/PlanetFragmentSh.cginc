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
		o.normal2 = IN[i].normal2;

		o.uv = IN[i].uv;
		o.wordPosition = IN[i].wordPosition;
		o.height = IN[i].height;
		tristream.Append(o);
	}
}


float3 calcColor2(GM_OUTPUT input, float3 textureColor) {

	float3 normalDirection = input.normal;
	float3 normalDirection2 = input.normal2;

	float3 viewDirection = normalize(_WorldSpaceCameraPos - input.wordPosition.xyz);
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

	//float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
	float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection2 + (0.2 * lightDirection))));
	float3 spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

	// DIFFUSE + NORMAL
	diff.x = diff.x < 0.1 ? 0.1 : diff.x;
	diff.y = diff.y < 0.1 ? 0.1 : diff.y;
	diff.z = diff.z < 0.1 ? 0.1 : diff.z;

	//diff =  lerp(diff, diff2, 0.5);

	float3 c = diff * pow(textureColor, _Gamma);

	// SPECULAR
	c += spec * diff * pow(tex2D(_SpecMap, input.uv.xy).r, _Gamma);

	// EXPOSURE
	c = 1.0 - exp(c * -fHdrExposure);

	// GAMMA CORRECTION
	//c = pow(c, 1 / );

	return c;
}

float3 ShowLODSystem(float height) {
	float interpolar = height / (127420 / 2);
	float4 color = float4(interpolar, 0.1, 0.5 - interpolar, 1.0);

	if (interpolar < 0.1 && interpolar > 0.02) {
		return float4(0.3 + interpolar, 0.2 + interpolar, 0.1, 1.0);
	}
	else if (interpolar <= 0.02 && interpolar > 0.002) {
		return float4(interpolar * 50, 0.6, 0.5 - interpolar * 20, 1.0);
	}
	else if (interpolar < 0.002 && interpolar > 0.0001) {
		return float4(0.3 + interpolar * 100, 0.2 + interpolar * 100, 0.4, 1.0);
	}
	else if (interpolar <= 0.0001) {
		return float4(interpolar * 500, 0.6, 0.5 - interpolar * 200, 1.0);
	}
	return color;
}


fixed4 FS(GM_OUTPUT i, uint instanceID : SV_InstanceID) : SV_Target
{
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;
	int xindex;
	float dist = distance(_CameraPosition, float3(0, 0, 0)) - _PlanetInfo.x;
	fixed4 c;
	float uCoor2;
	float spectrum = tex2D(_SpecularMap,float2(uCoor, vCoor)).r;
	c = tex2Dlod(_PlanetTextures, float4(uCoor, vCoor, 0.0, 0));

	float3 calc;

	if (_IsLODActive == 1) {
		calc = calcColor2(i, ShowLODSystem(i.height));
	}
	else {
		calc = calcColor2(i, c.xyz);
	}

	return float4(c.xyz * 2, 1.0);
}