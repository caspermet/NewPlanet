Shader "Unlit/heightmap"
{
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Scale("Scale", float) = 1.0
		_Scale2("Scale", float) = 1.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 20

			CGPROGRAM

			#pragma surface surf Standard fullforwardshadows vertex:vert



			#pragma target 3.0

			sampler2D _MainTex;

			struct Input {
				float2 uv_MainTex;
				float3 worldPos;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float _Scale;
			float _Scale2;

			void vert(inout appdata_full v) {

				float4 wolrldPosition = mul(unity_ObjectToWorld, v.vertex);
				v.vertex.y = tex2Dlod(_MainTex, float4(wolrldPosition.xz / _Scale2, 0, 0)) * 400 / 0.5;
			}


			UNITY_INSTANCING_BUFFER_START(Props)

			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o) {


				float4 wolrldPosition = mul(unity_ObjectToWorld, float4(IN.worldPos, 0));
				fixed4 c = tex2D(_MainTex, wolrldPosition.xz / _Scale2);
				o.Albedo = c.rgb;

				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;

			}
			ENDCG
		}
			FallBack "Diffuse"
}