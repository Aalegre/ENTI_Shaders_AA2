using System.Collections;
using System.Collections.Generic;
using UnityEngine; // Obligatorio
using System;
using UnityEngine.Rendering.PostProcessing; // Obligatorio


[Serializable] // Obligatorio
[PostProcess(renderer: typeof(CustomVignitte),//Le indica que script c# vamos a usar (linea 24)
    PostProcessEvent.AfterStack,//Cuando se va a ejecutar el efecto, es mejor dejarlo como está
    "Custom/Vignitte")] //Indicamos la carpeta y el nombre del shader a mostrar en la UI de unity


//Aquí configuramos los inputs que el usuario va a poder modificar, como si fuesen variables de un script normal
public sealed class CustomVignitteSettings : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Intensidad.")]
    public FloatParameter blend = new FloatParameter { value = 0.0f };

    [Tooltip("Color a teñir.")]
    public ColorParameter color = new ColorParameter { value = Color.white };

    public FloatParameter _innerRadius = new FloatParameter { value = 0.0f };
    public FloatParameter _outerRadius = new FloatParameter { value = 0.0f };
}

public class CustomVignitte : PostProcessEffectRenderer<CustomVignitteSettings>//<T> hay que colocar el PostProcessEffectSettings (linea 15)
{
    public override void Render(PostProcessRenderContext context)
    {
        //Cargamos el shader que vamos a usar
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Vignitte"));
        //Aplicamos las opciones que ha seleccionado el usuario:
        sheet.properties.SetFloat("_intensity", settings.blend);
        sheet.properties.SetColor("_color", settings.color);
        sheet.properties.SetFloat("_innerRadius", settings._innerRadius);
        sheet.properties.SetFloat("_outerRadius", settings._outerRadius);
        //Ejecutamos el shader
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

