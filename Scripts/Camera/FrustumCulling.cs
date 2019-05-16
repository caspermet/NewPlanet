using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class FrustumCulling
{
    //Frustum culling
    public static bool Frustum(Camera camera, Vector3 position, float scale, Bounds bounds)
    {      
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
    //Rozšireni o orezávání ploch za horizontem

    public static bool horizont(Camera camera, Vector3 position)
    {
        // zjisteni normaly od pozorovatele k bodu
        Vector3 viewDirection = PlanetData.CameraPosition - position;
        float angle = 120;
        

        //při přiblížení pozorovatele k planetě lze zvolit meší úhel při, kterém se začne ořezávat hrana
        // Musí být minimálně 90 stupnu protože by jinak docházelo k ořezávání ploch, která pozorovatel vidí
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
