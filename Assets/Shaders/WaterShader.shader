Shader "Custom/WaterShader"
{
    Properties
    {
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
        [ShowAsVector2] _OffsetSpeed ("_OffsetSpeed", Vector) = (0,0,0,0)
        _BumpTex ("Bump", 2D) = "white" {}
        _BumpStrength ("_BumpStrength", Range(0,1)) = 0.05
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Voronoi_Tiling ("_Voronoi_Tiling", Float) = 5
        _Voronoi_Speed ("_Voronoi_Speed", Float) = 50
        _Voronoi_Start ("_Voronoi_Start", Range(0,1)) = 0.0
        _Voronoi_End ("_Voronoi_End", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha
        OneMinusSrcAlpha
        Cull Off
        LOD 100

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _BumpTex;

        struct Input
        {
            float2 uv_BumpTex;
        };

        half _BumpStrength;
        half _Glossiness;
        half _Metallic;
        fixed2 _OffsetSpeed;
        fixed4 _ColorA;
        fixed4 _ColorB;

        half _Voronoi_Tiling;
        half _Voronoi_Speed;
        half _Voronoi_Start;
        half _Voronoi_End;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        inline float2 voronoiEdges_noise_randomVector(float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)) * 46839.32);
            return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
        }
        half2 VoronoiEdges2(half2 UV, half AngleOffset, half CellDensity, half tiling)
        {
            half Cells = 0;
            half Out = 0;
            half2 g = floor(UV * CellDensity);
            half2 f = frac(UV * CellDensity);
            half2 res = half2(8.0, 8.0);
            half2 ml = half2(0, 0);
            half2 mv = half2(0, 0);

            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    half2 lattice = half2(x, y);
                    if (tiling > 0)
                    {
                        lattice = lattice % tiling;
                    }
                    half2 offset = voronoiEdges_noise_randomVector(g + lattice, AngleOffset);
                    half2 v = lattice + offset - f;
                    half d = dot(v, v);

                    if (d < res.x)
                    {
                        res.x = d;
                        res.y = offset.x;
                        mv = v;
                        ml = lattice;
                    }
                }
            }

            Cells = res.y;

            res = half2(8.0, 8.0);
            for (int y = -2; y <= 2; y++)
            {
                for (int x = -2; x <= 2; x++)
                {
                    half2 lattice = ml + half2(x, y);
                    if (tiling > 0)
                    {
                        lattice = lattice % tiling;
                    }
                    half2 offset = voronoiEdges_noise_randomVector(g + lattice, AngleOffset);
                    half2 v = lattice + offset - f;

                    half2 cellDifference = abs(ml - lattice);
                    if (cellDifference.x + cellDifference.y > 0.1)
                    {
                        half d = dot(0.5 * (mv + v), normalize(v - mv));
                        res.x = min(res.x, d);
                    }
                }
            }

            Out = res.x;
            return half2(Out, Cells);
        }
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half2 modifiedUV = IN.uv_BumpTex;
            modifiedUV.x -= _SinTime.x * 0.1;
            modifiedUV.y += _CosTime.x * 0.1;
            fixed3 n1 = UnpackNormal(tex2D(_BumpTex, modifiedUV));
            modifiedUV = IN.uv_BumpTex;
            modifiedUV.x -= _SinTime.x * 0.1;
            modifiedUV.y += _CosTime.x * 0.1;
            fixed3 n2 = UnpackNormal(tex2D(_BumpTex, modifiedUV));
            fixed3 n = (n1 * _BumpStrength) + (n2 * _BumpStrength);
            modifiedUV = IN.uv_BumpTex;
            modifiedUV.x += n.r;
            modifiedUV.y += n.g;
            modifiedUV.x += _SinTime.x * 0.05;
            modifiedUV.y += _CosTime.x * 0.05;
            modifiedUV.x += _OffsetSpeed.x * _Time.y;
            modifiedUV.y += _OffsetSpeed.y * _Time.y;
            half2 voronoi = VoronoiEdges2(modifiedUV, 10.0 + _Time.y * _Voronoi_Speed, _Voronoi_Tiling, 100);
            half4 col = lerp(_ColorA, _ColorB, smoothstep(_Voronoi_Start, _Voronoi_End, voronoi.r));
            o.Albedo = col.rgb;
            n = (n1 * 0.5) + (n2 * 0.5);
            o.Normal = n.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
