// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Planet/Planet"
{
	Properties
	{
		_MainTex("Diffuse Map", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_SpecMap("Specular Map", 2D) = "white" {}
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Range(1, 50)) = 20
		_LightMap("Night lights Map", 2D) = "black" {}
		_LightMapIntensity("Night lights Intensity", Float) = 1.0
		_CloudMap("Cloud Map", 2D) = "black" {}
		_CloudSpeed("Cloud speed", Float) = 0.01
		_CloudStrength("Cloud strength", Range(0, 5)) = 1.0
		_CloudShadowsStrength("Cloud shadows strength", Range(0, 1)) = 0.0
		_Color1("Color 1", Color) = (0, 255, 31, 0)
		_Color2("Color 2", Color) = (226, 183, 25, 0)
		_AirGlowStrength("Air Glow strength", Range(0, 2)) = 0.2
	}
		SubShader
		{
			Tags
			{
				"LightMode" = "ForwardBase"
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
			}

			Pass
			{
				Cull Back
				ZWrite On

				CGPROGRAM
				#include "UnityCG.cginc"

				#include "PlanetShared.cginc"
				#pragma vertex vert  
				#pragma fragment frag
				#pragma target 3.0
				#pragma multi_compile MOBILE_ON MOBILE_OFF
				#pragma multi_compile ATMO_ON ATMO_OFF

				uniform float4 _LightColor0;

				struct vertexInput
				{
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD0;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
				};

				struct vertexOutput {
					float4	pos : SV_POSITION;
					float4	posWorld : TEXCOORD0;
					// position of the vertex (and fragment) in world space 
					float4	tex : TEXCOORD1;
					float3	tangentWorld : TEXCOORD2;
					float3	normalWorld : TEXCOORD3;
					float3	binormalWorld : TEXCOORD4;
					float3	c0 : COLOR0;
					float3	c1 : COLOR1;
				};

				vertexOutput vert(vertexInput input)
				{
					vertexOutput output;

					float4x4 modelMatrix = unity_ObjectToWorld;
					float4x4 modelMatrixInverse = unity_WorldToObject;

					output.tangentWorld = normalize(
						mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
					output.normalWorld = normalize(
						mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
					output.binormalWorld = normalize(
						cross(output.normalWorld, output.tangentWorld)
						* input.tangent.w); // tangent.w is specific to Unity

					output.posWorld = mul(modelMatrix, input.vertex);
					output.tex = input.texcoord;
					output.pos = UnityObjectToClipPos(input.vertex);

					return output;
				}

				// fragment shader for pass 2 without ambient lighting 
				float4 frag(vertexOutput input) : COLOR
				{
					float w = 0;

				// SHADOW HANDLING
			
				// in principle we have to normalize tangentWorld,
				// binormalWorld, and normalWorld again; however, the  
				// potential problems are small since we use this 
				// matrix only to compute "normalDirection", 
				// which we normalize anyways

				float3 localCoords;

				localCoords = float3(0.0, 0.0, 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				// approximation without sqrt:  localCoords.z = 
				// 1.0 - 0.5 * dot(localCoords, localCoords);


				float3x3 local2WorldTranspose = float3x3(
					input.tangentWorld,
					input.binormalWorld,
					input.normalWorld);
				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

				float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDirection;

				lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				float3 diff = _LightColor0.rgb * max(0, dot(lightDirection, normalize(normalDirection + (0.2 * lightDirection))));
				float3 spec;

				spec = _SpecColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

				// diffuse without normal for cloud (cloud hide the relief of the planet)
				float3 diffWn = _LightColor0.rgb * max(0, dot(lightDirection, normalize(input.normalWorld + (0.2 * lightDirection))));

				// DIFFUSE + NORMAL

				float3 c = diff * pow(tex2D(_MainTex, input.tex.xy), _Gamma);
				// SPECULAR
				c += spec * diff * pow(tex2D(_SpecMap, input.tex.xy).r, _Gamma);
				

				// EXPOSURE
				c = 1.0 - exp(c * -fHdrExposure);
				// GAMMA CORRECTION
				c = pow(c, 1 / _Gamma);
				return float4(c, 1.0);
			}
		ENDCG
		}

		}
}