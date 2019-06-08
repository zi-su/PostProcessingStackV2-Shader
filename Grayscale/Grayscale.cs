using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(GrayscaleRenderer), PostProcessEvent.AfterStack, "Custom/Grayscale")]
public sealed class Grayscale : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Grayscale effect intensity.")]
    public FloatParameter blend = new FloatParameter { value = 0.5f };
}

public sealed class GrayscaleRenderer : PostProcessEffectRenderer<Grayscale>
{
    Shader _shader = null;
    PropertySheet _sheet = null;
    public override void Init()
    {
        base.Init();
    }
    public override void Render(PostProcessRenderContext context)
    {
        if(_shader == null) _shader = Shader.Find("Hidden/Custom/Grayscale");
        if(_sheet == null) _sheet = context.propertySheets.Get(_shader);
        _sheet.properties.SetFloat("_Blend", settings.blend);
        context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 0);
        //context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 1);
        //context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 2);
    }
}