cbuffer vars : register(b0)
{
    float2 uResolution;
    float uTime;
    float2 uMouse;
    const uint euclidean = 0;
    const uint manhattan = 1;
    const uint chebychev = 2;
    const uint minkowski = 3;
};

float rand2dTo1d(float2 value, float2 dotDir = float2(12.9898, 78.233)){
    float2 smallValue = sin(value);
    float random = dot(smallValue, dotDir);
    random = frac(sin(random) * 143758.5453);
    return random;
}

float2 rand2dTo2d(float2 value){
    return float2(
        rand2dTo1d(value, float2(12.989, 78.233)),
        rand2dTo1d(value, float2(39.346, 11.135))
    );
}

float voronoiNoiseOld(float2 value){
    float2 cell = floor(value);
    float2 cellPosition = cell + rand2dTo2d(cell);
    float2 toCell = cellPosition - value;
    float distToCell = length(toCell);
    return distToCell;
}

float getDistanceToCellOld(float2 toCell, int minkowskiDistance) {
    switch(minkowskiDistance)
    {
        case 1:
            return abs(toCell.x) + abs(toCell.y);
        case 2:
            return length(toCell);
        default:
            return pow(pow(abs(toCell.x), minkowskiDistance) + pow(abs(toCell.y), minkowskiDistance), 1.f / minkowskiDistance);
    }
}

float getDistanceToCell(float2 toCell, float minkowskiOrder) {
    float x = pow(abs(toCell.x), minkowskiOrder);
    float y = pow(abs(toCell.y), minkowskiOrder);
    return pow(x + y, 1.f / minkowskiOrder);
}

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

float voronoiF1(float2 value, float cellSize, uint metric, float exponent = 0.f){
    float2 baseCell = floor(value);

    float minDistToCell = 10;
    [unroll]
    for(int x=-1; x<=1; x++){
        [unroll]
        for(int y=-1; y<=1; y++){
            float2 cell = baseCell + float2(x, y);
            float2 cellPosition = cell + rand2dTo2d(cell);
            float distToCell = voronoiDistance(cellPosition, value, metric, exponent);

            if(distToCell < minDistToCell){
                minDistToCell = distToCell;
            }
        }
    }
    float2 cellPosition = uMouse * uResolution / cellSize;
    float distToCell = voronoiDistance(cellPosition, value, metric, exponent);
    if(distToCell < minDistToCell){
        minDistToCell = distToCell;
    }
    return minDistToCell;
}

float voronoiF2(float2 value, float cellSize, float minkowskiOrder){
    float2 baseCell = floor(value);

    float minDistToCell = 10;
    float minDistToSecondCell = 20;
    [unroll]
    for(int x=-1; x<=1; x++){
        [unroll]
        for(int y=-1; y<=1; y++){
            float2 cell = baseCell + float2(x, y);
            float2 cellPosition = cell + rand2dTo2d(cell);
            float2 toCell = cellPosition - value;

            float distToCell = getDistanceToCell(toCell, minkowskiOrder);
            if(distToCell < minDistToCell){
                minDistToSecondCell = minDistToCell;
                minDistToCell = distToCell;
            }
            else if (distToCell < minDistToSecondCell) {
                minDistToSecondCell = distToCell;
            }
        }
    }
    float2 cellPosition = uMouse * uResolution / cellSize;
    float2 toCell = cellPosition - value;
    float distToCell = getDistanceToCell(toCell, minkowskiOrder);
    if(distToCell < minDistToCell){
        minDistToSecondCell = minDistToCell;
        minDistToCell = distToCell;
    }
    else if (distToCell < minDistToSecondCell) {
        minDistToSecondCell = distToCell;
       }
       return minDistToSecondCell;
}

float4 main(float4 fragCoord : SV_POSITION) : SV_TARGET
{
    float _CellSize = 100;
    float2 value = fragCoord.xy / _CellSize;
    //float minkowskiOrder = 2.f;
    uint metric = euclidean;
    float noise = voronoiF1(value, _CellSize, metric);
    return float4(noise, noise, noise, 1.f);
}