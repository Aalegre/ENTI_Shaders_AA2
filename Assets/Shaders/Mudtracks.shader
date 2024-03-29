﻿Shader "Custom/Mudtracks"
{
    Properties
    {
		_Tess ("Tessellation", Range(1,32)) = 4
        _MudColor ("Mud Color", Color) = (1,1,1,1)
        _MudTex ("Mud (RGB)", 2D) = "white" {}
		_GroundColor ("Ground Color", Color) = (1,1,1,1)
        _GroundTex ("Ground (RGB)", 2D) = "white" {}
		_Splat ("SplatMap", 2D) = "black" {}
		_SplatMask ("SplatMapMask", 2D) = "white" {}
		_Displacement ("Displacement", Range(0, 1.0)) = 0.3
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:disp tessellate:tessDistance addshadow fullforwardshadows nolightmap

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.6

		 #include "Tessellation.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _Tess;

            float4 tessDistance (appdata v0, appdata v1, appdata v2) {
                float minDist = 10.0;
                float maxDist = 25.0;
                return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
            }

            sampler2D _Splat;
            sampler2D _SplatMask;
            float _Displacement;

            void disp (inout appdata v)
            {
                float d = ( (1 - tex2Dlod(_Splat, float4(v.texcoord.xy,0,0)).r) * tex2Dlod(_SplatMask, float4(v.texcoord.xy,0,0)).r) * _Displacement;
                //v.vertex.xyz -= v.normal * d;
				v.vertex.xyz += v.normal * d;
            }

        sampler2D _GroundTex;
        fixed4 _GroundColor;
		sampler2D _MudTex;
        fixed4 _MudColor;

        struct Input
        {
            float2 uv_GroundTex;
			float2 uv_MudTex;
			float2 uv_Splat;
        };

        half _Glossiness;
        half _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			half amount = tex2Dlod(_Splat, float4(IN.uv_Splat,0,0)).r;
			fixed4 c = lerp(tex2D (_MudTex, IN.uv_MudTex) * _MudColor, tex2D (_GroundTex, IN.uv_GroundTex) * _GroundColor, amount);

            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
