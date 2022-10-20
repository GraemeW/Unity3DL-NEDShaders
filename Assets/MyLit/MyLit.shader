Shader "NedMakesGames/MyLit" {
	Properties{
		[Header(Surface Options)]
		[MainTexture] _ColorMap("Color", 2D) = "white" {}
		[MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)
	}
	SubShader{
		Tags {"RenderPipeline" = "UniversalPipeline"}
		Pass {
			Name "ForwardLit" // For debugging
			Tags {"LightMode" = "UniversalForward"} // Note:  main lighting pass of this shader

			HLSLPROGRAM // Begin HLSL Code
			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "MyLitForwardLitPass.hlsl"
			ENDHLSL
		}
	}
}