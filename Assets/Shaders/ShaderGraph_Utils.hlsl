#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED

void GaussianV_float(float _blurSize, Texture2D _texture, SamplerState _textureSampler, float2 _UVs, out float4 color_)
{
    color_ = float4(0,0,0,0);
    float2 tempUvs = float2(_UVs.x, _UVs.y - 4.0 * _blurSize);
    color_ = color_ + _texture.Sample(_textureSampler, tempUvs) * 0.05;
    tempUvs = (_UVs.x, _UVs.y - 3.0 * _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.09;
    tempUvs = (_UVs.x, _UVs.y - 2.0 * _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.12;
    tempUvs = (_UVs.x, _UVs.y - _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.15;
    tempUvs = (_UVs.x, _UVs.y);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.16;
    tempUvs = (_UVs.x, _UVs.y + _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.15;
    tempUvs = (_UVs.x, _UVs.y + 2.0 * _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.12;
    tempUvs = (_UVs.x, _UVs.y + 3.0 * _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.09;
    tempUvs = (_UVs.x, _UVs.y + 4.0 * _blurSize);
    color_ += _texture.Sample(_textureSampler, tempUvs) * 0.05;
}
void Gaussian_half(Texture2D _texture, SamplerState _textureSampler, half _size, half _directions, half _quality, half2 _UVs, out half4 color_) {
    half Pi = 6.28318530718; // Pi*2

    // Pixel colour
    color_ = _texture.Sample(_textureSampler,_UVs);

    // Blur calculations
    for (float d = 0.0; d < Pi; d += Pi / _directions)
    {
        for (float i = 1.0 / _quality; i <= 1.0; i += 1.0 / _quality)
        {
            color_ += _texture.Sample(_textureSampler,_UVs + half2(cos(d), sin(d)) * _size * i);
        }
    }

    color_ /= _quality * _directions - 15.0;
}
void GetMax_half(half4 _in, bool _detectBlack, out half4 out_) {
    out_ = half4(0, 0, 0, 0);
    if (_detectBlack &&
        _in.r == 0 &&
        _in.g == 0 &&
        _in.b == 0 &&
        _in.a == 0
        ) {
    }
    else {
        if (_in.r > _in.g) {
            if (_in.r > _in.b) {
                if (_in.r > _in.a) {
                    out_.r = 1;
                }
                else {
                    out_.a = 1;
                }
            }
            else {
                if (_in.b > _in.a) {
                    out_.b = 1;
                }
                else {
                    out_.a = 1;
                }
            }
        }
        else {
            if (_in.g > _in.b) {
                if (_in.g > _in.a) {
                    out_.g = 1;
                }
                else {
                    out_.a = 1;
                }
            }
            else {
                if (_in.b > _in.a) {
                    out_.b = 1;
                }
                else {
                    out_.a = 1;
                }
            }
        }
    }

}
//void GaussianH_float(float _blurSize, sampler2D _texture, float2 _UVs, out float4 color_)
//{
//    color_ += texture2D(_texture, float2(_UVs.x - 4.0 * _blurSize), _UVs.y) * 0.05;
//    color_ += texture2D(_texture, float2(_UVs.x - 3.0 * _blurSize), _UVs.y) * 0.09;
//    color_ += texture2D(_texture, float2(_UVs.x - 2.0 * _blurSize), _UVs.y) * 0.12;
//    color_ += texture2D(_texture, float2(_UVs.x - _blurSize, _UVs.y)) * 0.15;
//    color_ += texture2D(_texture, float2(_UVs.x, _UVs.y)) * 0.16;
//    color_ += texture2D(_texture, float2(_UVs.x + _blurSize, _UVs.y)) * 0.15;
//    color_ += texture2D(_texture, float2(_UVs.x + 2.0 * _blurSize, _UVs.y)) * 0.12;
//    color_ += texture2D(_texture, float2(_UVs.x + 3.0 * _blurSize, _UVs.y)) * 0.09;
//    color_ += texture2D(_texture, float2(_UVs.x + 4.0 * _blurSize, _UVs.y)) * 0.05;
//}

void GrayscaleAccurate_float(float3 _color, out float _gray) {
    _gray = (_color.r * 0.2126) + (_color.g * 0.7152) + (_color.b * 0.7152);
}

void GrayscaleSimple_float(float3 _color, out float _gray) {
    _color *= (1.0 / 3.0);
    _gray = _color.r + _color.g + _color.b;
}

inline float2 voronoiEdges_noise_randomVector(float2 UV, float offset) {
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}


void VoronoiEdges_half(half2 UV, half AngleOffset, half CellDensity, out half2 Out, out half Cells) {
    half2 g = floor(UV * CellDensity);
    half2 f = frac(UV * CellDensity);
    half3 res = half3(8.0, 8.0, 8.0);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            half2 lattice = half2(x, y);
            half2 offset = voronoiEdges_noise_randomVector(g + lattice, AngleOffset);
            half2 v = lattice + offset - f;
            half d = dot(v, v);

            if (d < res.x) {
                res.y = res.x;
                res.x = d;
                res.z = offset.x;
            }
            else if (d < res.y) {
                res.y = d;
            }
        }
    }

    Out = half2(sqrt(res.x), sqrt(res.y));
    Cells = res.z;
}

inline half2 modulo(half2 divident, half2 divisor){
    half2 positiveDivident = divident % divisor + divisor;
    return positiveDivident % divisor;
}

void VoronoiEdges2_half(half2 UV, half AngleOffset, half CellDensity, half tiling, out half Out, out half Cells) {
    half2 g = floor(UV * CellDensity);
    half2 f = frac(UV * CellDensity);
    half2 res = half2(8.0, 8.0);
    half2 ml = half2(0, 0);
    half2 mv = half2(0, 0);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            half2 lattice = half2(x, y);
            if(tiling > 0){
                lattice = modulo(lattice, tiling);
            }
            half2 offset = voronoiEdges_noise_randomVector(g + lattice, AngleOffset);
            half2 v = lattice + offset - f;
            half d = dot(v, v);

            if (d < res.x) {
                res.x = d;
                res.y = offset.x;
                mv = v;
                ml = lattice;
            }
        }
    }

    Cells = res.y;

    res = half2(8.0, 8.0);
    for (int y = -2; y <= 2; y++) {
        for (int x = -2; x <= 2; x++) {
            half2 lattice = ml + half2(x, y);
            if(tiling > 0){
                lattice = modulo(lattice, tiling);
            }
            half2 offset = voronoiEdges_noise_randomVector(g + lattice, AngleOffset);
            half2 v = lattice + offset - f;

            half2 cellDifference = abs(ml - lattice);
            if (cellDifference.x + cellDifference.y > 0.1) {
                half d = dot(0.5 * (mv + v), normalize(v - mv));
                res.x = min(res.x, d);
            }
        }
    }

    Out = res.x;
}


half fract(half f){return f - floor(f);}
half mod289(half x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
half4 mod289(half4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
half4 perm(half4 x){return mod289(((x * 34.0) + 1.0) * x);}

void NoiseThree_half(half3 p, out half Out_){
    half3 a = floor(p);
    half3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    half4 b = a.xxyy + half4(0.0, 1.0, 0.0, 1.0);
    half4 k1 = perm(b.xyxy);
    half4 k2 = perm(k1.xyxy + b.zzww);

    half4 c = k2 + a.zzzz;
    half4 k3 = perm(c);
    half4 k4 = perm(c + 1.0);

    half4 o1 = fract(k3 * (1.0 / 41.0));
    half4 o2 = fract(k4 * (1.0 / 41.0));

    half4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    half2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
    Out_ = o4.y * d.y + o4.x * (1.0 - d.y);
}


void Max_half(half _r, half _g, half _b, half Out_) {
    if (_r > _g && _r > _b) {
        Out_ = _b;
        return;
    }
    else if (_g > _r && _g > _b) {
        Out_ = _g;
        return;
    }
    else {
        Out_ = _b;
        return;
    }
}
void Random_half(half2 _Seed, out half Out_)
{
    Out_ = frac(sin(dot(_Seed, half2(12.9898, 78.233))) * 43758.5453);
}
void RandomRange_half(half2 _Seed, half _Min, half _Max, out half Out_)
{
    half randomno = 0;
    Random_half(_Seed, randomno);
    Out_ = lerp(_Min, _Max, randomno);
}
inline void Exponential_half(half _Exp, half _x, out half Out_) {
    Out_ = (pow(_Exp + 1, _x) - 1) / _Exp;
}
void ColorspaceConversion_RGB_HSV_half(half3 _In, out half3 Out_)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 P = lerp(half4(_In.bg, K.wz), half4(_In.gb, K.xy), step(_In.b, _In.g));
    half4 Q = lerp(half4(P.xyw, _In.r), half4(_In.r, P.yzx), step(P.x, _In.r));
    half D = Q.x - min(Q.w, Q.y);
    half E = 1e-10;
    Out_ = half3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
}

void ColorspaceConversion_HSV_RGB_half(half3 _In, out half3 Out_)
{
    half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 P = abs(frac(_In.xxx + K.xyz) * 6.0 - K.www);
    Out_ = _In.z * lerp(K.xxx, saturate(P - K.xxx), _In.y);
}

void Saturation_half(half3 _In, half Saturation, out half3 Out_)
{
    half luma = dot(_In, half3(0.2126729, 0.7151522, 0.0721750));
    Out_ = luma.xxx + Saturation.xxx * (_In - luma.xxx);
}

float4 StochSampler(Texture2D tex, SamplerState ss, float2 uv)
{
    //get derivatives to avoid triangular artifacts
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);
    //skew the uv to create triangular grid
    float2 skewUV = mul(float2x2 (1.0, 0.0, -0.57735027, 1.15470054), uv * 3.464);

    //vertices on the triangular grid
    float2 vertID = float2(floor(skewUV));

    //barycentric coordinates of uv position
    float3 temp = float3(frac(skewUV), 0);
    temp.z = 1.0 - temp.x - temp.y;

    //each vertex on the grid gets an according weight value
    float2 vertA, vertB, vertC;
    float weightA, weightB, weightC;

    //determine which triangle we're in
    if (temp.z > 0.0)
    {
        weightA = temp.z;
        weightB = temp.y;
        weightC = temp.x;
        vertA = vertID;
        vertB = vertID + float2(0, 1);
        vertC = vertID + float2(1, 0);
    }
    else
    {
        weightA = -temp.z;
        weightB = 1.0 - temp.y;
        weightC = 1.0 - temp.x;
        vertA = vertID + float2(1, 1);
        vertB = vertID + float2(1, 0);
        vertC = vertID + float2(0, 1);
    }

    //offset uvs using magic numbers
    float2 randomA = uv + frac(sin(fmod(float2(dot(vertA, float2(127.1, 311.7)), dot(vertA, float2(269.5, 183.3))), 3.14159)) * 43758.5453);
    float2 randomB = uv + frac(sin(fmod(float2(dot(vertB, float2(127.1, 311.7)), dot(vertB, float2(269.5, 183.3))), 3.14159)) * 43758.5453);
    float2 randomC = uv + frac(sin(fmod(float2(dot(vertC, float2(127.1, 311.7)), dot(vertC, float2(269.5, 183.3))), 3.14159)) * 43758.5453);

    //get texture samples
    float4 sampleA = float4(1, 1, 1, 1);
    float4 sampleB = float4(1, 1, 1, 1);
    float4 sampleC = float4(1, 1, 1, 1);

    if(weightA <= 0){
            
    } else {
        sampleA = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomA, dx, dy);
    }
    if(weightB <= 0){
            
    } else {
        sampleB = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomB, dx, dy);
    }
    if(weightC <= 0){
            
    } else {
        sampleC = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomC, dx, dy);
    }

    //blend samples with weights	
    return sampleA * weightA + sampleB * weightB + sampleC * weightC;
}
half4 StochSamplerHalf(Texture2D tex, SamplerState ss, half2 uv)
{
    //get derivatives to avoid triangular artifacts
    half2 dx = ddx(uv);
    half2 dy = ddy(uv);

    //skew the uv to create triangular grid
    half2 skewUV = mul(half2x2 (1.0, 0.0, -0.57735027, 1.15470054), uv * 3.464);

    //vertices on the triangular grid
    half2 vertID = int2(floor(skewUV));

    //barycentric coordinates of uv position
    half3 temp = half3(frac(skewUV), 0);
    temp.z = 1.0 - temp.x - temp.y;

    //each vertex on the grid gets an according weight value
    half2 vertA, vertB, vertC;
    half weightA, weightB, weightC;

    //determine which triangle we're in
    if (temp.z > 0.0)
    {
        weightA = temp.z;
        weightB = temp.y;
        weightC = temp.x;
        vertA = vertID;
        vertB = vertID + half2(0, 1);
        vertC = vertID + half2(1, 0);
    }
    else
    {
        weightA = -temp.z;
        weightB = 1.0 - temp.y;
        weightC = 1.0 - temp.x;
        vertA = vertID + half2(1, 1);
        vertB = vertID + half2(1, 0);
        vertC = vertID + half2(0, 1);
    }

    //offset uvs using magic numbers
    half2 randomA = uv + frac(sin(fmod(half2(dot(vertA, half2(127.1, 311.7)), dot(vertA, half2(269.5, 183.3))), 3.14159)) * 43758.5453);
    half2 randomB = uv + frac(sin(fmod(half2(dot(vertB, half2(127.1, 311.7)), dot(vertB, half2(269.5, 183.3))), 3.14159)) * 43758.5453);
    half2 randomC = uv + frac(sin(fmod(half2(dot(vertC, half2(127.1, 311.7)), dot(vertC, half2(269.5, 183.3))), 3.14159)) * 43758.5453);
    
    //get texture samples
    float4 sampleA = float4(1, 1, 1, 1);
    float4 sampleB = float4(1, 1, 1, 1);
    float4 sampleC = float4(1, 1, 1, 1);

    if(weightA <= 0){
            
    } else {
        sampleA = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomA, dx, dy);
    }
    if(weightB <= 0){
            
    } else {
        sampleB = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomB, dx, dy);
    }
    if(weightC <= 0){
            
    } else {
        sampleC = SAMPLE_TEXTURE2D_GRAD(tex, ss, randomC, dx, dy);
    }

    //blend samples with weights	
    return sampleA * weightA + sampleB * weightB + sampleC * weightC;
}
float4 hash4_float( float2 p ) {
    float temp = sin(float4( 1.0+dot(p,float2(37.0,17.0)), 2.0+dot(p,float2(11.0,47.0)), 3.0+dot(p,float2(41.0,29.0)), 4.0+dot(p,float2(23.0,31.0))))*103.0;
    return temp - floor( temp );
}
half4 hash4_half( half2 p ) {
    half temp = sin(half4( 1.0+dot(p,half2(37.0,17.0)), 2.0+dot(p,half2(11.0,47.0)), 3.0+dot(p,half2(41.0,29.0)), 4.0+dot(p,half2(23.0,31.0))))*103.0;
    return temp - floor( temp );
}
float4 VoronoiSampler(Texture2D tex, SamplerState ss, float2 uv)
{
    float2 p = floor( uv );
    float2 f = uv - floor( uv );
	
    // derivatives (for correct mipmapping)
    float2 dx = ddx( uv );
    float2 dy = ddy( uv );
    
    // voronoi contribution
    float4 va = float4(0.0, 0.0, 0.0, 0.0);
    float wt = 0.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            float2 g = float2( float(i), float(j) );
            float4 o = hash4_float( p + g );
            float2 r = g - f + o.xy;
            float d = dot(r,r);
            float w = exp(-5.0*d );
            float4 c = SAMPLE_TEXTURE2D_GRAD( tex, ss, uv + o.zw, dx, dy );
            va += w*c;
            wt += w;
        }
	
    // normalization
    return va/wt;
}
half4 VoronoiSamplerHalf(Texture2D tex, SamplerState ss, half2 uv)
{
    half2 p = floor( uv );
    half2 f = uv - floor( uv );
	
    // derivatives (for correct mipmapping)
    half2 dx = ddx( uv );
    half2 dy = ddy( uv );
    
    // voronoi contribution
    half4 va = half4(0.0, 0.0, 0.0, 0.0);
    half wt = 0.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            half2 g = half2( half(i), half(j) );
            half4 o = hash4_float( p + g );
            half2 r = g - f + o.xy;
            half d = dot(r,r);
            half w = exp(-5.0*d );
            half4 c = SAMPLE_TEXTURE2D_GRAD( tex, ss, uv + o.zw, dx, dy );
            va += w*c;
            wt += w;
        }
	
    // normalization
    return va/wt;
}

