Shader "Custom/Tessellation" {

	Properties
	{
		_Tess("Tessellation", Range(1,32)) = 4
		_DiffuseColor("Diffuse Color", color) = (0.5,0.5,0.5,0.5)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque"  }
		LOD 200

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment FS
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
		#ifdef UNITY_CAN_COMPILE_TESSELLATION
			#pragma hull HS
			#pragma domain DS
		#endif        
		//#pragma multi_compile_fwdbase
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"        

		float _Tess;
		float4 _DiffuseColor;
		sampler2D _MainTex;

		struct APP_OUTPUT
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 uv : TEXCOORD0;
		};
		struct VS_OUTPUT
		{
			float4 vertex : INTERNALTESSPOS;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
			float2 uv1 : TEXCOORD1;
			float2 uv2 : TEXCOORD2;
		};

		struct HS_OUTPUT
		{
			float4 vertex : INTERNALTESSPOS;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
			float2 uv1 : TEXCOORD1;
			float2 uv2 : TEXCOORD2;
		};

		struct DS_OUTPUT
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
			float2 uv1 : TEXCOORD1;
			float2 uv2 : TEXCOORD2;
		};

#ifdef UNITY_CAN_COMPILE_TESSELLATION
			struct HS_CONSTANT_OUTPUT
			{
				float edges[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			HS_CONSTANT_OUTPUT HSConst()
			{
				HS_CONSTANT_OUTPUT o;

				o.edges[0] = _Tess;
				o.edges[1] = _Tess;
				o.edges[2] = _Tess;
				o.inside = _Tess;

				return o;
			}
#endif


			StructuredBuffer<float4> positionBuffer;
			StructuredBuffer<float4> directionsBuffer;


			VS_OUTPUT VS(APP_OUTPUT v, uint instanceID : SV_InstanceID)
			{
				VS_OUTPUT o;


				float4 data = positionBuffer[instanceID];
				float4 transform = directionsBuffer[instanceID];


				o.vertex = v.vertex + float4(data.xyz, 0);
				o.normal = v.normal;
				o.uv = v.uv;
				//o.vertex = UnityObjectToClipPos(o.vertex);
				return o;

			}

#ifdef UNITY_CAN_COMPILE_TESSELLATION

			[UNITY_domain("tri")]
			[UNITY_partitioning("fractional_odd")]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_outputcontrolpoints(3)]
			[UNITY_patchconstantfunc("HSConst")]
			HS_OUTPUT HS(InputPatch<VS_OUTPUT, 3> ip, uint id : SV_OutputControlPointID)
			{
				HS_OUTPUT o;
				o.vertex = ip[id].vertex;
				o.normal = ip[id].normal;
				o.tangent = ip[id].tangent;
				o.uv = ip[id].uv;
				o.uv1 = ip[id].uv1;
				o.uv2 = ip[id].uv2;

				return o;
			}


			[UNITY_domain("tri")]
			DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> ip, float3 b : SV_DomainLocation)
			{
				DS_OUTPUT o;
				o.vertex = ip[0].vertex*b.x + ip[1].vertex*b.y + ip[2].vertex*b.z;
				o.normal = ip[0].normal*b.x + ip[1].normal*b.y + ip[2].normal*b.z;
				o.tangent = ip[0].tangent*b.x + ip[1].tangent*b.y + ip[2].tangent*b.z;
				o.uv = ip[0].uv*b.x + ip[1].uv*b.y + ip[2].uv*b.z;
				o.uv1 = ip[0].uv1*b.x + ip[1].uv1*b.y + ip[2].uv1*b.z;
				o.uv2 = ip[0].uv2*b.x + ip[1].uv2*b.y + ip[2].uv2*b.z;
				o.vertex = UnityObjectToClipPos(o.vertex);
				return o;
			}

#endif
			fixed4 FS(DS_OUTPUT i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}