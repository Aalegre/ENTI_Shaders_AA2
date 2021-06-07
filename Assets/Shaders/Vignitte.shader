//Siempre hay que dejarlo en "Hidden/" + lo que sea
Shader "Hidden/Custom/Vignitte"
{
	HLSLINCLUDE
	//Shaders por defecto que tiene el Post Processing Stack v2 https://github.com/Unity-Technologies/PostProcessing/tree/v2/PostProcessing/Shaders

	// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	// Colors.hlsl incluye funciones utiles para modificar colores, cambiar la saturación, la luminancia, pasar de RGB a HSV, etc
	// #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Colors.hlsl"
	
	//Inputs que se rellenan automaticamente
	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex); //Textura del color de la escena
	float4 _MainTex_TexelSize; //x: ancho pantalla, y: alto pantalla, z: 1/ancho pantalla, w: 1/alto pantalla
	TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture); //Textura de la profundidad de la escena (Se puede usar el _MainTex_TexelSize con esta sin problema)
	

	float _intensity;
	float _innerRadius;
	float _outerRadius;
	//float _mix;
	float3 _color;



	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float2 uvfix = (i.texcoord - float2(0.5, 0.5));
		float shade = smoothstep(_innerRadius, _outerRadius, length(uvfix));
		
		return float4(lerp(col.rgb, lerp(col.rgb, _color, shade), _intensity.xxx), shade * _intensity);
	}
	/*float4 Frag2(VaryingsDefault i) : SV_Target
	{
		return float4(1);
	}*/

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
				#pragma fragment Frag
			ENDHLSL
		}
		/*
		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Frag2
			ENDHLSL
		}
		*/
	}
}
