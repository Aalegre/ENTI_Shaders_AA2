Shader "Hidden/Custom/ToonOutlines"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	float4 _MainTex_TexelSize;
	TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
	
	#pragma shader_feature RAW_OUTLINE

	float _Delta;
    float _Strength;
    float4 _Color;
	
	float sobel (float2 uv)
    {
        float2 delta = float2(_Delta, _Delta);
                
        float hr = 0;
        float vt = 0;
                
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2(-1.0, -1.0) * delta) *  1.0;
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 1.0, -1.0) * delta) * -1.0;
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2(-1.0,  0.0) * delta) *  2.0;
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 1.0,  0.0) * delta) * -2.0;
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2(-1.0,  1.0) * delta) *  1.0;
        hr += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 1.0,  1.0) * delta) * -1.0;
                
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2(-1.0, -1.0) * delta) *  1.0;
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 0.0, -1.0) * delta) *  2.0;
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 1.0, -1.0) * delta) *  1.0;
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2(-1.0,  1.0) * delta) * -1.0;
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 0.0,  1.0) * delta) * -2.0;
        vt += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv + float2( 1.0,  1.0) * delta) * -1.0;
                
        return sqrt(hr * hr + vt * vt);
    }

	float4 Outline(VaryingsDefault i) : SV_Target
	{
        float sob = sobel(i.texcoordStereo);
        float s = pow(1 - saturate(sob * _Strength), 50);
        float4 outline = (1 - (1 - s) * (1 - 0));

		#ifdef RAW_OUTLINE
			return lerp(outline + _Color, (outline * -1 + 1) * _Color, _Color.a);
		#endif

		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

		float4 mult = col * (outline + _Color);
        float4 add = col + ((outline * -1 + 1) * _Color);
        return lerp(mult, add, _Color.a);
	}

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
				#pragma fragment Outline
			ENDHLSL
		}
		
	}
}
