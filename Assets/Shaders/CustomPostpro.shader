//Siempre hay que dejarlo en "Hidden/" + lo que sea
Shader "Hidden/Custom/CustomPostpro"
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
	

	//Inputs que rellena el usuario
	//float, escalar, o slider
	float _intensity;
	//vector o color
	float4 _color;
	float4 _vector;



	float4 Frag(VaryingsDefault i) : SV_Target
	{
		//profundidad de la escena en espacio lineal
		//float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoordStereo));
		
		//como usar SAMPLE_TEXTURE2D(Textura a consultar, Sampler de la textura (viene con la propia definicion), float2 que punto se va a consultar la textura (0-1, 0-1) )
		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float4 color2 = float4(1,1,1,1) - col;
		//como usar lerp(float vector o color A, float vector o color B, valor de 0-1 que indica que valor A o B tendrá más peso)
		col.rgb = lerp(col.rgb, color2.rgb, _intensity.xxx);
		//teñir un color con otro color
		col.rgb = _color.rgb * col.rgb;
		//se devuelve siempre un float4, o un color
		return col;
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
