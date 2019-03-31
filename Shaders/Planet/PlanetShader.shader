Shader "Planet/PlanetShader" {

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
			#define PI 3.141592653589793238462643383279 

		float _Tess;
		float4 _DiffuseColor;
		sampler2D _MainTex;
		sampler2D _HeightTex;

		//#pragma multi_compile_fwdbase

		#include "UnityCG.cginc"
		#include "Tessellation.cginc"

		#include "PlanetVertexSh.cginc" 
		#include "PlanetTessellation.cginc" 
		#include "PlanetFragmentSh.cginc"    


	
			ENDCG
		}
	}
}