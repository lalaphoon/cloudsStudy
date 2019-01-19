// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Centre ("Center", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Radius ("Radius", Float) = 100.0
        
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            //reference: https://www.alanzucconi.com/2016/07/01/raymarching/
            
			struct appdata
			{
				float4 vertex : POSITION; //pos
				float3 uv : TEXCOORD1; //wPos
			};

			struct v2f
			{
				float3 uv : TEXCOORD1;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float4 _Centre;
            float _Radius;
            
            bool sphereHit(float3 p) {
                return distance(p, _Centre) < _Radius;
            }
            
            float sphereDistance (float3 p){
                return distance(p, _Centre) - _Radius;
            }
            

            fixed4 raymarch(float3 position, float3 direction) {
                for (int i = 0; i < 100; i++) {
                    if (sphereHit(position)) {
                       return fixed4(1,0,0,1); //Red
                    }
                    position += direction * 0.2;
                }
                return fixed4(1,1,1,1); // White
              
            // for (int i = 0 ; i < 100; i++) {
            //   float distance = sphereDistance(position);
             //  if (distance < 0.0001) {
             //       return i/(float)50;
              //  }
              //  position += distance * direction;
             // }
             // return 0;
                
            }
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = mul(unity_ObjectToWorld, v.vertex).xyz;
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
                float3 worldPosition = i.uv;
                float3 viewDirection = normalize(i.uv - _WorldSpaceCameraPos);

                return raymarch(worldPosition, viewDirection);
			}
			ENDCG
		}
	}
}
