float voronoiDistance(float2 a, float2 b, uint metric, float exponent) {
    float2 dist = a - b;
    switch(metric) {
        case euclidean:
            // Euclidean
            return length(dist);
        case manhattan:
            // Manhattan
            return abs(dist.x) + abs(dist.y);
        case chebychev:
            // Chebychev
            return max(abs(dist.x), abs(dist.y));
        case minkowski:
            // Minkowski
            return pow(
                pow(abs(dist.x), exponent) + 
                pow(abs(dist.y), exponent), 
                1.f / exponent);
    }
}

float voronoiF1(float2 Position, float Scale, float RandomSeed, float Randomness, float DistanceMetric, float MinkowskiExponent) {
    float2 BaseCell = floor(Position);
    float F1Distance = 10.f;

    F1Position.xy = (float2)0.f;
    F1Color.xyz = (float3)0.f;

    [unroll]
    for(int x=-1; x<=1; x++){
        [unroll]
        for(int y=-1; y<=1; y++){
            float2 Cell = BaseCell + float2(x, y);
            float3 VectorNoise = MaterialExpressionVectorNoise(float3(Cell.x, Cell.y, RandomSeed), 1.f,0.f,0.f,300.f).xyz;
            float2 CellPosition = Cell + Randomness * VectorNoise.xy;

            float2 Difference = CellPosition - Position;
            float Distance = 0.f;

            if (DistanceMetric < 0.5f)
            {
                // Euclidean
                Distance = length(Difference);
            }
            else if (DistanceMetric < 1.5f)
            {
                // Manhattan
                Distance = abs(Difference.x) + abs(Difference.y);
            }
            else if (DistanceMetric < 2.5f)
            {
                // Chebychev
                Distance = max(abs(Difference.x), abs(Difference.y));
            }
            else
            {
                // Minkowski
                Distance = pow(
                    pow(abs(Difference.x), MinkowskiExponent) + 
                    pow(abs(Difference.y), MinkowskiExponent), 
                    1.f / MinkowskiExponent);
            }

            if(Distance < F1Distance){
                F1Distance = Distance;
                F1Position = CellPosition / Scale;
                F1Color = VectorNoise;
            }
        }
    }

    return F1Distance;
}

float voronoiF2(float2 Position, float Scale, float RandomSeed, float Randomness, float DistanceMetric, float MinkowskiExponent) { 
    float2 BaseCell = floor(Position);

    float F1Distance = 10.f;
    float2 F1Position = (float2)0.f;
    float3 F1Color = (float3)0.f;

    float F2Distance = 11.f;
    F2Position.xy = (float2)0.f;
    F2Color.xyz = (float3)0.f;

    [unroll]
    for(int x=-1; x<=1; x++){
        [unroll]
        for(int y=-1; y<=1; y++){
            float2 Cell = BaseCell + float2(x, y);
            float3 VectorNoise = MaterialExpressionVectorNoise(float3(Cell.x, Cell.y, RandomSeed), 1.f,0.f,0.f,300.f).xyz;
            float2 CellPosition = Cell + Randomness * VectorNoise.xy;

            float2 Difference = CellPosition - Position;
            float Distance = 0.f;

            if (DistanceMetric < 0.5f)
            {
                // Euclidean
                Distance = length(Difference);
            }
            else if (DistanceMetric < 1.5f)
            {
                // Manhattan
                Distance = abs(Difference.x) + abs(Difference.y);
            }
            else if (DistanceMetric < 2.5f)
            {
                // Chebychev
                Distance = max(abs(Difference.x), abs(Difference.y));
            }
            else
            {
                // Minkowski
                Distance = pow(
                    pow(abs(Difference.x), MinkowskiExponent) + 
                    pow(abs(Difference.y), MinkowskiExponent), 
                    1.f / MinkowskiExponent);
            }

            if(Distance < F1Distance){
                F2Distance = F1Distance;
                F2Position = F1Position;
                F2Color = F1Color;

                F1Distance = Distance;
                F1Position = CellPosition / Scale;
                F1Color = VectorNoise;
            }
            else if(Distance < F2Distance){
                F2Distance = Distance;
                F2Position = CellPosition / Scale;
                F2Color = VectorNoise;
            }
        }
    }

    return F2Distance;
}