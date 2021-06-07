Shader "Hidden/Custom/Tonemapping"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Colors.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	
	float _Strength;
	float _Steps;

	float ShoulderStrength = 0.1;
	float LinearStrength = 0.136;
	float LinearAngle = 0.045;
	float ToeStrength = 0.0999;
	float ToeNumerator = 0.0045;
	float ToeDenominator = 0.136;
	float ToeAngle = 0.0045/0.136;

	float usePredefinedLuminance = true;
	float LinearWhite = 5.09;
	float exposure = .6;

	float F(float col)
	{
		float numerator = col*(col*ShoulderStrength+LinearAngle*LinearStrength) + ToeStrength * ToeNumerator;
		float denominator = col*(ShoulderStrength * col + LinearStrength) + ToeStrength * ToeDenominator;
		return (numerator / denominator) - ToeNumerator / ToeDenominator;
	}

	float3 F(float3 col)
	{
		float3 numerator = col*(col*ShoulderStrength+LinearAngle*LinearStrength) + ToeStrength * ToeNumerator;
		float3 denominator = col*(ShoulderStrength * col + LinearStrength) + ToeStrength * ToeDenominator;
		return (numerator / denominator) - ToeNumerator / ToeDenominator;
	}

	float4 Tonemapping(VaryingsDefault i) : SV_Target
	{
		float2 uv = i.texcoord;

		float3 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float luminancia;
    
		if(usePredefinedLuminance){
			luminancia=LinearWhite;
		}
		else{
    		luminancia = dot(SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex,float2(0.5,0.5),100).rgb,float3(0.22,0.7,0.05));
		}
		float3 mappedColor=F(col*exposure);
    
		float whiteScale = F(luminancia);  
    
		// Output to screen
		if(uv.x > 0.5)
		return float4(mappedColor / whiteScale, 1);
		else
		return float4(col, 1);

	}

	ENDHLSL
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Tonemapping
			ENDHLSL
		}
		
	}
}
