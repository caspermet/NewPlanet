Shader "Planet/PlanetShader" {

	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_HeightTex("HeighMap", 2D) = "white" {}		
		_noiseHeight("minheightNOise", Range(0,1)) = 0

		_Tess("Tessellation", Range(0,2)) = 4
		_Tesss("tttt", Range(0,512)) = 4
		[MaterialToggle] _FlipNoise("NoiseMap", Float) = 0
		_Shininess("Shininess", Range(1, 50)) = 20
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecMap("Specular Map", 2D) = "white" {}
		_PlanetTexturesTop("Textures", 2DArray) = "" {}
		_PlanetTexturesBottom("Textures", 2DArray) = "" {}
		_PlanetHeightMapTop("Textures", 2DArray) = "" {}
		_PlanetHeightMapBottom("Textures", 2DArray) = "" {}

		_TessMin("Tessellation", Range(1,5)) = 1
		_TessMax("Tessellation", Range(1,5)) = 1
		_rotate("rotate", Range(0,360)) = 0

		_textureblend("bluer Texture", Range(0,10)) = 1


			/**********************
			Whater
			************/
		_WaterColor(" Color", Color) = (1,1,1,1)
		_WaterMainTex("Texture", 2D) = "white" {}
		[NoScaleOffset] _WaterFlowMap("Flow (RG, A noise)", 2D) = "black" {}
		[NoScaleOffset] _WaterNormalMap("Normals", 2D) = "bump" {}
				[NoScaleOffset] _DerivHeightMap("Deriv (AG) Height (B)", 2D) = "black" {}
		_WaterTiling("Tiling", Float) = 1
		_WaterSpeed("Speed", Float) = 1
		_WaterFlowStrength("Flow Strength", Float) = 1
		_WaterFlowOffset("Flow Offset", Float) = 0

			_Value("gamma", Float) = 1
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
			#pragma geometry geom
		#ifdef UNITY_CAN_COMPILE_TESSELLATION
			#pragma hull HS
			#pragma domain DS

		#endif
			#define PI 3.141592653589793238462643383279 

		

		//#pragma multi_compile_fwdbase

		#include "UnityCG.cginc"
		#include "Tessellation.cginc"

		#include "PlanetPropertiesSh.cginc" 
		#include "PlanetVertexSh.cginc" 
		#include "PlanetTessellation.cginc" 
		//#include "PlanetGeometrySh.cginc" 
		#include "PlanetFragmentSh.cginc"    


	
			ENDCG
		}
	}
}