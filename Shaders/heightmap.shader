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
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows vertex:vert


			// Use shader model 3.0 target, to get nicer looking lighting
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

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o) {
				// Albedo comes from a texture tinted by color

				float4 wolrldPosition = mul(unity_ObjectToWorld, float4(IN.worldPos, 0));
				fixed4 c = tex2D(_MainTex, wolrldPosition.xz / _Scale2);
				o.Albedo = c.rgb;

				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;

			}
			ENDCG
		}
			FallBack "Diffuse"
}