Shader "Instanced/Terrain" {
	Properties{
		_HeightTex("Texture", 2D) = "white" {}
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_PlanetInf("height", float) = 1
		_Textures("Textures", 2DArray) = "" {}
		_PlanetTextures("Textures", 2DArray) = "" {}
		_Tess("Tessellation", Range(1,32)) = 4

	}
		SubShader{
			Tags { "RenderType" = "Opaque"  }
			LOD 300

			CGPROGRAM

			#pragma surface surf Standard addshadow fullforwardshadows vertex:vert
			#pragma multi_compile_instancing
			#pragma instancing_options procedural:setup
			#pragma target 4.6
			#include "Tessellation.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#define PI 3.141592653589793238462643383279 
		

			sampler2D _HeightTex;
			sampler2D _MainTex;

			int _TexturesArrayLength;
			float _TexturesArray[20];

		/*****************************************************************
			Planet Info
			x -> planet Radius -> (chunkSize - 1) * MaxScale
			y -> Max terrain height
			********************************************************************/
			float3 _PlanetInfo;

			UNITY_DECLARE_TEX2DARRAY(_Textures);
			UNITY_DECLARE_TEX2DARRAY(_PlanetTextures);

			struct Input {	
				float3 worldPos;
			};

			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
			StructuredBuffer<float4> positionBuffer;
			StructuredBuffer<float4> directionsBuffer;		
			#endif

			void setup()
			{
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
					float4 data = positionBuffer[unity_InstanceID];
					unity_ObjectToWorld._11_21_31_41 = float4(data.w, 0, 0, 0);
					unity_ObjectToWorld._12_22_32_42 = float4(0, data.w, 0, 0);
					unity_ObjectToWorld._13_23_33_43 = float4(0, 0, data.w, 0);
					unity_ObjectToWorld._14_24_34_44 = float4(data.x, data.y, data.z, 1);
					unity_WorldToObject = unity_ObjectToWorld;
					unity_WorldToObject._14_24_34 *= -1 /data.w;
					unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
				#endif
				}


			void vert(inout appdata_full v) {

		
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED

				float4 transform = directionsBuffer[unity_InstanceID];
				float4 data = positionBuffer[unity_InstanceID];
				float4 pos = v.vertex;

				if (transform.x != 0) {
					v.vertex.y = mul(transform.x, pos.z);
					v.vertex.z = 0;
				}
				else if (transform.y != 0) {
					v.vertex.y = mul(transform.y, pos.x);
					v.vertex.x = 0;
				}
				else if(transform.z == -1){						
					v.vertex.x = -pos.x;
				}
				v.vertex = mul(unity_ObjectToWorld, v.vertex);


				float x = v.vertex.x / _PlanetInfo.x;
				float y = v.vertex.y / _PlanetInfo.x;
				float z = v.vertex.z / _PlanetInfo.x;
				
				float dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
				float dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
				float dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));
				
				v.vertex.xyz = float3(dx, dy, dz) * _PlanetInfo.x;
				float4 wolrldPosition = v.vertex;

				float3 n = normalize(float3(wolrldPosition.x, wolrldPosition.y, wolrldPosition.z));
				float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5;
				float vCoor = n.y * 0.5 + 0.5;
		
				v.vertex.xyz = (v.vertex.xyz + normalize(v.vertex.xyz) * (tex2Dlod(_HeightTex, float4(uCoor, vCoor, 0, 0)) * _PlanetInfo.x));
				
				v.vertex = mul(unity_WorldToObject, v.vertex); 
						
			#endif
			}
			float _Tess;
			float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2) {
				float minDist = 10.0;
				float maxDist = 25.0;
				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
			}

			void surf(Input IN, inout SurfaceOutputStandard o) {		
				float4 wolrldPosition = mul(unity_ObjectToWorld, float4(IN.worldPos, 0));

				float3 n = normalize(float3(wolrldPosition.x, wolrldPosition.y, wolrldPosition.z));
				float uu = atan2(n.z, n.x) / (2 * PI) + 0.5;
				float vv = n.y * 0.5 + 0.5;
				float uMap = uu * 4;
				
				int xindex = int(uMap);
				int vMap = vv >= 0.5f ? 1 : 2;

				int index = xindex + (vv >= 0.5f ? 0 : 4);

				float uCoor = (uu - (float(xindex) - 1.0f) * 0.25f) * 4;
				float vCoor = (vv - float(vMap) * 0.5f) * 2;
				
				//fixed4 c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTextures, float3(float2(uCoor, vCoor), index));
				fixed4 c = tex2D(_MainTex, float2(uu,vv));			
				o.Albedo = c.rgb;
				o.Alpha = 1;
			}
			ENDCG
		}
			FallBack "Diffuse"
}