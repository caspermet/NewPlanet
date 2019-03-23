Shader "Tessellation Sample" {
	Properties{
		_Tess("Tessellation", Range(1,32)) = 4
		_MainTex("Base (RGB)", 2D) = "white" {}
		_DispTex("Disp Texture", 2D) = "gray" {}
		_NormalMap("Normalmap", 2D) = "bump" {}
		_Displacement("Displacement", Range(0, 1.0)) = 0.3
		_Color("Color", color) = (1,1,1,0)
		_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
		_test("Height", Range(0.0, 90.0)) = 0.5
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 300

			CGPROGRAM
			#pragma surface surf Standard addshadow fullforwardshadows vertex:vert 
			#pragma multi_compile_instancing

			#pragma target 4.6
			#include "Tessellation.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			float _Tess;
			float _test;

			float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2) {
				float minDist = 10.0;
				float maxDist = 50.0;
				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
			}

			sampler2D _DispTex;
			float _Displacement;

			void vert(inout appdata_full v)
			{
				float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
				v.vertex.xyz += v.normal * d;
			}

			struct Input {
				float2 uv_MainTex;
			};

			sampler2D _MainTex;
			sampler2D _NormalMap;
			fixed4 _Color;

			void surf(Input IN, inout SurfaceOutputStandard o) {
				half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
			
				o.Normal = _test;
				//o.Albedo = _test;
			}
			ENDCG
		}
			FallBack "Diffuse"
}