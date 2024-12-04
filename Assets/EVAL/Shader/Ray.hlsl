void Raycast_float (float3 Rayorigin, float3 RayDir, float3 SphereOrigin, float SphereSize,
            out float Hit, out float3 HitPosition, out float3 HitNormal)
            {
                HitPosition = float3(0.0,0.0,0.0);
                HitNormal = float3(0.0,0.0,0.0);

                float t = 0.0f;
                float3 L = SphereOrigin - Rayorigin;
                float tca = dot(L, -RayDir);

                if(tca < 0)
                {
                    Hit = 0.0f;
                    return;
                }
                float d2 = dot(L,L) - tca * tca;
                float radius2 = SphereSize * SphereSize;

                if(d2 > radius2)
                {
                    Hit =0.0f;
                    return;
                }
                float thc = sqrt(radius2 - d2);
                t = tca - thc;

                Hit = 1.0f;
                HitPosition = Rayorigin - RayDir * t;
                HitNormal = normalize(HitPosition - SphereOrigin);
            }