#include "MyLitCommon.hlsl"

// Data Structures
struct Attributes {
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
	float2 uv : TEXCOORD0;
};

struct Interpolators {
	float4 positionCS : SV_POSITION;

	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
	float3 normalWS : TEXCOORD2;
	float4 tangentWS : TEXTCOORD3;
};

// Main Functionality
Interpolators Vertex(Attributes input)
{
	Interpolators output;
	VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

	output.positionCS = positionInputs.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	output.normalWS = normalInputs.normalWS;
	output.tangentWS = float4(normalInputs.tangentWS, input.tangentOS.w);
	output.positionWS = positionInputs.positionWS;

	return output;
}

float4 Fragment(Interpolators input, FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC) : SV_TARGET{
	float3 normalWS = normalize(input.normalWS);
#ifdef _DOUBLE_SIDED_NORMALS
	normalWS *= IS_FRONT_VFACE(frontFace, 1, -1);
#endif

	float3 positionWS = input.positionWS;
	float3 viewDirectionWS = GetWorldSpaceNormalizeViewDir(positionWS); // ShaderVariablesFunctions.hlsl
	float3 viewDirectionTS = GetViewDirectionTangentSpace(input.tangentWS, normalWS, viewDirectionWS); // ParallaxMapping.hlsl

	float2 uv = input.uv;
	uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirectionTS, _ParallaxStrength, uv);

	float4 colorSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * _ColorTint;
	TestAlphaClip(colorSample);

#ifdef _NORMALMAP
	float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalStrength);
	float3x3 tangentToWorld = CreateTangentToWorld(normalWS, input.tangentWS.xyz, input.tangentWS.w);
	normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
#else
	float3 normalTS = float3(0, 0, 1);
	normalWS = normalize(normalWS);
#endif

	InputData lightingInput = (InputData)0;
	lightingInput.positionWS = positionWS;
	lightingInput.normalWS = normalWS;
	lightingInput.viewDirectionWS = viewDirectionWS;
	lightingInput.shadowCoord = TransformWorldToShadowCoord(positionWS);
	lightingInput.positionCS = input.positionCS;
#ifdef _NORMALMAP
	lightingInput.tangentToWorld = tangentToWorld;
#endif

	SurfaceData surfaceInput = (SurfaceData)0;
	surfaceInput.albedo = colorSample.rgb;
	surfaceInput.alpha = colorSample.a;

#ifdef _SPECULAR_SETUP
	surfaceInput.specular = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, uv).rgb * _SpecularTint;
	surfaceInput.metallic = 0;
#else
	surfaceInput.specular = 1;
	surfaceInput.metallic = SAMPLE_TEXTURE2D(_MetalnessMask, sampler_MetalnessMask, uv).r * _Metalness;
#endif
	surfaceInput.smoothness = SAMPLE_TEXTURE2D(_SmoothnessMask, sampler_SmoothnessMask, uv).r * _Smoothness;
	surfaceInput.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionTint;
	surfaceInput.clearCoatMask = SAMPLE_TEXTURE2D(_ClearCoatMask, sampler_ClearCoatMask, uv).r * _ClearCoatStrength;
	surfaceInput.clearCoatSmoothness = SAMPLE_TEXTURE2D(_ClearCoatSmoothnessMask, sampler_ClearCoatSmoothnessMask, uv).r * _ClearCoatSmoothness;
	surfaceInput.normalTS = normalTS;

	return UniversalFragmentPBR(lightingInput, surfaceInput);
}