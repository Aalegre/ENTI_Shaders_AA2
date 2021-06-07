Shader "Hidden/Custom/Misregistration"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	float4 _MainTex_TexelSize;
	TEXTURE2D_SAMPLER2D(_Mask, sampler_Mask);
	
	float _Strength;
	float _Scale;

	float4 _ORS_C;
	float4 _ORS_M;
	float4 _ORS_Y;
	float4 _ORS_K;

	float4 RGBtoCMYK(float3 col)
	{
		float4 cymk = float4(0,0,0,0);
		cymk.a = 1 - max(max(col.r, col.g), col.b);
		cymk.r = (1 - col.r - cymk.a) / (1 - cymk.a);
		cymk.g = (1 - col.g - cymk.a) / (1 - cymk.a);
		cymk.b = (1 - col.b - cymk.a) / (1 - cymk.a);
		return cymk;
	}
	float3 CMYKtoRGB(float4 col)
	{
		float3 rgb = float3(0,0,0);
		rgb.r = (1-col.r)*(1-col.a);
		rgb.g = (1-col.g)*(1-col.a);
		rgb.b = (1-col.b)*(1-col.a);
		return rgb;
	}

	float2 Rotate_Radians(float2 UV, float2 Center, float Rotation)
	{
		UV -= Center;
		float s = sin(Rotation);
		float c = cos(Rotation);
		float2x2 rMatrix = float2x2(c, -s, s, c);
		rMatrix *= 0.5;
		rMatrix += 0.5;
		rMatrix = rMatrix * 2 - 1;
		UV.xy = mul(UV.xy, rMatrix);
		UV += Center;
		return UV;
	}

	float4 Misregistration(VaryingsDefault i) : SV_Target
	{
		float2 uv = float2(i.texcoord.x * _MainTex_TexelSize.z, i.texcoord.y * _MainTex_TexelSize.w);
		uv *= _Scale;
		float2 uv_c = Rotate_Radians(uv + _ORS_C.xy, float2(0.5, 0.5), _ORS_C.z);
		float2 uv_m = Rotate_Radians(uv + _ORS_M.xy, float2(0.5, 0.5), _ORS_M.z);
		float2 uv_y = Rotate_Radians(uv + _ORS_Y.xy, float2(0.5, 0.5), _ORS_Y.z);
		float2 uv_k = Rotate_Radians(uv + _ORS_K.xy, float2(0.5, 0.5), _ORS_K.z);
		float3 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float4 cmyk = RGBtoCMYK(col);
		cmyk.r *= saturate(SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_c) * _ORS_C.w);
		cmyk.g *= saturate(SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_m) * _ORS_M.w);
		cmyk.b *= saturate(SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_y) * _ORS_Y.w);
		cmyk.a *= saturate((1-SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_k)) * _ORS_K.w);
		return float4(lerp(col, CMYKtoRGB(cmyk),_Strength),0);
	}

	ENDHLSL
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Misregistration
			ENDHLSL
		}
		
	}
}
