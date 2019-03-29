Shader "Unlit/test"
{
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_HeightTex("HeighMap", 2D) = "white" {}
		_PlanetTextures("Textures", 2DArray) = "" {}
		_Tess("Tessellation", int) = 4
		_BlendAlpha("Blend Alpha", float) = 0
	}
		SubShader{
			 
			Pass {

				Tags {"LightMode" = "ForwardBase"}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
		
				#pragma target 4.6

				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"
				#include "AutoLight.cginc"
				 #include "Tessellation.cginc"

				#define PI 3.141592653589793238462643383279 

				sampler2D _MainTex;
				sampler2D _HeightTex;
				int _Tess;

				UNITY_DECLARE_TEX2DARRAY(_PlanetTextures);


				/*****************************************************************
				Planet Info
				x -> planet Radius -> (chunkSize - 1) * MaxScale
				y -> Max terrain height
				********************************************************************/
				float3 _PlanetInfo;

			#if SHADER_TARGET >= 45
				StructuredBuffer<float4> positionBuffer;
				StructuredBuffer<float4> directionsBuffer;
			#endif



				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldPosition : TEXCOORD5;
					float2 uv_HeightTex : TEXCOORD0;
					float3 ambient : TEXCOORD1;
					float3 diffuse : TEXCOORD2;
					float3 color : TEXCOORD3;

					SHADOW_COORDS(4)
				};


				inline float2 RadialCoords(float3 a_coords)
				{
					float3 a_coords_n = normalize(a_coords);
					float lon = atan2(a_coords_n.z, a_coords_n.x);
					float lat = acos(a_coords_n.y);
					float2 sphereCoords = float2(lon, lat) * (1.0 / PI);
					return float2(sphereCoords.x * 0.5 + 0.5, 1 - sphereCoords.y);

				}


				v2f vert(appdata_full v, uint instanceID : SV_InstanceID)
				{
				#if SHADER_TARGET >= 45
					float4 data = positionBuffer[instanceID];
					float4 transform = directionsBuffer[instanceID];
				#else
					float4 data = 0;
					float4 transform = 0;
				#endif

					float4 pos = v.vertex;

					if (transform.x != 0) {
						v.vertex.y = mul(transform.x, pos.z);
						v.vertex.z = 0;
					}
					else if (transform.y != 0) {
						v.vertex.y = mul(transform.y, pos.x);
						v.vertex.x = 0;
					}
					else if (transform.z == -1) {
						v.vertex.x = -pos.x;
					}			

					float3 localPosition = v.vertex.xyz * data.w;
					float3 worldPosition = data.xyz + localPosition;
					float3 worldNormal = v.normal;


					float x = worldPosition.x / _PlanetInfo.x;;
					float y = worldPosition.y / _PlanetInfo.x;;
					float z = worldPosition.z / _PlanetInfo.x;;

					float dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
					float dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
					float dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));

					worldPosition.xyz = float3(dx, dy, dz) * _PlanetInfo.x;;
				
					float3 n = normalize(float3(worldPosition.x, worldPosition.y, worldPosition.z));
					float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
					float vCoor = asin(n.y) / PI - 0.5f;
					//float2 equiUV = RadialCoords(v.normal);

					worldPosition.xyz = (worldPosition.xyz + normalize(worldPosition.xyz) * (tex2Dlod(_HeightTex, float4(uCoor, vCoor, 0.0, 0)) * _PlanetInfo.y)) ;

					float3 ndotl = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
					float3 ambient = ShadeSH9(float4(worldNormal, 1.0f));
					float3 diffuse = (ndotl * _LightColor0.rgb);

					v2f o;
					o.worldPosition = worldPosition;
					o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
					o.uv_HeightTex = float2(uCoor, vCoor);
			
					o.ambient = ambient;
					o.diffuse = diffuse;
					//o.color = color;
					TRANSFER_SHADOW(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 n = normalize(float3(i.worldPosition.x, i.worldPosition.y, i.worldPosition.z));
					float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
					float vCoor = asin(n.y) / PI - 0.5f;
					
					float uMap = i.uv_HeightTex.x * 4;
					int vMap = i.uv_HeightTex.y >= 0.5f ? 1 : 2;

					int xindex = int(uMap);			

					int index = xindex + (i.uv_HeightTex.y >= 0.5f ? 0 : 4);

					float uCoor2 = (uCoor - (float(xindex) - 1.0f) * 0.25f) * 4;
					float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;

					//fixed4 c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTextures, float3(float2(uCoor2, vCoor2), index));
					fixed4 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

					fixed shadow = SHADOW_ATTENUATION(i);
					fixed4 albedo = c;
					float3 lighting = i.diffuse * shadow + i.ambient;
					fixed4 output = fixed4(albedo.rgb * i.color * lighting, albedo.w);
					UNITY_APPLY_FOG(i.fogCoord, output);
					return c;

				}

				ENDCG
			}
	}
}