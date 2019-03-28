Shader "Custom/ColorChanger"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MaskColor("Mask Color", Color) = (1,1,1,1)
		_ReplaceColor("Replace Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MaskTex("Mask", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex, _MaskTex;

        struct Input
        {
            float2	uv_MainTex, uv_MaskTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color, _MaskColor, _ReplaceColor;

        UNITY_INSTANCING_BUFFER_START(Props)
			//UNITY_DEFINE_INSTANCED_PROP(fixed4, _ReplaceColor)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// Check if the current uv coordinates color corresponds with the mask color
			float isMask = tex2D(_MaskTex, IN.uv_MaskTex) == _MaskColor;

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = /*(1 - isMask) **/ c.rgb + isMask * _ReplaceColor;
			//o.Albedo = (1 - isMask) *  o.Albedo + isMask * UNITY_ACCESS_INSTANCED_PROP(Props, _ReplaceColor);

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
