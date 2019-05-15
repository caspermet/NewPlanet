/**********
Geometry shader

***************/

[maxvertexcount(3)]
void geom(triangle DS_OUTPUT IN[3], inout TriangleStream<GM_OUTPUT> tristream)
{
	GM_OUTPUT o;

	for (int i = 0; i < 3; i++)
	{
		o.vertex = IN[i].vertex;
		o.normal = IN[i].normal;
		o.normal2 = IN[i].normal2;

		o.uv = IN[i].uv;
		o.wordPosition = IN[i].wordPosition;
		o.height = IN[i].height;
		tristream.Append(o);
	}
}

double3 filterNormalLoda(double4 uv, double position, double3 normal)
{
	float _HeightmapDimY = 6048;
	float _HeightmapDimX = 6048;
	float n = tex2Dlod(_PlanetHeightMap, float4(uv.x, uv.y + 1.0 / _HeightmapDimY, 0, 0)).x;
	float s = tex2Dlod(_PlanetHeightMap, float4(uv.x, uv.y - 1.0 / _HeightmapDimY, 0, 0)).x;
	float e = tex2Dlod(_PlanetHeightMap, float4(uv.x - 1.0 / _HeightmapDimX, uv.y, 0, 0)).x;
	float w = tex2Dlod(_PlanetHeightMap, float4(uv.x + 1.0 / _HeightmapDimX, uv.y, 0, 0)).x;
	float3 norm = normal;
	float3 temp = norm; //a temporary vector that is not parallel to norm
	if (norm.x == 1)
		temp.y += 0.5;
	else
		temp.x += 0.5;
	//form a basis with norm being one of the axes:
	float3 perp1 = normalize(cross(norm, temp));
	float3 perp2 = normalize(cross(norm, perp1));
	//use the basis to move the normal in its own space by the offset
	float3 normalOffset = 1 * (((n - position) - (s - position)) * perp1 + ((e - position) - (w - position)) * perp2);

	norm += normalOffset;
	norm = normalize(norm);
	return norm;
}


float3 calcColor(GM_OUTPUT input, float3 textureColor) {

	float3 normalDirection = input.normal;

	float3 viewDirection = normalize(_WorldSpaceCameraPos - input.wordPosition.xyz);
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

	// výpoèet difúzní složky
	float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));

	// výpoèet lesklé složky
	float3 spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), 40);

	
	diff.x = diff.x < 0.04 ? 0.04 : diff.x;
	diff.y = diff.y < 0.04 ? 0.04 : diff.y;
	diff.z = diff.z < 0.04 ? 0.04 : diff.z;

	//difuzní + ambientni složka
	float3 c = diff * pow(textureColor, _Gamma);

	// Lesklá složka
	c += spec * diff * pow(tex2D(_SpecMap, input.uv.xy).r, _Gamma);

	c = 1.0 - exp(c * -2);

	c = pow(c, 1.4f );

	return c;
}


/*******
Obarveni dlaždic
*****/
float3 ShowLODSystem(float height) {
	float interpolar = height / (127420 / 2);
	float4 color = float4(interpolar, 0.1, 0.5 - interpolar, 1.0);


	if (interpolar < 0.1 && interpolar > 0.04) {
		return float4(0.4 + interpolar, 0.3 + interpolar * 1.8, interpolar * 2.5 - 0.4 , 1.0);
	}
	else if (interpolar < 0.04 && interpolar > 0.02) {
		return float4(0.2 + interpolar, 1, interpolar * 1 + 0.4, 1.0);
	}
	else if (interpolar <= 0.02 && interpolar > 0.002) {
		return float4(0.5 , 0.2 + interpolar * 20, 0.2 + interpolar * 20, 1.0);
	}
	else if (interpolar < 0.002 && interpolar > 0.0001) {
		return float4(0.3 + interpolar * 50, 0.2 + interpolar * 100, 0.4, 1.0);
	}
	else if (interpolar <= 0.0001) {
		return float4(interpolar * 500, 0.6, 0.5 - interpolar * 200, 1.0);
	}
	return color;
}


fixed4 FS(GM_OUTPUT i, uint instanceID : SV_InstanceID) : SV_Target
{
	// zjištìní uv souøadnic na kouli
	float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
	
	float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	float vCoor = asin(n.y) / PI + 0.5f;

	float3 calc;

	if (_IsLODActive == 1) {
		//vypoèet normály terénu
		float3 vector1 = filterNormalLoda(float4(uCoor, vCoor, 0, 0), i.wordPosition, n);

		// uhel mezi normálou vertexu a normálou pøimo na terénu
		double angle = acos(dot(i.normal, vector1));


		// mode pro zobrazení rùzného barevnosti dlaždic s rozdílnou úrovní detailu
		calc = calcColor(i, ShowLODSystem(i.height) - float3(angle *1.4, angle*1.4, angle*1.4));
	}
	else {
		fixed4 color = tex2Dlod(_PlanetTextures, float4(uCoor, vCoor, 0.0, 0));
		calc = calcColor(i, color.xyz);
	}

	return float4(calc, 1.0);
}