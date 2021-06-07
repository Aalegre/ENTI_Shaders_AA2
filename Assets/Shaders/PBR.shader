Shader "Lit/PBR"
{
	Properties
	{
		 _objectColor("Main color",Color) = (0,0,0,1)
		 _ambientInt("Ambient int", Range(0,1)) = 0.25
		 _ambientColor("Ambient Color", Color) = (0,0,0,1)

		 _diffuseInt("Diffuse int", Range(0,1)) = 1
		_specularAlpha("Specular alpha",Range(0,1)) = 0.0
		_fresnelQ("Fresnel q",Float) = 1.0

    }
    SubShader
    {
        Tags {"LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
			#include "Assets/Shaders/BRDF.hlsl"

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight


            struct v2f
            {
                float2 uv : TEXCOORD0;
				SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
                float3 wpos : TEXCOORD2;
				float3 normal : TEXCOORD3;
				float3 wnormal : TEXCOORD4;
            };


            v2f vert (appdata_base v)
            {
                v2f o;
				o.uv = v.texcoord;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = v.normal;
				o.wnormal = UnityObjectToWorldNormal(v.normal);
				TRANSFER_SHADOW(o)
                return o;
            }

			fixed4 _objectColor;
			
			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _specularAlpha;
			float _fresnelQ;

            fixed4 frag (v2f i) : SV_Target
            {
				

				//3 phong model light components
                //We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = _ambientColor * _ambientInt;
				
				float3 viewVec = normalize(_WorldSpaceCameraPos - i.wpos);
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 lightColor;
				float3 lightDir;
                fixed shadow;


				lightDir = _WorldSpaceLightPos0.xyz;
				lightColor = _LightColor0.rgb;
				shadow = SHADOW_ATTENUATION(i);
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.wnormal), 0, 1);
				specularComp = lightColor * BRDF(_specularAlpha, _fresnelQ, viewVec, i.wnormal, lightDir);
				finalColor += clamp(float4(shadow * (difuseComp + specularComp), 1), 0, 1);

				//for (int index = 0; index < 4; index++)
				//{
				//	lightDir = normalize((float3(unity_4LightPosX0[index],
				//		unity_4LightPosY0[index],
				//		unity_4LightPosZ0[index]) - i.wpos));
				//	lightColor = unity_LightColor[index];
				//	shadow = unity_4LightAtten0[index];
				//	difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.wnormal), 0, 1);
				//	specularComp = lightColor * BRDF(_specularAlpha, _fresnelQ, viewVec, i.wnormal, lightDir);
				//	finalColor += clamp(float4(shadow * (difuseComp + specularComp), 1), 0, 1);
				//}
				
                
				return finalColor * _objectColor;
            }
            ENDCG
        }
    } FallBack "Diffuse"
}
