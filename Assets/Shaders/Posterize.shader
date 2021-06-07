Shader "Hidden/Custom/Posterize"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Colors.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	
	float _Strength;
	float _Steps;
	float4 Posterize(VaryingsDefault i) : SV_Target
	{
		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float4 col2 = pow(col, 0.4545);
        float3 c = RgbToHsv(col2);
        c.z = round(c.z * _Steps) / _Steps;
        col2 = float4(HsvToRgb(c), col2.a);
        col2 = pow(col2, 2.2);

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
				#pragma fragment Posterize
			ENDHLSL
		}
		
	}
}
