using System.Collections;
using System.Collections.Generic;
using UnityEngine; // Obligatorio
using System;
using UnityEngine.Rendering.PostProcessing; // Obligatorio


[Serializable] // Obligatorio
[PostProcess(renderer: typeof(CustomPostpro),//Le indica que script c# vamos a usar (linea 24)
    PostProcessEvent.AfterStack,//Cuando se va a ejecutar el efecto, es mejor dejarlo como está
    "Custom/CustomPostpro")] //Indicamos la carpeta y el nombre del shader a mostrar en la UI de unity


//Aquí configuramos los inputs que el usuario va a poder modificar, como si fuesen variables de un script normal
public sealed class CustomPostproSettings : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Intensidad.")]
    public FloatParameter blend = new FloatParameter { value = 0.0f };

    [Tooltip("Color a teñir.")]
    public ColorParameter color = new ColorParameter { value = Color.white };

    [Tooltip("Vector ejemplo")]
    public Vector4Parameter vector = new Vector4Parameter { value = Vector4.zero };
}

public class CustomPostpro : PostProcessEffectRenderer<CustomPostproSettings>//<T> hay que colocar el PostProcessEffectSettings (linea 15)
{
    public override void Render(PostProcessRenderContext context)
    {
        //Cargamos el shader que vamos a usar
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/CustomPostpro"));
        //Aplicamos las opciones que ha seleccionado el usuario:
        sheet.properties.SetFloat("_intensity", settings.blend);
        sheet.properties.SetColor("_color", settings.color);
        sheet.properties.SetVector("_vector", settings.vector);
        //Ejecutamos el shader
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

