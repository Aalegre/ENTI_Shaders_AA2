Shader "Hidden/Custom/Pixelate"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	
	float _Strength;
	float _Steps;
	float4 Pixelate(VaryingsDefault i) : SV_Target
	{
		float2 oldUv = floor(i.texcoord * _Steps) / _Steps;
		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float4 col2 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, oldUv);
		return lerp(col, col2, _Strength);
	}

	ENDHLSL
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Pixelate
			ENDHLSL
		}
		
	}
}
