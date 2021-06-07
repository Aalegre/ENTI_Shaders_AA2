using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(renderer: typeof(DOF_BokehRenderer),
    PostProcessEvent.BeforeStack,
    "Custom/DOF_Bokeh", false)]


public sealed class DOF_Bokeh : PostProcessEffectSettings
{
    [Tooltip("Muestra rango de enfoque")]
    public BoolParameter _Debug = new BoolParameter { value = false };


    [Tooltip("Distancia a la que enfocar")]
    public FloatParameter _FocusDistance = new FloatParameter { value = 10.0f };
    [Tooltip("Potencia de enfoque")]
    public FloatParameter _FocusRange = new FloatParameter { value = 1.0f };
    [Range(0, 10), Tooltip("Radio de Bokeh")]
    public FloatParameter _Radius = new FloatParameter { value = 1.0f };
    [Range(1, 5), Tooltip("Calidad del bokeh")]
    public IntParameter _Quality = new IntParameter { value = 1 };
}

public class DOF_BokehRenderer : PostProcessEffectRenderer<DOF_Bokeh>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/DOF_Bokeh"));
        sheet.properties.SetFloat("_FocusDistance", settings._FocusDistance);
        sheet.properties.SetFloat("_FocusRange", settings._FocusRange);
        settings._Radius.value = Mathf.Max(0.00001f, settings._Radius.value) * 0.001f;
        sheet.properties.SetFloat("_Radius", settings._Radius);
        if (settings._Debug)
            sheet.EnableKeyword("RAW_DEPTH");
        else
            sheet.DisableKeyword("RAW_DEPTH");
        switch (settings._Quality)
        {
            case 2:
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRALOW");
                sheet.EnableKeyword("_QUALITYBOKEH_LOW");
                sheet.DisableKeyword("_QUALITYBOKEH_MEDIUM");
                sheet.DisableKeyword("_QUALITYBOKEH_HIGH");
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRA");
                break;
            case 3:
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRALOW");
                sheet.DisableKeyword("_QUALITYBOKEH_LOW");
                sheet.EnableKeyword("_QUALITYBOKEH_MEDIUM");
                sheet.DisableKeyword("_QUALITYBOKEH_HIGH");
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRA");
                break;
            case 4:
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRALOW");
                sheet.DisableKeyword("_QUALITYBOKEH_LOW");
                sheet.DisableKeyword("_QUALITYBOKEH_MEDIUM");
                sheet.EnableKeyword("_QUALITYBOKEH_HIGH");
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRA");
                break;
            case 5:
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRALOW");
                sheet.DisableKeyword("_QUALITYBOKEH_LOW");
                sheet.DisableKeyword("_QUALITYBOKEH_MEDIUM");
                sheet.DisableKeyword("_QUALITYBOKEH_HIGH");
                sheet.EnableKeyword("_QUALITYBOKEH_ULTRA");
                break;
            default:
                sheet.EnableKeyword("_QUALITYBOKEH_ULTRALOW");
                sheet.DisableKeyword("_QUALITYBOKEH_LOW");
                sheet.DisableKeyword("_QUALITYBOKEH_MEDIUM");
                sheet.DisableKeyword("_QUALITYBOKEH_HIGH");
                sheet.DisableKeyword("_QUALITYBOKEH_ULTRA");
                break;
        }
        Vector4 texelSize = Vector4.zero;
        texelSize.z = context.camera.pixelWidth;
        texelSize.w = context.camera.pixelHeight;
        texelSize.x = 1 / texelSize.z;
        texelSize.y = 1 / texelSize.w;
        sheet.properties.SetVector("_MainTex_TexelSize", texelSize);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

