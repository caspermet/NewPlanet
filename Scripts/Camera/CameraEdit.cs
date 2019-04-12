using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;


public class CameraEdit
{

    private Camera camera;
    private float distance;

    private FlyCamera flyCamera;

    public CameraEdit(Camera camera, float distance)
    {
        this.camera = camera;
        this.distance = distance;
        flyCamera = new FlyCamera(camera, distance);
        SetDefaultCameraPosition();
        EditFarPlane();     
    }

    public void SetDefaultCameraPosition()
    {
        camera.transform.position = new Vector3(0, 0, -(distance * 4f));
    }

    public void cameraUpdate()
    {
        flyCamera.Update();
        EditFarPlane();
    }

    private void EditFarPlane()
    {
        float farPlanedistance = Vector3.Distance(camera.transform.position, new Vector3(0, 0, 0));
        camera.farClipPlane = farPlanedistance;
        if(distance < 100)
        {
            camera.nearClipPlane = 0.1f;
        }
        else
        {
            camera.nearClipPlane = 30;
        }

    }
}