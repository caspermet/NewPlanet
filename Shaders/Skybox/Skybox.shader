﻿Shader "Skybox/blender" {
	Properties{
		_Tint("Tint Color", Color) = (.5, .5, .5, .5)
		[Gamma] _Exposure("Exposure", Range(0, 8)) = 1.0
		_Rotation("Rotation", Range(0, 360)) = 0
		_blender("blendern", Range(0, 1)) = 0
		[NoScaleOffset] _FrontTex("Front [+Z]   (HDR)", 2D) = "grey" {}
		[NoScaleOffset] _BackTex("Back [-Z]   (HDR)", 2D) = "grey" {}
		[NoScaleOffset] _LeftTex("Left [+X]   (HDR)", 2D) = "grey" {}
		[NoScaleOffset] _RightTex("Right [-X]   (HDR)", 2D) = "grey" {}
		[NoScaleOffset] _UpTex("Up [+Y]   (HDR)", 2D) = "grey" {}
		[NoScaleOffset] _DownTex("Down [-Y]   (HDR)", 2D) = "grey" {}
		_blenderColor("Color 1", Color) = (0, 0, 0)
	}

		SubShader{
			Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
			Cull Off ZWrite Off

			CGINCLUDE
			#include "UnityCG.cginc"

			half4 _Tint;
			half _Exposure;
			float _Rotation;
			float _blender;
			float4 _blenderColor;
			uniform float4 _LightColor0;

			/*****************************************************************
				Planet Info
				x -> planet Radius ->  MaxScale / 2
				y -> Max terrain height
			********************************************************************/
		//	float3 _PlanetInfo;


			float3 RotateAroundYInDegrees(float3 vertex, float degrees)
			{
				float alpha = degrees * UNITY_PI / 180.0;
				float sina, cosa;
				sincos(alpha, sina, cosa);
				float2x2 m = float2x2(cosa, -sina, sina, cosa);
				return float3(mul(m, vertex.xz), vertex.y).xzy;
			}

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert(appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
				o.vertex = UnityObjectToClipPos(rotated);
				o.texcoord = v.texcoord;
				return o;
			}

			float3 calcColor2(float3 textureColor, float blenderIndex) {

				float3 normalDirection = _WorldSpaceCameraPos;

				float3 viewDirection = normalize(_WorldSpaceCameraPos );
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				float3 c = float3(1, 1, 1) - float3(1,1,1) * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
				blenderIndex = blenderIndex + 0.3 - c.x * 1.2;
				if (blenderIndex < 0) {
					blenderIndex = 0;
				}
				else if (blenderIndex > 1) {
					blenderIndex = 1;
				}
				
				c = lerp(textureColor, _blenderColor, blenderIndex);
				
				return c;
			}


			half4 skybox_frag(v2f i, sampler2D smp, half4 smpDecode)
			{
				float dist = (distance(float3(0, 0, 0), _WorldSpaceCameraPos)) - 63710;
				float blenderIndex = 1;

				if ((63710 * 0.2f) > dist) {
					float smallDistance = (63710 * 0.1f);
					if (smallDistance > dist) {
						blenderIndex = 1;
					}
					else {
						dist = (63710 * 0.2f) - dist;
						blenderIndex = dist / (smallDistance);
					}

					half4 tex = tex2D(smp, i.texcoord);
					half3 c = DecodeHDR(tex, smpDecode);
		
					c = calcColor2(c, blenderIndex);
					c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
					c *= _Exposure;
					return half4(c, 1);
				} 
				else {
					half4 tex = tex2D(smp, i.texcoord);
					half3 c = DecodeHDR(tex, smpDecode);
					c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
					c *= _Exposure;
					return half4(c, 1);
				}
			}
			ENDCG

			Pass {
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _FrontTex;
				half4 _FrontTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_FrontTex, _FrontTex_HDR); }
				ENDCG
			}
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _BackTex;
				half4 _BackTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_BackTex, _BackTex_HDR); }
				ENDCG
			}
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _LeftTex;
				half4 _LeftTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_LeftTex, _LeftTex_HDR); }
				ENDCG
			}
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _RightTex;
				half4 _RightTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_RightTex, _RightTex_HDR); }
				ENDCG
			}
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _UpTex;
				half4 _UpTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_UpTex, _UpTex_HDR); }
				ENDCG
			}
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				sampler2D _DownTex;
				half4 _DownTex_HDR;
				half4 frag(v2f i) : SV_Target { return skybox_frag(i,_DownTex, _DownTex_HDR); }
				ENDCG
			}
		}
}