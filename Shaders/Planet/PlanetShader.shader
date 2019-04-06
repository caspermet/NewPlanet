Shader "Planet/PlanetShader" {

	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_HeightTex("HeighMap", 2D) = "white" {}
		_PlanetTexturesTop("Textures", 2DArray) = "" {}
		_PlanetTexturesBottom("Textures", 2DArray) = "" {}
		_PlanetHeightMapTop("Textures", 2DArray) = "" {}
		_PlanetHeightMapBottom("Textures", 2DArray) = "" {}
		_noiseHeight("minheightNOise", Range(0,1)) = 0
		_textureProfil("texture", int) = 0
		_Tess("Tessellation", Range(0,2)) = 4
		_Tesss("tttt", Range(0,512)) = 4
		_DiffuseColor("Diffuse Color", color) = (0.5,0.5,0.5,0.5)

		[MaterialToggle] _FlipNoise("NoiseMap", Float) = 0



		_Shininess("Shininess", Range(1, 50)) = 20
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecMap("Specular Map", 2D) = "white" {}
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
		float _Tesss;
		float4 _DiffuseColor;
		sampler2D _MainTex;
		sampler2D _HeightTex;
		float _FlipNoise;
		float _noiseHeight;
		int _textureProfil;


		/*********************
		light
		*/
	
		uniform float4 _LightColor0;
		uniform float _Shininess;
		uniform float4 _SpecColor;
		uniform sampler2D _SpecMap;

		float fHdrExposure;
		float _Gamma;

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