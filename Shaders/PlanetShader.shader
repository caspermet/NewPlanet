// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Instanced/PlanetShader" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader{

			Pass {

				Tags {"LightMode" = "ForwardBase"}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				#pragma target 4.5

				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"
				#include "AutoLight.cginc"

				sampler2D _MainTex;

			#if SHADER_TARGET >= 45
				StructuredBuffer<float4> positionBuffer;
				StructuredBuffer<float4> directionsBuffer;
			#endif

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv_MainTex : TEXCOORD0;
					float3 ambient : TEXCOORD1;
					float3 diffuse : TEXCOORD2;
					float3 color : TEXCOORD3;
					SHADOW_COORDS(4)
				};


				v2f vert(appdata_full v, uint instanceID : SV_InstanceID)
				{
					float4 data = positionBuffer[instanceID];
					float4 transform = directionsBuffer[instanceID];

					float3 localPosition = v.vertex.xyz * data.w;
					float3 worldPosition = data.xyz + localPosition;
					float3 worldNormal = v.normal;

					float3 pos = worldPosition;

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

					v2f o;
					o.pos = v.vertex;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv_MainTex);
					return col;
				}

				ENDCG
			}
	}
}