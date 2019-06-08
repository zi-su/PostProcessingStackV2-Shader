using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(GaussianBlurRenderer), PostProcessEvent.AfterStack, "Custom/GaussianBlur")]
public sealed class GaussianBlur : PostProcessEffectSettings
{
    [Range(1, 100), Tooltip("GaussianBlur effect intensity.")]
    public IntParameter samplingCount = new IntParameter { value = 1 };
}

public sealed class GaussianBlurRenderer : PostProcessEffectRenderer<GaussianBlur>
{
    Shader _shader = null;
    PropertySheet _sheet = null;
    public override void Render(PostProcessRenderContext context)
    {
        if (_shader == null) _shader = Shader.Find("Hidden/Custom/GaussianBlur");
        if (_sheet == null) _sheet = context.propertySheets.Get(_shader);
        _sheet.properties.SetInt("_SamplingCount", settings.samplingCount);

        {
            context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 0);
            context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 1);
            context.command.BlitFullscreenTriangle(context.source, context.destination, _sheet, 2);
        }
        
    }
}