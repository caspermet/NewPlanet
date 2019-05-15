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

float3		_CameraPosition;
sampler2D	_noiseTexture;
sampler2D	_SpecularMap;
float		fHdrExposure;
float		_Gamma;
int			_IsLODActive;
int			_IsTessellation;


/**********************
buffery for instancing

positionBuffer
		x -> x - souøadnici daného meshe
		y -> y - souøadnici daného meshe
		z -> z - souøadnici daného meshe
		w -> scale daného meshe

directionsBuffer
		x -> x - normála meshe
		y -> y - normála meshe
		z -> z - normála meshe
		w -> rotace daného meshe
******/
StructuredBuffer<float4> positionBuffer;
StructuredBuffer<float4> directionsBuffer;

/********************
HeightMap textures
************************/
sampler2D _PlanetTextures;


/*********************************
Planet Textures in fragment shade
*******************************/
sampler2D _PlanetHeightMap;
sampler2D _PlanetNormalMap;


UNITY_DECLARE_TEX2DARRAY(_SurfaceTexture);

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
	float height : TEXCOORD3;
};

struct HS_OUTPUT
{
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float3 normal2 : NORMAL2;
	float2 uv : TEXCOORD0;
	float4 wordPosition : TEXCOORD1;
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


const static int maxLayerCount = 8;

int layerCount;
float3 baseColours[maxLayerCount];
float baseStartHeights[maxLayerCount];
float baseBlends[maxLayerCount];
float baseColourStrength[maxLayerCount];
float baseTextureScales[maxLayerCount];