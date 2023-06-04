Shader "NedMakesGames/MyLit" {
	Properties{
		[Header(Surface Options)]
		[MainTexture] _MainTex("Color", 2D) = "white" {} // Magic property, required naming scheme
		[MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)
		_Cutoff("Alpha cutout threshold", Range(0, 1)) = 0.05 // Magic property, required naming scheme
		[NoScaleOffset][Normal] _NormalMap("Normal", 2D) = "bump" {} // Magic property, required naming scheme; bump translates to 0,0,1 in tangent space
		_NormalStrength("Normal strength", Range(0, 1)) = 1
		[NoScaleOffset] _MetalnessMask("Metalness mask", 2D) = "white" {}
		_Metalness("Metalness strength", Range(0,1)) = 0
		[Toggle(_SPECULAR_SETUP)] _SpecularSetupToggle("Use specular workflow", Float) = 0
		[NoScaleOffset] _SpecularMap("Specular map", 2D) = "white" {}
		_SpecularTint("Specular tint", Color) = (1, 1, 1, 1)
		[NoScaleOffset] _SmoothnessMask("Smoothness mask", 2D) = "white" {}
		_Smoothness("Smoothness strength", Range(0,1)) = 0.5
		[NoScaleOffset] _EmissionMap("Emission map", 2D) = "white" {}
		[HDR]_EmissionTint("Emission tint", Color) = (0, 0, 0, 0)
		[NoScaleOffset] _ParallaxMap("Height/displacement map", 2D) = "white" {}
		_ParallaxStrength("Parallax strength", Range(0,1)) = 0.005
		[NoScaleOffset] _ClearCoatMask("Clear coat mask", 2D) = "white" {}
		_ClearCoatStrength("Clear coat strength", Range(0,1)) = 0
		[NoScaleOffset] _ClearCoatSmoothnessMask("Clear coat smoothness mask", 2D) = "white" {}
		_ClearCoatSmoothness("Clear coat smoothness", Range(0,1)) = 0

		// Properties for transparency handling
		[HideInInspector] _SourceBlend("Source blend", Float) = 0
		[HideInInspector] _DestinationBlend("Destination blend", Float) = 0
		[HideInInspector] _ZWrite("ZWrite", Float) = 0

		[HideInInspector] _SurfaceType("Surface type", Float) = 0 // Opaque, Transparent, Transparent cutout
		[HideInInspector] _BlendType("Blend type", Float) = 0 // Alpha, Premultiplied, Additive, Multiply
		[HideInInspector] _FaceRenderingMode("Face rendering mode", Float) = 0 // Front, No culling, Double-sided
		[HideInInspector] _Cull("Cull mode", Float) = 2
	}
	SubShader{
		Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
		Pass {
			Name "ForwardLit" // For debugging
			Tags {"LightMode" = "UniversalForward"} // Note:  main lighting pass of this shader

			// Transparency Support
			Blend[_SourceBlend][_DestinationBlend] // Linearly interpolate b/w source and destination color
			ZWrite[_ZWrite] // Prevent transparent surfaces from being stored in depth buffer
			Cull[_Cull] // Prevent culling interior surfaces for transparent cutouts

			HLSLPROGRAM
			// Shader feature keyword definitions
			#pragma shader_feature_local_fragment _NORMALMAP
			#define _CLEARCOATMAP
			#pragma shader_feature_local _ALPHA_CUTOUT
			#pragma shader_feature_local _DOUBLE_SIDED_NORMALS
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

			// Shadow Support
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT

			// Debug Output
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			// Main Functionality
			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "MyLitForwardLitPass.hlsl"
			ENDHLSL
		}
		Pass {
			Name "ShadowCaster" // For debugging
			Tags {"LightMode" = "ShadowCaster"} // Note:  main shadow pass of this shader

			ColorMask A // No color info needed, just positional info for shadow rendering
			Cull[_Cull] // Prevent culling interior surfaces for transparent cutouts

			HLSLPROGRAM
			// Shader feature keyword definitions
			#pragma shader_feature_local _ALPHA_CUTOUT
			#pragma shader_feature_local _DOUBLE_SIDED_NORMALS

			// Main Functionality
			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "MyLitShadowCasterPass.hlsl"
			ENDHLSL
		}
	}

	CustomEditor "MyLitCustomInspector" // For switching between opaque vs. transparent mode
}