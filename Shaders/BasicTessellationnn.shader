// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BasicTessellation" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Offset("Offset", Float) = 10
		_Tess("Tessellation", Float) = 2
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			Pass {

				CGPROGRAM
				#pragma vertex MyTessellationVertexProgram
				#pragma fragment frag
				#pragma hull tessBase
				#pragma domain MyDomainProgram
				#pragma target 4.6
				#include "UnityCG.cginc"

				#define INTERNAL_DATA			

				sampler2D _MainTex;

				float4 _MainTex_ST;
				float _Offset;
				float _Tess;

				struct v2f {
					float4 pos : SV_POSITION;
					float2 texcoord : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				#ifdef UNITY_CAN_COMPILE_TESSELLATION

				struct inputControlPoint {
					float4 position : WORLDPOS;
					float4 texcoord : TEXCOORD0;
					float4 tangent : TANGENT;
					float3 normal : NORMAL;
				};

				struct outputControlPoint {
					float3 position : BEZIERPOS;
				};

				struct outputPatchConstant {
					float edges[3]        : SV_TessFactor;
					float inside : SV_InsideTessFactor;

					float3 vTangent[4]    : TANGENT;
					float2 vUV[4]         : TEXCOORD;
					float3 vTanUCorner[4] : TANUCORNER;
					float3 vTanVCorner[4] : TANVCORNER;
					float4 vCWts          : TANWEIGHTS;
				};

				struct TessellationControlPoint {
					float4 vertex : INTERNALTESSPOS;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 uv : TEXCOORD0;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
				};

				struct TessellationFactors {
					float edge[3] : SV_TessFactor;
					float inside : SV_InsideTessFactor;
				};

				TessellationFactors MyPatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch) {
					TessellationFactors f;
					f.edge[0] = 1;
					f.edge[1] = 1;
					f.edge[2] = 1;
					f.inside = 1;
					return f;
				}


				// tessellation hull shader
				[UNITY_domain("tri")]
				[UNITY_outputcontrolpoints(3)]
				[UNITY_outputtopology("triangle_cw")]
				[UNITY_partitioning("integer")]
				[UNITY_patchconstantfunc("MyPatchConstantFunction")]
				TessellationControlPoint tessBase(InputPatch<TessellationControlPoint,3> v, uint id : SV_OutputControlPointID) {
					return v[id];
				}
		
				#endif // UNITY_CAN_COMPILE_TESSELLATION

				TessellationControlPoint MyTessellationVertexProgram(appdata_full v) {
					TessellationControlPoint p;
					p.vertex = v.vertex;
					p.normal = v.normal;
					p.tangent = v.tangent;
					p.uv = v.texcoord;
					p.uv1 = v.texcoord1;
					p.uv2 = v.texcoord2;
					return p;
				}


				#ifdef UNITY_CAN_COMPILE_TESSELLATION

				[UNITY_domain("tri")]
				TessellationControlPoint  MyDomainProgram(
					TessellationFactors factors,
					OutputPatch<TessellationControlPoint, 3> vi,
					float3 bary : SV_DomainLocation) {

					appdata_full v;

					v.vertex   =  vi[0].vertex*  bary.x + vi[1].vertex*  bary.y + vi[2].vertex*  bary.z;
					v.tangent  =  vi[0].tangent *bary.x + vi[1].tangent *bary.y + vi[2].tangent * bary.z;
					v.normal   =  vi[0].normal  *bary.x + vi[1].normal  *bary.y + vi[2].normal *bary.z;
					v.texcoord =  vi[0].uv *     bary.x + vi[1].uv *     bary.y + vi[2].uv *    bary.z;
					v.texcoord1 = vi[0].uv1 *    bary.x + vi[1].uv1 *    bary.y + vi[2].uv1   * bary.z;
					v.texcoord2 = vi[0].uv2 *    bary.x + vi[1].uv2 *    bary.y + vi[2].uv2   * bary.z;

					TessellationControlPoint o  = MyTessellationVertexProgram(v);

					return o;
				}

			#endif // UNITY_CAN_COMPILE_TESSELLATION



				float4 frag(in v2f IN) :COLOR{
					return tex2D(_MainTex, IN.texcoord);
				}

			ENDCG
			}
		}
}