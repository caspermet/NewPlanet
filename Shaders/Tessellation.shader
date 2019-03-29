Shader "Custom/Tessellation" {

	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_HeightTex("HeighMap", 2D) = "white" {}
		_PlanetTextures("Textures", 2DArray) = "" {}
		_Tess("Tessellation", Range(1,32)) = 4
		_DiffuseColor("Diffuse Color", color) = (0.5,0.5,0.5,0.5)
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

			#define PI 3.141592653589793238462643383279 


		float _Tess;
		float4 _DiffuseColor;
		sampler2D _MainTex;
		sampler2D _HeightTex;

		/*****************************************************************
				Planet Info
				x -> planet Radius -> (chunkSize - 1) * MaxScale
				y -> Max terrain height
				********************************************************************/
		float3 _PlanetInfo;

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
			float4 wordPosition : TEXCOORD1;
		};

		struct HS_OUTPUT
		{
			float4 vertex : INTERNALTESSPOS;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
			float4 wordPosition : TEXCOORD1;
		};

		struct DS_OUTPUT
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
			float4 wordPosition : TEXCOORD1;
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

				worldPosition.xyz = (worldPosition.xyz + normalize(worldPosition.xyz) * (tex2Dlod(_HeightTex, float4(uCoor, vCoor, 0.0, 0)) * _PlanetInfo.y));

				o.wordPosition = mul(UNITY_MATRIX_MV, float4(worldPosition, 1.0f));
				o.wordPosition = float4(worldPosition, 1.0f);
				o.vertex = float4(worldPosition, 1.0f);
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
				o.wordPosition = ip[id].wordPosition;

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
				o.wordPosition = ip[0].wordPosition*b.x + ip[1].wordPosition*b.y + ip[2].wordPosition*b.z;
				o.vertex = UnityObjectToClipPos(o.vertex);
				return o;
			}

#endif
			fixed4 FS(DS_OUTPUT i) : SV_Target
			{
				float3 n = normalize(float3(i.wordPosition.x, i.wordPosition.y, i.wordPosition.z));
				float uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
				float vCoor = asin(n.y) / PI - 0.5f;

				float uMap = i.uv.x * 4;
				int vMap = i.uv.y >= 0.5f ? 1 : 2;

				int xindex = int(uMap);

				int index = xindex + (i.uv.y >= 0.5f ? 0 : 4);

				float uCoor2 = (uCoor - (float(xindex) - 1.0f) * 0.25f) * 4;
				float vCoor2 = (vCoor - float(vMap) * 0.5f) * 2;

				//fixed4 c = UNITY_SAMPLE_TEX2DARRAY(_PlanetTextures, float3(float2(uCoor2, vCoor2), index));
				fixed4 c = tex2Dlod(_MainTex, float4(uCoor, vCoor, 0.0, 0));

				fixed4 albedo = c;
		
				return c;

				return c;
			}
			ENDCG
		}
	}
}