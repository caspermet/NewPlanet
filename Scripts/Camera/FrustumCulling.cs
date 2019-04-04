using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class FrustumCulling 
{

    public static bool Frustum(Camera camera, Vector3 position, float scale, Vector3 normal)
    {
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
        for (int i = 0; i < planes.Length; i++)
        {  
            if (planes[i].GetDistanceToPoint(position) + scale < 0 && planes[i].GetDistanceToPoint(position) - scale < 0)
            {
                return false;
            }
        }
        return true;
    }
}
