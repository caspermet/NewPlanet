// Upgrade NOTE: replaced 'defined FOG_COMBINED_WITH_WORLD_POS' with 'defined (FOG_COMBINED_WITH_WORLD_POS)'

Shader "Tessellation Sample" {
	Properties{
		_Tess("Tessellation", Range(1,32)) = 4
		_MainTex("Base (RGB)", 2D) = "white" {}
		_DispTex("Disp Texture", 2D) = "gray" {}
		_NormalMap("Normalmap", 2D) = "bump" {}
		_Displacement("Displacement", Range(0, 1.0)) = 0.3
		_Color("Color", color) = (1,1,1,0)
		_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 300

			// ---- forward rendering base pass:
			Pass {
				Name "FORWARD"
				Tags { "LightMode" = "ForwardBase" }

		CGPROGRAM
			// compile directives
			#pragma vertex tessvert_surf
			#pragma fragment frag_surf
			#pragma hull hs_surf
			#pragma domain ds_surf
			#pragma target 4.6
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase noshadowmask nodynlightmap nolightmap
			#include "HLSLSupport.cginc"
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			// -------- variant for: <when no other keywords are defined>

					
							// Surface shader code generated based on:
							// vertex modifier: 'disp'
							// writes to per-pixel normal: YES
							// writes to emission: no
							// writes to occlusion: no
							// needs world space reflection vector: no
							// needs world space normal vector: no
							// needs screen space position: no
							// needs world space position: no
							// needs view direction: no
							// needs world space view direction: no
							// needs world space position for lighting: YES
							// needs world space view direction for lighting: YES
							// needs world space view direction for lightmaps: no
							// needs vertex color: no
							// needs VFACE: no
							// passes tangent-to-world matrix to pixel shader: YES
							// reads from normal: no
							// 1 texcoords actually used
							//   float2 _MainTex
							#include "UnityCG.cginc"
							//Shader does not support lightmap thus we always want to fallback to SH.
							#undef UNITY_SHOULD_SAMPLE_SH
							#define UNITY_SHOULD_SAMPLE_SH (!defined(UNITY_PASS_FORWARDADD) && !defined(UNITY_PASS_PREPASSBASE) && !defined(UNITY_PASS_SHADOWCASTER) && !defined(UNITY_PASS_META))
							#include "Lighting.cginc"
							#include "AutoLight.cginc"

							#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
							#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
							#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

							// Original surface shader snippet:
							#line 13 ""
							#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
							#endif
							/* UNITY: Original start of shader */
										//#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
										//#pragma target 4.6
										#include "Tessellation.cginc"

										struct appdata {
											float4 vertex : POSITION;
											float4 tangent : TANGENT;
											float3 normal : NORMAL;
											float2 texcoord : TEXCOORD0;
										};

										float _Tess;

										float4 tessDistance(appdata v0, appdata v1, appdata v2) {
											float minDist = 10.0;
											float maxDist = 25.0;
											return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
										}

										sampler2D _DispTex;
										float _Displacement;

										void disp(inout appdata v)
										{
											float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
											v.vertex.xyz += v.normal * d;
										}

										struct Input {
											float2 uv_MainTex;
										};

										sampler2D _MainTex;
										sampler2D _NormalMap;
										fixed4 _Color;

										void surf(Input IN, inout SurfaceOutput o) {
											half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
											o.Albedo = c.rgb;
											o.Specular = 0.2;
											o.Gloss = 1.0;
											o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
										}


							#ifdef UNITY_CAN_COMPILE_TESSELLATION

										// tessellation vertex shader
										struct InternalTessInterp_appdata {
										  float4 vertex : INTERNALTESSPOS;
										  float4 tangent : TANGENT;
										  float3 normal : NORMAL;
										  float2 texcoord : TEXCOORD0;
										};
										InternalTessInterp_appdata tessvert_surf(appdata v) {
										  InternalTessInterp_appdata o;
										  o.vertex = v.vertex;
										  o.tangent = v.tangent;
										  o.normal = v.normal;
										  o.texcoord = v.texcoord;
										  return o;
										}

										// tessellation hull constant shader
										UnityTessellationFactors hsconst_surf(InputPatch<InternalTessInterp_appdata,3> v) {
										  UnityTessellationFactors o;
										  float4 tf;
										  appdata vi[3];
										  vi[0].vertex = v[0].vertex;
										  vi[0].tangent = v[0].tangent;
										  vi[0].normal = v[0].normal;
										  vi[0].texcoord = v[0].texcoord;
										  vi[1].vertex = v[1].vertex;
										  vi[1].tangent = v[1].tangent;
										  vi[1].normal = v[1].normal;
										  vi[1].texcoord = v[1].texcoord;
										  vi[2].vertex = v[2].vertex;
										  vi[2].tangent = v[2].tangent;
										  vi[2].normal = v[2].normal;
										  vi[2].texcoord = v[2].texcoord;
										  tf = tessDistance(vi[0], vi[1], vi[2]);
										  o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
										  return o;
										}

										// tessellation hull shader
										[UNITY_domain("tri")]
										[UNITY_partitioning("fractional_odd")]
										[UNITY_outputtopology("triangle_cw")]
										[UNITY_patchconstantfunc("hsconst_surf")]
										[UNITY_outputcontrolpoints(3)]
										InternalTessInterp_appdata hs_surf(InputPatch<InternalTessInterp_appdata,3> v, uint id : SV_OutputControlPointID) {
										  return v[id];
										}

										#endif // UNITY_CAN_COMPILE_TESSELLATION


										// vertex-to-fragment interpolation data
										// no lightmaps:
										#ifndef LIGHTMAP_ON
										// half-precision fragment shader registers:
										#ifdef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
										#define FOG_COMBINED_WITH_TSPACE
										struct v2f_surf {
										  UNITY_POSITION(pos);
										  float2 pack0 : TEXCOORD0; // _MainTex
										  float4 tSpace0 : TEXCOORD1;
										  float4 tSpace1 : TEXCOORD2;
										  float4 tSpace2 : TEXCOORD3;
										  #if UNITY_SHOULD_SAMPLE_SH
										  half3 sh : TEXCOORD4; // SH
										  #endif
										  UNITY_LIGHTING_COORDS(5,6)
										  UNITY_VERTEX_INPUT_INSTANCE_ID
										  UNITY_VERTEX_OUTPUT_STEREO
										};
										#endif
										// high-precision fragment shader registers:
										#ifndef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
										struct v2f_surf {
										  UNITY_POSITION(pos);
										  float2 pack0 : TEXCOORD0; // _MainTex
										  float4 tSpace0 : TEXCOORD1;
										  float4 tSpace1 : TEXCOORD2;
										  float4 tSpace2 : TEXCOORD3;
										  #if UNITY_SHOULD_SAMPLE_SH
										  half3 sh : TEXCOORD4; // SH
										  #endif
										  UNITY_FOG_COORDS(5)
										  UNITY_SHADOW_COORDS(6)
										  UNITY_VERTEX_INPUT_INSTANCE_ID
										  UNITY_VERTEX_OUTPUT_STEREO
										};
										#endif
										#endif
										// with lightmaps:
										#ifdef LIGHTMAP_ON
										// half-precision fragment shader registers:
										#ifdef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
										#define FOG_COMBINED_WITH_TSPACE
										struct v2f_surf {
										  UNITY_POSITION(pos);
										  float2 pack0 : TEXCOORD0; // _MainTex
										  float4 tSpace0 : TEXCOORD1;
										  float4 tSpace1 : TEXCOORD2;
										  float4 tSpace2 : TEXCOORD3;
										  float4 lmap : TEXCOORD4;
										  UNITY_LIGHTING_COORDS(5,6)
										  UNITY_VERTEX_INPUT_INSTANCE_ID
										  UNITY_VERTEX_OUTPUT_STEREO
										};
										#endif
										// high-precision fragment shader registers:
										#ifndef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
										struct v2f_surf {
										  UNITY_POSITION(pos);
										  float2 pack0 : TEXCOORD0; // _MainTex
										  float4 tSpace0 : TEXCOORD1;
										  float4 tSpace1 : TEXCOORD2;
										  float4 tSpace2 : TEXCOORD3;
										  float4 lmap : TEXCOORD4;
										  UNITY_FOG_COORDS(5)
										  UNITY_SHADOW_COORDS(6)
										  UNITY_VERTEX_INPUT_INSTANCE_ID
										  UNITY_VERTEX_OUTPUT_STEREO
										};
										#endif
										#endif
										float4 _MainTex_ST;

										// vertex shader
										v2f_surf vert_surf(appdata v) {
										  UNITY_SETUP_INSTANCE_ID(v);
										  v2f_surf o;
										  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
										  UNITY_TRANSFER_INSTANCE_ID(v,o);
										  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
										  o.pos = UnityObjectToClipPos(v.vertex);
										  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
										  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
										  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
										  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
										  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
										  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
										  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
										  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
										  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
										  #ifdef LIGHTMAP_ON
										  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
										  #endif

										  // SH/ambient and vertex lights
										  #ifndef LIGHTMAP_ON
											#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
											  o.sh = 0;
											  // Approximated illumination from non-important point lights
											  #ifdef VERTEXLIGHT_ON
												o.sh += Shade4PointLights(
												  unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
												  unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
												  unity_4LightAtten0, worldPos, worldNormal);
											  #endif
											  o.sh = ShadeSHPerVertex(worldNormal, o.sh);
											#endif
										  #endif // !LIGHTMAP_ON

										  UNITY_TRANSFER_LIGHTING(o,v.texcoord1.xy); // pass shadow and, possibly, light cookie coordinates to pixel shader
										  #ifdef FOG_COMBINED_WITH_TSPACE
											UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(o,o.pos); // pass fog coordinates to pixel shader
										  #elif defined (FOG_COMBINED_WITH_WORLD_POS)
											UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(o,o.pos); // pass fog coordinates to pixel shader
										  #else
											UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
										  #endif
										  return o;
										}

										#ifdef UNITY_CAN_COMPILE_TESSELLATION

										// tessellation domain shader
										[UNITY_domain("tri")]
										v2f_surf ds_surf(UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_appdata,3> vi, float3 bary : SV_DomainLocation) {
										  appdata v;
										  v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
										  v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
										  v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
										  v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
										  disp(v);
										  v2f_surf o = vert_surf(v);
										  return o;
										}

										#endif // UNITY_CAN_COMPILE_TESSELLATION


										// fragment shader
										fixed4 frag_surf(v2f_surf IN) : SV_Target {
										  UNITY_SETUP_INSTANCE_ID(IN);
										// prepare and unpack data
										Input surfIN;
										#ifdef FOG_COMBINED_WITH_TSPACE
										  UNITY_EXTRACT_FOG_FROM_TSPACE(IN);
										#elif defined (FOG_COMBINED_WITH_WORLD_POS)
										  UNITY_EXTRACT_FOG_FROM_WORLD_POS(IN);
										#else
										  UNITY_EXTRACT_FOG(IN);
										#endif
										#ifdef FOG_COMBINED_WITH_TSPACE
										  UNITY_RECONSTRUCT_TBN(IN);
										#else
										  UNITY_EXTRACT_TBN(IN);
										#endif
										UNITY_INITIALIZE_OUTPUT(Input,surfIN);
										surfIN.uv_MainTex.x = 1.0;
										surfIN.uv_MainTex = IN.pack0.xy;
										float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
										#ifndef USING_DIRECTIONAL_LIGHT
										  fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
										#else
										  fixed3 lightDir = _WorldSpaceLightPos0.xyz;
										#endif
										float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
										#ifdef UNITY_COMPILER_HLSL
										SurfaceOutput o = (SurfaceOutput)0;
										#else
										SurfaceOutput o;
										#endif
										o.Albedo = 0.0;
										o.Emission = 0.0;
										o.Specular = 0.0;
										o.Alpha = 0.0;
										o.Gloss = 0.0;
										fixed3 normalWorldVertex = fixed3(0,0,1);
										o.Normal = fixed3(0,0,1);

										// call surface function
										surf(surfIN, o);

										// compute lighting & shadowing factor
										UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
										fixed4 c = 0;
										float3 worldN;
										worldN.x = dot(_unity_tbn_0, o.Normal);
										worldN.y = dot(_unity_tbn_1, o.Normal);
										worldN.z = dot(_unity_tbn_2, o.Normal);
										worldN = normalize(worldN);
										o.Normal = worldN;

										// Setup lighting environment
										UnityGI gi;
										UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
										gi.indirect.diffuse = 0;
										gi.indirect.specular = 0;
										gi.light.color = _LightColor0.rgb;
										gi.light.dir = lightDir;
										// Call GI (lightmaps/SH/reflections) lighting function
										UnityGIInput giInput;
										UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
										giInput.light = gi.light;
										giInput.worldPos = worldPos;
										giInput.worldViewDir = worldViewDir;
										giInput.atten = atten;
										#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
										  giInput.lightmapUV = IN.lmap;
										#else
										  giInput.lightmapUV = 0.0;
										#endif
										#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
										  giInput.ambient = IN.sh;
										#else
										  giInput.ambient.rgb = 0.0;
										#endif
										giInput.probeHDR[0] = unity_SpecCube0_HDR;
										giInput.probeHDR[1] = unity_SpecCube1_HDR;
										#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
										  giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
										#endif
										#ifdef UNITY_SPECCUBE_BOX_PROJECTION
										  giInput.boxMax[0] = unity_SpecCube0_BoxMax;
										  giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
										  giInput.boxMax[1] = unity_SpecCube1_BoxMax;
										  giInput.boxMin[1] = unity_SpecCube1_BoxMin;
										  giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
										#endif
										LightingBlinnPhong_GI(o, giInput, gi);

										// realtime lighting: call lighting function
										c += LightingBlinnPhong(o, worldViewDir, gi);
										UNITY_APPLY_FOG(_unity_fogCoord, c); // apply fog
										UNITY_OPAQUE_ALPHA(c.a);
										return c;
									  }


							


									  ENDCG

									  }


		}
}