using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(renderer: typeof(MisregistrationRenderer),
    PostProcessEvent.AfterStack,
    "Custom/Misregistration")]


public sealed class Misregistration : PostProcessEffectSettings
{
    [Range(0,1), Tooltip("Intensidad")]
    public FloatParameter _Strength = new FloatParameter { };
    [Space]
    [Header("Mascaras")]
    [Tooltip("Textura mascara")]
    public TextureParameter _Mask = new TextureParameter { };
    [Tooltip("Escala mascara")]
    public FloatParameter _Scale = new FloatParameter { value = 0.0005f };
    [Space]
    [Tooltip("Opciones de mascara para cian, xy: offset, z: rotacion, w: fuerza")]
    public Vector4Parameter _ORS_C = new Vector4Parameter { value = new Vector4(0.5f, 0f, 0.5f, 10f) };
    [Tooltip("Opciones de mascara para magenta, xy: offset, z: rotacion, w: fuerza")]
    public Vector4Parameter _ORS_M = new Vector4Parameter { value = new Vector4(0.25f, 0.5f, -0.5f, 10f) };
    [Tooltip("Opciones de mascara para amarillo, xy: offset, z: rotacion, w: fuerza")]
    public Vector4Parameter _ORS_Y = new Vector4Parameter { value = new Vector4(0f, 0f, 0f, 10f) };
    [Tooltip("Opciones de mascara para negro, xy: offset, z: rotacion, w: fuerza")]
    public Vector4Parameter _ORS_K = new Vector4Parameter { value = new Vector4(0f, 0f, 0.785398f, 1f) };
}

public class MisregistrationRenderer : PostProcessEffectRenderer<Misregistration>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Misregistration"));
        sheet.properties.SetFloat("_Strength", settings._Strength);
        if(settings._Mask.value)
        sheet.properties.SetTexture("_Mask", settings._Mask);
        sheet.properties.SetFloat("_Scale", settings._Scale);
        sheet.properties.SetVector("_ORS_C", settings._ORS_C);
        sheet.properties.SetVector("_ORS_M", settings._ORS_M);
        sheet.properties.SetVector("_ORS_Y", settings._ORS_Y);
        sheet.properties.SetVector("_ORS_K", settings._ORS_K);
        Vector4 texelSize = Vector4.zero;
        texelSize.z = context.camera.pixelWidth;
        texelSize.w = context.camera.pixelHeight;
        texelSize.x = 1f / texelSize.z;
        texelSize.y = 1f / texelSize.w;
        sheet.properties.SetVector("_MainTex_TexelSize", texelSize);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

