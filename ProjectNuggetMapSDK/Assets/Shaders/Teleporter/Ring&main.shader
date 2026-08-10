Shader "Shader Forge/Ring&main"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "Forward"

            Cull Back
            ZWrite On
            ZTest LEqual

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float4 positionWS = mul(unity_ObjectToWorld, IN.positionOS);
                OUT.positionCS = mul(UNITY_MATRIX_VP, positionWS);
                OUT.color = IN.color;

                return OUT;
            }

            fixed4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                float3 baseColor = UNITY_ACCESS_INSTANCED_PROP(Props, _Color).rgb;
                float t = IN.color.r * 0.3 + 0.1;
                float3 col = lerp(baseColor, float3(1.0, 1.0, 1.0), t);

                return fixed4(col, 1.0);
            }

            ENDCG
        }
    }
}
