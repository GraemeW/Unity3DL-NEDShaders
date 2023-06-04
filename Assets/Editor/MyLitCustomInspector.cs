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

    public enum BlendType
    {
        Alpha,
        Premultiplied,
        Additive,
        Multiply
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
        MaterialProperty blendProperty = BaseShaderGUI.FindProperty("_BlendType", properties, true);
        MaterialProperty faceProperty = BaseShaderGUI.FindProperty("_FaceRenderingMode", properties, true);

        EditorGUI.BeginChangeCheck();
        surfaceProperty.floatValue = (int)(SurfaceType)EditorGUILayout.EnumPopup("Surface type", (SurfaceType)surfaceProperty.floatValue);
        blendProperty.floatValue = (int)(BlendType)EditorGUILayout.EnumPopup("Blend type", (BlendType)blendProperty.floatValue);
        faceProperty.floatValue = (int)(FaceRenderingMode)EditorGUILayout.EnumPopup("Face rendering mode", (FaceRenderingMode)faceProperty.floatValue);
        base.OnGUI(materialEditor, properties);

        if (EditorGUI.EndChangeCheck())
        {
            UpdateSurfaceType(material);
            UpdateFaceRenderingMode(material);
        }
    }

    private void UpdateSurfaceType(Material material)
    {
        SurfaceType surface = (SurfaceType)material.GetFloat("_SurfaceType");
        BlendType blend = (BlendType)material.GetFloat("_BlendType");

        SetRenderProperties(material, surface);
        SetBlendProperties(material, surface, blend);
        material.SetShaderPassEnabled("ShadowCaster", surface != SurfaceType.TransparentBlend); // Disable shadows on full transparencies

        // Toggle normal map
        if (material.GetTexture("_NormalMap") == null)
        {
            material.DisableKeyword("_NORMALMAP");
        }
        else
        {
            material.EnableKeyword("_NORMALMAP");
        }

        // Handle premultiply
        if (surface == SurfaceType.TransparentBlend && blend == BlendType.Premultiplied)
        {
            material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
        }
        else
        {
            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        }

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

    private static void SetBlendProperties(Material material, SurfaceType surface, BlendType blend)
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
                switch (blend)
                {
                    case BlendType.Alpha:
                        material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                        material.SetInt("_DestinationBlend", (int)BlendMode.OneMinusSrcAlpha);
                        break;
                    case BlendType.Premultiplied:
                        material.SetInt("_SourceBlend", (int)BlendMode.One);
                        material.SetInt("_DestinationBlend", (int)BlendMode.OneMinusSrcAlpha);
                        break;
                    case BlendType.Additive:
                        material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                        material.SetInt("_DestinationBlend", (int)BlendMode.One);
                        break;
                    case BlendType.Multiply:
                        material.SetInt("_SourceBlend", (int)BlendMode.Zero);
                        material.SetInt("_DestinationBlend", (int)BlendMode.SrcColor);
                        break;
                }
                material.SetInt("_ZWrite", 0);
                break;
        }
    }
}