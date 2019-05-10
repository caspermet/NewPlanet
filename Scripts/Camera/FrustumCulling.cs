using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class FrustumCulling 
{

    public static bool Frustum(Camera camera, Vector3 position, float scale)
    {
      /*  if(Vector3.Distance(camera.transform.position, new Vector3(0,0,0)) < Vector3.Distance(camera.transform.position, position))
        {
            return false;
        }*/


        float maxHeight = PlanetData.MaxPlanetHeight;   
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
        for (int i = 0; i < planes.Length; i++)
        {  
            if (planes[i].GetDistanceToPoint(position) + 3 * scale + maxHeight < 0 && planes[i].GetDistanceToPoint(position) - 3 * scale - maxHeight < 0)
            {
                return false;
            }
        }
        return true;
    }
}
