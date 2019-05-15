

double3 RotateNormal(double3 vector1, double3 vector2, double3 vector3) {
	double3 n = cross(vector1, vector2);

	double vm1 = sqrt(n.x*n.x + n.y*n.y + n.z*n.z);

	n = normalize(n / (vm1));

	double angle = acos(dot(vector1, vector2));

	double s = sin(angle);
	double c = cos(angle);

	double3x3 matrixx = (
		n.x * n.x * (1 - c) + c       , n.y * n.x * (1 - c) - s * n.z, n.x * n.z * (1 - c) + s * n.y,
		n.x * n.y * (1 - c) + s * n.z , n.y * n.y * (1 - c) + c      , n.y * n.z * (1 - c) - s * n.x,
		n.x * n.z * (1 - c) - s * n.y , n.y * n.z * (1 - c) + s * n.x, n.z * n.z * (1 - c) + c);

	return mul(matrixx, normalize(vector3));
}


double3x3 RotateAroundYInDegrees(double degrees)
{
	double alpha = degrees * UNITY_PI / 180.0;
	double sina, cosa;
	sincos(alpha, sina, cosa);


	return double3x3(
		cosa, 0, -sina,
		0, 1, 0,
		sina, 0, cosa);
}

VS_OUTPUT VS(APP_OUTPUT v, uint instanceID : SV_InstanceID)
{
	VS_OUTPUT o;
	/// Buffery posílány s instancingem 
	double4 data = positionBuffer[instanceID];
	double4 transform = directionsBuffer[instanceID];

	double3 pos = v.vertex.xyz;


	/*********
	Rotace vertexù podle pro spojení jednotlivích dlaždic a následné vytvoøení krychle
	************/

	if (transform.z != 0 && transform.y != 0) {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w   + transform.z * 90), v.vertex.xyz);

		pos = v.vertex.xyz;
		v.vertex.y = mul(transform.z * -1, pos.x);
		v.vertex.x = 0;
	}
	else if (transform.x != 0 && transform.y != 0) {

		if (transform.x == 1) {
			v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w), v.vertex.xyz);
		}
		else {
			v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w + 180), v.vertex.xyz);
		}
	
		pos = v.vertex.xyz;
		v.vertex.y = mul(transform.x, pos.z);
		v.vertex.z = 0;
	}
	else if (transform.x == -1 && transform.z != 0) {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w ), v.vertex.xyz);
		pos = v.vertex.xyz;
		v.vertex.x = -pos.x;
	}
	else {
		v.vertex.xyz = mul(RotateAroundYInDegrees(-transform.w ), v.vertex.xyz);
	}
	
	// Pøevod krychle na kouli
	double3 localPosition = v.vertex.xyz * data.w;
	double3 worldPosition = data.xyz + localPosition;	

	double x = worldPosition.x / _PlanetInfo.x;;
	double y = worldPosition.y / _PlanetInfo.x;;
	double z = worldPosition.z / _PlanetInfo.x;;
	
	double dx = x * sqrt(1.0f - (y*y * 0.5f) - (z * z * 0.5f) + (y*y*z*z / 3.0f));
	double dy = y * sqrt(1.0f - (z*z * 0.5f) - (x * x * 0.5f) + (z*z*x*x / 3.0f));
	double dz = z * sqrt(1.0f - (x*x * 0.5f) - (y * y * 0.5f) + (x*x*y*y / 3.0f));


	//výsledek je pozice na jednotkové kouli -: normála
	o.normal = double3(dx, dy, dz);
	o.normal2 = double3(dx, dy, dz);

	worldPosition.xyz = double3(dx, dy, dz) * _PlanetInfo.x;

	//Výpoèet UV souøadnic
	double3 n = normalize(double3(worldPosition.x, worldPosition.y, worldPosition.z));
	o.normal = n;
	double uCoor = atan2(n.z, n.x) / (2 * PI) + 0.5f;
	double vCoor = asin(n.y) / PI + 0.5f; 

	// Výpoèet výšky vertexu z výškové mapy
	double height = tex2Dlod(_PlanetHeightMap, double4(double2(uCoor, vCoor), 0.0, 0));

	// Pøidání výšky  k pozici vertexu
	worldPosition.xyz = (worldPosition + n * (height * _PlanetInfo.y));


	
	o.wordPosition = double4(worldPosition, 1.0f);
	o.vertex = double4(worldPosition, 1.0f);
	o.uv = double2(uCoor, vCoor);
	o.height = data.w;
	
	return o;

}