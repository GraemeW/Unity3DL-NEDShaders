#include "MyLitCommon.hlsl"

// Data Structures
struct Attributes {
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float2 uv : TEXCOORD0;
};

struct Interpolators {
	float4 positionCS : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
	float3 normalWS : TEXCOORD2;
};

// Main Functionality
Interpolators Vertex(Attributes input)
{
	Interpolators output;
	VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

	output.positionCS = positionInputs.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	output.positionWS = positionInputs.positionWS;
	output.normalWS = normalInputs.normalWS;

	return output;
}

float4 Fragment(Interpolators input, FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC) : SV_TARGET{
	float2 uv = input.uv;
	float4 colorSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	TestAlphaClip(colorSample);

	InputData lightingInput = (InputData)0;
	lightingInput.positionWS = input.positionWS;
	float3 normalWS = normalize(input.normalWS);
#ifdef _DOUBLE_SIDED_NORMALS
	normalWS *= IS_FRONT_VFACE(frontFace, 1, -1);
#endif
	lightingInput.normalWS = normalWS;
	lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
	lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);

	SurfaceData surfaceInput = (SurfaceData)0;
	surfaceInput.albedo = colorSample.rgb * _ColorTint.rgb;
	surfaceInput.alpha = colorSample.a * _ColorTint.a;
	surfaceInput.specular = _Specular.rgb;
	surfaceInput.smoothness = _Smoothness;

	return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);
}