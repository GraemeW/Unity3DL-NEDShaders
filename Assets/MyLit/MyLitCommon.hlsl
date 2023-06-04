#ifndef MY_LIT_COMMON_INCLUDED
#define MY_LIT_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"

// Exposed Tunables
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex); // naming convention required/critical (need sampler_<name>)
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetalnessMask);
SAMPLER(sampler_MetalnessMask);
TEXTURE2D(_SpecularMap);
SAMPLER(sampler_SpecularMap);
TEXTURE2D(_SmoothnessMask);
SAMPLER(sampler_SmoothnessMask);
TEXTURE2D(_EmissionMap);
SAMPLER(sampler_EmissionMap);
TEXTURE2D(_ParallaxMap);
SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_ClearCoatMask);
SAMPLER(sampler_ClearCoatMask);
TEXTURE2D(_ClearCoatSmoothnessMask);
SAMPLER(sampler_ClearCoatSmoothnessMask);
float4 _MainTex_ST; // Automatically set by Unity, used in TRANSFORM_TEX for UV tiling -- naming convention required/critical (need <name>_ST)
float4 _ColorTint;
float _Cutoff;
float _NormalStrength;
float _Metalness;
float4 _SpecularTint;
float _Smoothness;
float4 _EmissionTint;
float _ParallaxStrength;
float _ClearCoatStrength;
float _ClearCoatSmoothness;

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
