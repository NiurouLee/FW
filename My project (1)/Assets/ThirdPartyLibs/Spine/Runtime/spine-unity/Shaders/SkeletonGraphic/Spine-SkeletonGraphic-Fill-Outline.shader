Shader "Spine/SkeletonGraphic Fill Outline"
{
	Properties
	{
		_FillColor("FillColor", Color) = (1,1,1,1)
		_FillPhase("FillPhase", Range(0, 1)) = 0
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("Straight Alpha Texture", Int) = 0
		[Toggle(_CANVAS_GROUP_COMPATIBLE)] _CanvasGroupCompatible("CanvasGroup Compatible", Int) = 1
		_Color("Tint", Color) = (1,1,1,1)

		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil("Stencil ID", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.StencilOp)] _StencilOp("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255

		[HideInInspector] _ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0

			// Outline properties are drawn via custom editor.
			[HideInInspector] _OutlineWidth("Outline Width", Range(0,8)) = 3.0
			[HideInInspector] _OutlineColor("Outline Color", Color) = (1,1,0,1)
			[HideInInspector] _OutlineReferenceTexWidth("Reference Texture Width", Int) = 1024
			[HideInInspector] _ThresholdEnd("Outline Threshold", Range(0,1)) = 0.25
			[HideInInspector] _OutlineSmoothness("Outline Smoothness", Range(0,1)) = 1.0
			[HideInInspector][MaterialToggle(_USE8NEIGHBOURHOOD_ON)] _Use8Neighbourhood("Sample 8 Neighbours", Float) = 1
			[HideInInspector] _OutlineOpaqueAlpha("Opaque Alpha", Range(0,1)) = 1.0
			[HideInInspector] _OutlineMipLevel("Outline Mip Level", Range(0,3)) = 0
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
				"CanUseSpriteAtlas" = "True"
			}

			Stencil
			{
				Ref[_Stencil]
				Comp[_StencilComp]
				Pass[_StencilOp]
				ReadMask[_StencilReadMask]
				WriteMask[_StencilWriteMask]
			}

			Cull Off
			Lighting Off
			ZWrite Off
			ZTest[unity_GUIZTestMode]
			Fog { Mode Off }
			Blend One OneMinusSrcAlpha
			ColorMask[_ColorMask]

			Pass
			{
				Name "Normal"

			CGPROGRAM
				#pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
				#pragma shader_feature _ _CANVAS_GROUP_COMPATIBLE
				#pragma vertex vert
				#pragma fragment frag_custom
				#pragma target 2.0

				#define ENABLE_FILL
				#define SKELETON_GRAPHIC
				#include "CGIncludes/Spine-SkeletonGraphic-NormalPass.cginc"
				// #include "../Outline/CGIncludes/Spine-Outline-Pass.cginc"
				float _OutlineWidth;
				float4 _OutlineColor;
				float4 _MainTex_TexelSize;
				float _ThresholdEnd;
				float _OutlineSmoothness;
				float _OutlineOpaqueAlpha;
				float _OutlineMipLevel;
				int _OutlineReferenceTexWidth;
				//#include "../CGIncludes/Spine-Outline-Common.cginc"
float computeOutlinePixel(sampler2D mainTexture, float2 mainTextureTexelSize,
	float2 uv, float vertexColorAlpha,
	float OutlineWidth, float OutlineReferenceTexWidth, float OutlineMipLevel,
	float OutlineSmoothness, float ThresholdEnd, float OutlineOpaqueAlpha, float4 OutlineColor) {

	float4 texColor = fixed4(0, 0, 0, 0);

	float outlineWidthCompensated = OutlineWidth / (OutlineReferenceTexWidth * mainTextureTexelSize.x);
	float xOffset = mainTextureTexelSize.x * outlineWidthCompensated;
	float yOffset = mainTextureTexelSize.y * outlineWidthCompensated;
	float xOffsetDiagonal = mainTextureTexelSize.x * outlineWidthCompensated * 0.7;
	float yOffsetDiagonal = mainTextureTexelSize.y * outlineWidthCompensated * 0.7;

	float pixelCenter = tex2D(mainTexture, uv).a;

	float4 uvCenterWithLod = float4(uv, 0, OutlineMipLevel);
	float pixelTop = tex2Dlod(mainTexture, uvCenterWithLod + float4(0, yOffset, 0, 0)).a;
	float pixelBottom = tex2Dlod(mainTexture, uvCenterWithLod + float4(0, -yOffset, 0, 0)).a;
	float pixelLeft = tex2Dlod(mainTexture, uvCenterWithLod + float4(-xOffset, 0, 0, 0)).a;
	float pixelRight = tex2Dlod(mainTexture, uvCenterWithLod + float4(xOffset, 0, 0, 0)).a;
#if _USE8NEIGHBOURHOOD_ON
	float numSamples = 8;
	float pixelTopLeft = tex2Dlod(mainTexture, uvCenterWithLod + float4(-xOffsetDiagonal, yOffsetDiagonal, 0, 0)).a;
	float pixelTopRight = tex2Dlod(mainTexture, uvCenterWithLod + float4(xOffsetDiagonal, yOffsetDiagonal, 0, 0)).a;
	float pixelBottomLeft = tex2Dlod(mainTexture, uvCenterWithLod + float4(-xOffsetDiagonal, -yOffsetDiagonal, 0, 0)).a;
	float pixelBottomRight = tex2Dlod(mainTexture, uvCenterWithLod + float4(xOffsetDiagonal, -yOffsetDiagonal, 0, 0)).a;
	float average = (pixelTop + pixelBottom + pixelLeft + pixelRight +
		pixelTopLeft + pixelTopRight + pixelBottomLeft + pixelBottomRight)
		* vertexColorAlpha / numSamples;
#else // 4 neighbourhood
	float numSamples = 4;
	float average = (pixelTop + pixelBottom + pixelLeft + pixelRight) * vertexColorAlpha / numSamples;
#endif
	float thresholdStart = ThresholdEnd * (1.0 - OutlineSmoothness);
	float outlineAlpha = saturate(saturate((average - thresholdStart) / (ThresholdEnd - thresholdStart)) - pixelCenter);
	outlineAlpha = pixelCenter > OutlineOpaqueAlpha ? 0 : outlineAlpha;
	return average;
	// return lerp(texColor, OutlineColor, outlineAlpha);
}
				fixed4 frag_custom (VertexOutput IN) : SV_Target
				{
					half4 texColor = tex2D(_MainTex, IN.texcoord);

					#if defined(_STRAIGHT_ALPHA_INPUT)
					texColor.rgb *= texColor.a;
					#endif

					half4 color = (texColor + _TextureSampleAdd) * IN.color;
					color *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

					float colorOutline = computeOutlinePixel(_MainTex, _MainTex_TexelSize.xy,
						IN.texcoord, IN.color.r,
						_OutlineWidth, _OutlineReferenceTexWidth, _OutlineMipLevel,
						_OutlineSmoothness, _ThresholdEnd, _OutlineOpaqueAlpha, _OutlineColor);
					// color += colorOutline;

					#ifdef UNITY_UI_ALPHACLIP
					clip (color.a - 0.001);
					#endif

					#ifdef ENABLE_FILL
					color.rgb = lerp(color.rgb, (_FillColor.rgb * colorOutline), _FillPhase); // make sure to PMA _FillColor.
					#endif
					return color;
				}

				// float4 fragOutline(VertexOutput i) : SV_Target {

				// 	float4 texColor = computeOutlinePixel(_MainTex, _MainTex_TexelSize.xy,
				// 		i.texcoord, i.color.r,
				// 		_OutlineWidth, _OutlineReferenceTexWidth, _OutlineMipLevel,
				// 		_OutlineSmoothness, _ThresholdEnd, /* _OutlineOpaqueAlpha, */ _OutlineColor);

				// #ifdef SKELETON_GRAPHIC
				// 	texColor *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				// #endif

				// 	return texColor;
				// }
			ENDCG
			}
		}
			CustomEditor "SpineShaderWithOutlineGUI"
}
