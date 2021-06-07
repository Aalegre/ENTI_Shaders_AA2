Shader "Hidden/Custom/DOF_Bokeh"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "Assets/Shaders/DiskKernels.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	float4 _MainTex_TexelSize;
	TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
	

	float _FocusDistance, _FocusRange, _Radius;

	#pragma shader_feature RAW_DEPTH
	#pragma shader_feature TENTFILTER
    #pragma shader_feature _QUALITYBOKEH_ULTRALOW _QUALITYBOKEH_LOW _QUALITYBOKEH_MEDIUM _QUALITYBOKEH_HIGH _QUALITYBOKEH_ULTRA



	float4 Bokeh(VaryingsDefault i) : SV_Target
	{
		float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoordStereo));
		float strength = (depth - _FocusDistance) / _FocusRange;
		#ifdef RAW_DEPTH
		if(strength < 0){
			return strength * -float4(0,0,1,0);
		}
		return strength * float4(1,0,0,0);
		#endif
		strength = saturate(abs(strength));
		//return float4(i.texcoordStereo, 0, 0);

		_Radius *= (_MainTex_TexelSize.z + _MainTex_TexelSize.w) * 0.5f;
        float3 col = float3(0, 0, 0);

        int samples = kSampleCount_ultralow;
#ifdef _QUALITYBOKEH_LOW
        samples = kSampleCount_low;
#endif
#ifdef _QUALITYBOKEH_MEDIUM
        samples = kSampleCount_medium;
#endif
#ifdef _QUALITYBOKEH_HIGH
        samples = kSampleCount_high;
#endif
#ifdef _QUALITYBOKEH_ULTRA
        samples = kSampleCount_ultra;
#endif
                    samples = lerp(1, samples, saturate(strength * 2));
					
                    for (int k = 0; k < samples; k++) {
                        float2 o = float2(0,0);
#ifdef _QUALITYBOKEH_ULTRALOW
                        o = kDiskKernel_ultralow[k];
#endif
#ifdef _QUALITYBOKEH_LOW
                        o = kDiskKernel_low[k];
#endif
#ifdef _QUALITYBOKEH_MEDIUM
                        o = kDiskKernel_medium[k];
#endif
#ifdef _QUALITYBOKEH_HIGH
                        o = kDiskKernel_high[k];
#endif
#ifdef _QUALITYBOKEH_ULTRA
                        o = kDiskKernel_ultra[k];
#endif
                        o *= _MainTex_TexelSize.xy * _Radius * strength;
                        o += i.texcoord;
                        col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, o);
                    }
                    col *= 1.0 / samples;
                    return float4(col, 1);
	}
	//float4 Tent(VaryingsDefault i) : SV_Target
	//{
	//	float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoordStereo));
	//	float strength = (depth - _FocusDistance) / _FocusRange;

	//	strength = saturate(abs(strength));

 //       float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
 //       half4 col =
 //           SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + o.xy) +
 //           SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + o.zy) +
 //           SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + o.xw) +
 //           SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + o.zw);
 //       col *= 0.25;
 //       return lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord), col, strength);
	//}

	ENDHLSL
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		//Configurar "pasadas" o funciones del shader en orden de ejecución
		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				//Que funcion se llamará para esta "pasada"
				#pragma fragment Bokeh
			ENDHLSL
		}
		
		//Pass
		//{
		//	HLSLPROGRAM
		//		#pragma vertex VertDefault
		//		#pragma fragment Tent
		//	ENDHLSL
		//}
		
	}
}
