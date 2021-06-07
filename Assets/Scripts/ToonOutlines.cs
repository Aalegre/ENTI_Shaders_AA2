using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(renderer: typeof(ToonOutlinesRenderer),
    PostProcessEvent.BeforeTransparent,
    "Custom/ToonOutlines")]


public sealed class ToonOutlines : PostProcessEffectSettings
{
    [Tooltip("Muestra solo el outline")]
    public BoolParameter _Debug = new BoolParameter { value = false };


    [Range(0.0005f, 0.0025f), Tooltip("Ancho del outline")]
    public FloatParameter _Delta = new FloatParameter { value = 0.0005f };
    [Range(0,10), Tooltip("Potencia del outline")]
    public FloatParameter _Strength = new FloatParameter { value = 1.0f };
    [Tooltip("Color del outline")]
    public ColorParameter _Color = new ColorParameter { value = Color.black };
}

public class ToonOutlinesRenderer : PostProcessEffectRenderer<ToonOutlines>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/ToonOutlines"));
        sheet.properties.SetFloat("_Delta", settings._Delta);
        sheet.properties.SetFloat("_Strength", settings._Strength);
        sheet.properties.SetColor("_Color", settings._Color);
        if (settings._Debug)
            sheet.EnableKeyword("RAW_OUTLINE");
        else
            sheet.DisableKeyword("RAW_OUTLINE");
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

