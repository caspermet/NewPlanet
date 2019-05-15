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
		x -> x - sou�adnici dan�ho meshe
		y -> y - sou�adnici dan�ho meshe
		z -> z - sou�adnici dan�ho meshe
		w -> scale dan�ho meshe

directionsBuffer
		x -> x - norm�la meshe
		y -> y - norm�la meshe
		z -> z - norm�la meshe
		w -> rotace dan�ho meshe
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