using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class FrustumCulling
{

    public static bool Frustum(Camera camera, Vector3 position, float scale, Bounds bounds)
    {
        /*  if(Vector3.Distance(camera.transform.position, new Vector3(0,0,0)) < Vector3.Distance(camera.transform.position, position))
          {
              return false;
          }*/
          
       

        float maxHeight = PlanetData.MaxPlanetHeight;
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
        for (int i = 0; i < planes.Length; i++)
        {
            if (planes[i].GetDistanceToPoint(position) + scale + maxHeight < 0 && planes[i].GetDistanceToPoint(position) - scale - maxHeight < 0)
            {
                return false;
            }
        }
        return true;
    }

    public static bool horizont(Camera camera, Vector3 position)
    {

        Vector3 viewDirection = PlanetData.CameraPosition - position;
        float angle = 120;
        
        if(PlanetData.ViewDistanceFromeEarth < PlanetData.PlanetRadius * 0.2f)
        {
            angle = 95;
        }

        if (Vector3.Angle(position.normalized, viewDirection) > angle)
        {
            return false;
        }

        return true;
    }
}
