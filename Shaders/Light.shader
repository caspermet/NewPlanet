// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "unityCook/rim lighting"
{
	Properties{
		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor("specular color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess("Shiniess", float) = 10
		_RimColor("Rim color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower("Rim Power", Range(0.1,10.0)) = 3.0
	}
		SubShader{
			Pass{
			Tags{ "LightMode" = "ForwardBase"}
			 CGPROGRAM
			#pragma vertex vert
			#pragma fragment fraq

			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _Shininess;
			uniform float _RimPower;

			uniform float4 _LightColor0;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXTOORD0;
				float3 normalDir : TEXTOORD1;
			};

			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 fraq(vertexOutput i) : COLOR{
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float atten = 1.0;

				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float rimLighting = atten * _LightColor0.xyz  * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
				float3 lightFinal = rimLighting + diffuseReflection + specularReflection;// +UNITY_LIGHTMODEL_AMBIENT.rgb;

				return float4(lightFinal * _Color.xyz, 1.0);
			}
				ENDCG
}
	}
		//fallback "Specular"
}
