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
		o.angle = IN[i].angle;
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


float3 calcColor2(GM_OUTPUT input, float3 textureColor, float3 vector1) {

	float3 normalDirection = input.normal;
	float3 normalDirection2 = vector1;

	float3 viewDirection = normalize(_WorldSpaceCameraPos - input.wordPosition.xyz);
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

	//float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
	float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection2 + (0.2 * lightDirection))));
	float3 spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), 40);

	// DIFFUSE + NORMAL
	diff.x = diff.x < 0.008 ? 0.008 : diff.x;
	diff.y = diff.y < 0.008 ? 0.008 : diff.y;
	diff.z = diff.z < 0.008 ? 0.008 : diff.z;

	//diff =  lerp(diff, diff2, 0.5);

	float3 c = diff * pow(textureColor, _Gamma);

	// SPECULAR
	c += spec * diff * pow(tex2D(_SpecMap, input.uv.xy).r, _Gamma);

	// EXPOSURE
	c = 1.0 - exp(c * -3);

	c = pow(c, 1.6f );

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
	//float spectrum = tex2D(_SpecularMap,float2(uCoor, vCoor)).r;
	//float spectrum = tex2Dlod(_SpecMap, float4(uCoor, vCoor, , 0.0, 0)).x;

	c = tex2Dlod(_PlanetTextures, float4(uCoor, vCoor, 0.0, 0));

	float3 vector1 = filterNormalLoda(float4(uCoor, vCoor, 0, 0), i.wordPosition, n);
	double angle = acos(dot(i.normal, vector1));

	float3 calc;


	if (_IsLODActive == 1) {
		calc = calcColor2(i, ShowLODSystem(i.height), n);
	}
	else {
	if (dist < float(_PlanetInfo.x)  * 0.2f) {
			float ii = 1;
			float maxBlender = 0.7f;
			float minBlender = 1 - maxBlender;

			if (dist < float(_PlanetInfo.x)  * 0.05f) {
				ii = maxBlender;
			}
			else {
				ii = ((dist - float(_PlanetInfo.x)  * 0.05f) * 0.4f) / (float(_PlanetInfo.x)  * 0.15f) + maxBlender;
			}
			fixed4 textureColor;

		/*	if (angle < 0.02) {
				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, ii);
			}
			else if (angle < 0.03) {
			//	c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 0)), c, (1 - maxBlender) / (0.03 - 0.02) * (angle - 0.02f) + maxBlender);
			}*/
		/*	else if (angle < 0.1) {
				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 1)), c, ii);
			}
			else if (angle < 0.12) {
				c = lerp(UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), 1)), c, (1 - maxBlender) / (0.12 - 0.1) * (angle - 0.1f) + maxBlender);
			}*/ 


			/*for (int x = 0;x < 1; x++)
			{
				
				if (baseStartHeights[x] >= angle) {
					textureColor = UNITY_SAMPLE_TEX2DARRAY(_SurfaceTexture, float3(float2(uCoor * _PlanetInfo.y, vCoor * _PlanetInfo.y), x));
					//float min = angle / baseStartHeights[x];
					float blender;
					if (baseBlends[x] > angle) {
						blender = maxBlender;
					}
					else {
						float s = baseStartHeights[x] - baseBlends[x];
						float d = (angle - baseBlends[x] + 0.0001);
						float a = d / s;
						 blender = (1 - maxBlender) / (0.07f - s + 0.0001) * (angle - s + 0.0001) + maxBlender;
					}
					c = lerp( textureColor, c, ii);
				}

			}*/
			//c = lerp(textureColor, c, 0.9);
			
		}

		calc = calcColor2(i, c.xyz, n);
		//calc = calc * 1.5f;
	}


	//return float4(angle, angle, angle, 1.0f);




	return float4(calc, 1.0);
}