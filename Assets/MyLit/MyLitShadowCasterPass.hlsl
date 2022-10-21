#include "MyLitCommon.hlsl"

// URP Globals
float3 _LightDirection;

// Data Structures
struct Attributes {
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
#if _ALPHA_CUTOUT
	float2 uv : TEXCOORD0;
#endif
};

struct Interpolators {
	float4 positionCS : SV_POSITION;
#if _ALPHA_CUTOUT
	float2 uv : TEXCOORD0;
#endif
};

float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS) {
	float3 lightDirectionWS = _LightDirection;
#ifdef _DOUBLE_SIDED_NORMALS
	normalWS = FlipNormalBasedOnViewDir(normalWS, positionWS);
#endif
	float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
	positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
	positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif
	return positionCS;
}

Interpolators Vertex(Attributes input) {
	Interpolators output;
	
	VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

	output.positionCS = GetShadowCasterPositionCS(positionInputs.positionWS, normalInputs.normalWS);
#if _ALPHA_CUTOUT
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
#endif
	return output;
}

float4 Fragment(Interpolators input) : SV_TARGET{
#if _ALPHA_CUTOUT
	float2 uv = input.uv;
	float4 colorSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	TestAlphaClip(colorSample);
#endif

	return 0;
}