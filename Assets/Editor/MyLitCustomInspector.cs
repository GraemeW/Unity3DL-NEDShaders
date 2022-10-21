using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class MyLitCustomInspector : ShaderGUI
{
    public enum SurfaceType
    {
        Opaque,
        TransparentBlend,
        TransparentCutout
    }

    public enum FaceRenderingMode
    {
        FrontOnly,
        NoCulling,
        DoubleSided
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (newShader.name == "NedMakesGames/MyLit")
        {
            UpdateSurfaceType(material);
        }
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material material = materialEditor.target as Material;
        MaterialProperty surfaceProperty = BaseShaderGUI.FindProperty("_SurfaceType", properties, true);
        MaterialProperty faceProperty = BaseShaderGUI.FindProperty("_FaceRenderingMode", properties, true);

        EditorGUI.BeginChangeCheck();
        surfaceProperty.floatValue = (int)(SurfaceType)EditorGUILayout.EnumPopup("Surface type", (SurfaceType)surfaceProperty.floatValue);
        faceProperty.floatValue = (int)(FaceRenderingMode)EditorGUILayout.EnumPopup("Face rendering mode", (FaceRenderingMode)faceProperty.floatValue);
        if (EditorGUI.EndChangeCheck())
        {
            UpdateSurfaceType(material);
            UpdateFaceRenderingMode(material);
        }

        base.OnGUI(materialEditor, properties);
    }

    private void UpdateSurfaceType(Material material)
    {
        SurfaceType surface = (SurfaceType)material.GetFloat("_SurfaceType");
        SetRenderProperties(material, surface);
        SetBlendProperties(material, surface);
        material.SetShaderPassEnabled("ShadowCaster", surface != SurfaceType.TransparentBlend); // Disable shadows on full transparencies

        // Handle cutout clipping
        if (surface == SurfaceType.TransparentCutout)
        {
            material.EnableKeyword("_ALPHA_CUTOUT");
        }
        else
        {
            material.DisableKeyword("_ALPHA_CUTOUT");
        }
    }

    private void UpdateFaceRenderingMode(Material material)
    {
        FaceRenderingMode faceRenderingMode = (FaceRenderingMode)material.GetFloat("_FaceRenderingMode");
        if (faceRenderingMode == FaceRenderingMode.FrontOnly)
        {
            material.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Back);
        }
        else
        {
            material.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Off);
        }

        if (faceRenderingMode == FaceRenderingMode.DoubleSided)
        {
            material.EnableKeyword("_DOUBLE_SIDED_NORMALS");
        }
        else
        {
            material.DisableKeyword("_DOUBLE_SIDED_NORMALS");
        }
    }

    private static void SetRenderProperties(Material material, SurfaceType surface)
    {
        switch (surface)
        {
            case SurfaceType.Opaque:
                material.renderQueue = (int)RenderQueue.Geometry;
                material.SetOverrideTag("RenderType", "Opaque");
                break;
            case SurfaceType.TransparentCutout:
                material.renderQueue = (int)RenderQueue.AlphaTest;
                material.SetOverrideTag("RenderType", "TransparentCutout");
                break;
            case SurfaceType.TransparentBlend:
                material.renderQueue = (int)RenderQueue.Transparent;
                material.SetOverrideTag("RenderType", "Transparent");
                break;
        }
    }

    private static void SetBlendProperties(Material material, SurfaceType surface)
    {
        switch (surface)
        {
            case SurfaceType.Opaque:
            case SurfaceType.TransparentCutout:
                material.SetInt("_SourceBlend", (int)BlendMode.One);
                material.SetInt("_DestinationBlend", (int)BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                break;
            case SurfaceType.TransparentBlend:
                material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                material.SetInt("_DestinationBlend", (int)BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                break;

        }
    }
}