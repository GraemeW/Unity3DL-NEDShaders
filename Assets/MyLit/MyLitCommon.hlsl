#ifndef MY_LIT_COMMON_INCLUDED
#define MY_LIT_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// Exposed Tunables
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex); // naming convention required/critical (need sampler_<name>)
float4 _MainTex_ST; // Automatically set by Unity, used in TRANSFORM_TEX for UV tiling -- naming convention required/critical (need <name>_ST)
float4 _ColorTint;
float _Cutoff;
float4 _Specular;
float _Smoothness;

void TestAlphaClip(float4 colorSample) {
#ifdef _ALPHA_CUTOUT
	clip(colorSample.a * _ColorTint.a - _Cutoff);
#endif
}

float3 FlipNormalBasedOnViewDir(float3 normalWS, float3 positionWS) {
	float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
	return normalWS * (dot(normalWS, viewDirWS) < 0 ? -1 : 1);
}

#endif
