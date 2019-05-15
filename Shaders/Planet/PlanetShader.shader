Shader "Planet/PlanetShader" {

	Properties
	{
		_Shininess("Shininess", Range(1, 50)) = 20
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecMap("Specular Map", 2D) = "white" {}
		_PlanetTextures("Textures", 2DArray) = "" {}
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
		
		// všechny proměnné 
		#include "PlanetPropertiesSh.cginc" 

		// Vertex shader 
		#include "PlanetVertexSh.cginc" 

		// Tesselace 
		#include "PlanetTessellation.cginc"

		// Geometry shader a Pixel shader 
		#include "PlanetFragmentSh.cginc"    


	
			ENDCG
		}
	}
}