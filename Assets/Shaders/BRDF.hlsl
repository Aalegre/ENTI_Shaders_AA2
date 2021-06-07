#ifndef UNITY_BRDF
#define UNITY_BRDF

static const float PI = 3.14159265;

// - FRESNEL

float Fresnel(float q, float3 lightDir, float3 halfDir){
	return pow((q + (1.0 - q)) * (1.0 - dot(halfDir, lightDir)), 5.0);
}
float Fresnel2(float q, float3 lightDir, float3 halfDir){
	return (q + (1.0 - q) * pow(1.0 - dot(lightDir, halfDir),5.0));
}
// - FRESNEL


// - DISTRIBUTION

float Distribution_Blinn(float alpha, float3 normalDir, float3 halfDir){
	return (1.0 / (PI * alpha)) * pow(dot(normalDir, halfDir), (2.0 / (alpha * alpha)) - 2.0);
}
float Distribution_Blinn2(float alpha, float3 normalDir, float3 halfDir){
	return pow(max(dot(halfDir, normalDir), 0.0), alpha);
}

float Distribution_Beckmann(float alpha, float3 normalDir, float3 halfDir){
	float dotVec = dot(normalDir, halfDir);
	return (1.0 / (PI * alpha * alpha * pow(dotVec, 4.0))) * exp(((dotVec * dotVec) - 1.0) / (alpha * alpha * dotVec * dotVec));
}

// usar esta
float Distribution_GGX(float alpha, float3 normalDir, float3 halfDir){
	return (alpha * alpha) / (PI * pow(pow(dot(halfDir, normalDir), 2.0) * (alpha * alpha - 1.0) + 1.0, 2.0));
}

// - DISTRIBUTION


// - GEOMETRY

// usar esta
float Geometric_Kelemen(float3 viewDir, float3 normalDir, float3 lightDir, float3 halfDir){
	return (dot(normalDir, lightDir) * dot(normalDir, viewDir)) / pow(dot(viewDir, halfDir), 2);
}

float Geometry_GGX(float alpha, float3 viewDir, float3 normalDir, float3 lightDir){
	float dotVec = dot(normalDir, viewDir);
	return 2.0 * dotVec / dotVec + sqrt(alpha * alpha + (1.0 - alpha * alpha) * dotVec * dotVec);
}

// - GEOMETRY

float BRDF(float alpha, float q, float3 viewDir, float3 normalDir, float3 lightDir){
	float3 halfDir = normalize(viewDir + lightDir);
	return	max((
			Fresnel2(q, lightDir, halfDir)
			* Geometric_Kelemen(viewDir, normalDir, lightDir, halfDir)
			* Distribution_GGX(alpha, normalDir, halfDir)
			), 0)
			/ (4.0 * dot(normalDir, lightDir) * dot(normalDir, viewDir));
}

#endif