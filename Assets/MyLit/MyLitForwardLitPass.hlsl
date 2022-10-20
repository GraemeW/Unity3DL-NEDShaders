// Includes
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


// Textures
TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap); 
	// N.B. naming convention required/critical (need sampler_<name>
float4 _ColorMap_ST; // Automatically set by Unity, used in TRANSFORM_TEX for UV tiling
	// N.B. naming convetion required/critical (need <name>_ST)

// Other Properties
float4 _ColorTint;

// Data Structures
struct Attributes {
	float3 positionOS : POSITION;
	float2 uv : TEXCOORD0;
};

struct Interpolators {
	float4 positionCS : SV_POSITION;
	float2 uv : TEXCOORD0;
};

// Main Functionality
Interpolators Vertex(Attributes input)
{
	Interpolators output;
	VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);

	output.positionCS = posnInputs.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _ColorMap);

	return output;
}

float4 Fragment(Interpolators input) : SV_TARGET{
	float2 uv = input.uv;
	float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
	return colorSample * _ColorTint;
}