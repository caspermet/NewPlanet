float _Tess;
float _TessMin;
float _TessMax;
float _Tesss;
sampler2D _MainTex;
sampler2D _HeightTex;
float _FlipNoise;
float _noiseHeight;
float _rotate;
float _textureblend;

/**************
water
*****************/

sampler2D _WaterMainTex, _WaterFlowMap, _WaterNormalMap, _DerivHeightMap;;
float _WaterTiling, _WaterSpeed, _WaterFlowStrength, _WaterFlowOffset, _Value;
fixed4 _WaterColor;

/*********************
light
*/

uniform float4 _LightColor0;
uniform float _Shininess;
uniform float4 _SpecColor;
uniform sampler2D _SpecMap;


/****************
Variablec from scripts
************/

float3 _CameraPosition;
sampler2D _noiseTexture;
sampler2D _SpecularMap;
float fHdrExposure;
float _Gamma;
int _IsLODActive;


/**********************
buffery for instancing
***************/
StructuredBuffer<float4> positionBuffer;
StructuredBuffer<float4> directionsBuffer;

/********************
HeightMap textures
************************/
sampler2D _PlanetTextures;
/*
UNITY_DECLARE_TEX2DARRAY(_PlanetHeightMapTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetHeightMapBottom);*/

/*********************************
Planet Textures in fragment shade
*******************************/
sampler2D _PlanetHeightMap;
sampler2D _PlanetNormalMap;

/*
UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesTop);
UNITY_DECLARE_TEX2DARRAY(_PlanetTexturesBottom);
UNITY_DECLARE_TEX2DARRAY(_SurfaceTexture);*/

/*****************************************************************
Planet Info
		x -> planet Radius ->  MaxScale / 2
		y -> Max terrain height
********************************************************************/
float3 _PlanetInfo;



/************************************
Shader struct
***************************/

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
	float3 normal2 : NORMAL2;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float tess : TEXCOORD2;
	float height : TEXCOORD3;
};

struct HS_OUTPUT
{
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float3 normal2 : NORMAL2;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float tess : TEXCOORD2;
	float height : TEXCOORD3;
};

struct DS_OUTPUT
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float3 normal2 : NORMAL2;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float height : TEXCOORD2;
};
struct GM_OUTPUT
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float3 normal2 : NORMAL2;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
	float height : TEXCOORD2;
};