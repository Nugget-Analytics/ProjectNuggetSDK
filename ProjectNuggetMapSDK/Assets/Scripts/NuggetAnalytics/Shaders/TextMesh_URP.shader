Shader "Custom/TextMesh"
{
    Properties
    {
        _MainTex ("Font Texture (Alpha)", 2D) = "white" {}
        _Color ("Text Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        LOD 100

        Pass
        {
            Name "Forward"

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS = UnityObjectToClipPos(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color * _Color;

                return output;
            }

            fixed4 frag(Varyings input) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, input.uv);
                fixed4 finalColor = input.color;

                finalColor.a *= texColor.a;

                return finalColor;
            }

            ENDCG
        }
    }
}
