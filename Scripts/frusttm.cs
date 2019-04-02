using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class frusttm : MonoBehaviour
{
    public Camera camera;
    public GameObject some;
    public Transform viewer;

    // Update is called once per frame
    void Update()
    {
        Debug.Log(someee());
    }


    public bool someee()
    {
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
        for (int i = 0; i < planes.Length; i++)
        {
            if (planes[i].GetDistanceToPoint(viewer.position) < 0)
            {
                return false;
            }
        }

        return true;
    }
}