void StochSample_float(Texture2D tex, SamplerState ss, float2 uv, out float4 Out_)
{
    Out_ = StochSampler(tex, ss, uv);
}
void StochSample_half(Texture2D tex, SamplerState ss, half2 uv, out half4 Out_)
{
    Out_ = StochSamplerHalf(tex, ss, uv);
}

void StochTriplanar_float(Texture2D Texture, float3 Position, float3 Normal, float Tile, float Blend, SamplerState Sampler, bool dontExecute, out float4 Out_) {
    if(dontExecute){
        Out_ = (1,1,1,1);
    } else {
        float3 Node_UV = Position * Tile;
        float3 Node_Blend = pow(abs(Normal), Blend);
        Node_Blend /= dot(Node_Blend, 1.0);
        float4 Node_X = float4(1, 1, 1, 1);
        float4 Node_Y = float4(1, 1, 1, 1);
        float4 Node_Z = float4(1, 1, 1, 1);
        if (Node_Blend.x <= 0.0) {

        }
        else
            Node_X = StochSampler(Texture, Sampler, Node_UV.zy);
        if (Node_Blend.y <= 0.0) {

        }
        else
            Node_Y = StochSampler(Texture, Sampler, Node_UV.xz);
        if (Node_Blend.z <= 0.0) {

        }
        else
            Node_Z = StochSampler(Texture, Sampler, Node_UV.xy);
        //Out_ = float4(0, 0, 0, 0);
        Out_ = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
    }
}
void StochTriplanar_half(Texture2D Texture, half3 Position, half3 Normal, half Tile, half Blend, SamplerState Sampler, bool dontExecute, out half4 Out_) {
    if(dontExecute){
        Out_ = (1,1,1,1);
    } else {
        half3 Node_UV = Position * Tile;
        half3 Node_Blend = pow(abs(Normal), Blend);
        Node_Blend /= dot(Node_Blend, 1.0);
        half4 Node_X = half4(1, 1, 1, 1);
        half4 Node_Y = half4(1, 1, 1, 1);
        half4 Node_Z = half4(1, 1, 1, 1);
        if (Node_Blend.x <= 0.0) {

        }
        else
            Node_X = StochSamplerHalf(Texture, Sampler, Node_UV.zy);
        if (Node_Blend.y <= 0.0) {

        }
        else
            Node_Y = StochSamplerHalf(Texture, Sampler, Node_UV.xz);
        if (Node_Blend.z <= 0.0) {

        }
        else
            Node_Z = StochSamplerHalf(Texture, Sampler, Node_UV.xy);
        //Out_ = half4(0, 0, 0, 0);
        Out_ = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
    }
}
void StochTriplanarNormal_float(Texture2D Texture, float3 Position, float3 Normal, float3 Tangent, float3 BiTangent, float Tile, float Blend, SamplerState Sampler, bool dontExecute, out float3 Out_) {
    if(dontExecute){
        Out_ = Normal;
    } else {
        float3 Node_UV = Position * Tile;
        float3 Node_Blend = max(pow(abs(Normal), Blend), 0);
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z).xxx;
        float3 Node_X = float3(1, 1, 1);
        float3 Node_Y = float3(1, 1, 1);
        float3 Node_Z = float3(1, 1, 1);
        if (Node_Blend.x <= 0.0) {

        }
        else
            Node_X = UnpackNormalmapRGorAG(StochSampler(Texture, Sampler, Node_UV.zy));
        if (Node_Blend.y <= 0.0) {

        }
        else
            Node_Y = UnpackNormalmapRGorAG(StochSampler(Texture, Sampler, Node_UV.xz));
        if (Node_Blend.z <= 0.0) {

        }
        else
            Node_Z = UnpackNormalmapRGorAG(StochSampler(Texture, Sampler, Node_UV.xy));
        Node_X = float3(Node_X.xy + Normal.zy, abs(Node_X.z) * Normal.x);
        Node_Y = float3(Node_Y.xy + Normal.xz, abs(Node_Y.z) * Normal.y);
        Node_Z = float3(Node_Z.xy + Normal.xy, abs(Node_Z.z) * Normal.z);
        //Out_ = float4(0, 0, 0, 0);
        Out_ = normalize(Node_X.zyx * Node_Blend.x + Node_Y.xzy * Node_Blend.y + Node_Z.xyz * Node_Blend.z);
        float3x3 TBN = float3x3(Tangent, BiTangent, Normal);
        Out_ = TransformWorldToTangent(Out_, TBN);
    }
}
void StochTriplanarNormal_half(Texture2D Texture, half3 Position, half3 Normal, half3 Tangent, half3 BiTangent, half Tile, half Blend, SamplerState Sampler, bool dontExecute, out half3 Out_) {
    if(dontExecute){
        Out_ = Normal;
    } else {
        half3 Node_UV = Position * Tile;
        half3 Node_Blend = max(pow(abs(Normal), Blend), 0);
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z).xxx;
        half3 Node_X = half3(1, 1, 1);
        half3 Node_Y = half3(1, 1, 1);
        half3 Node_Z = half3(1, 1, 1);
        if (Node_Blend.x <= 0.0) {

        }
        else
            Node_X = UnpackNormalmapRGorAG(StochSamplerHalf(Texture, Sampler, Node_UV.zy));
        if (Node_Blend.y <= 0.0) {

        }
        else
            Node_Y = UnpackNormalmapRGorAG(StochSamplerHalf(Texture, Sampler, Node_UV.xz));
        if (Node_Blend.z <= 0.0) {

        }
        else
            Node_Z = UnpackNormalmapRGorAG(StochSamplerHalf(Texture, Sampler, Node_UV.xy));
        Node_X = half3(Node_X.xy + Normal.zy, abs(Node_X.z) * Normal.x);
        Node_Y = half3(Node_Y.xy + Normal.xz, abs(Node_Y.z) * Normal.y);
        Node_Z = half3(Node_Z.xy + Normal.xy, abs(Node_Z.z) * Normal.z);
        //Out_ = half4(0, 0, 0, 0);
        Out_ = normalize(Node_X.zyx * Node_Blend.x + Node_Y.xzy * Node_Blend.y + Node_Z.xyz * Node_Blend.z);
        half3x3 TBN = half3x3(Tangent, BiTangent, Normal);
        Out_ = TransformWorldToTangent(Out_, TBN);
    }
}

#endif