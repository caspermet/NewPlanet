using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;


public class CameraController
{

    private Camera camera;
    private float distance;

    private FlyCamera flyCamera;

    public CameraController(Camera camera, float distance)
    {
        this.camera = camera;
        this.distance = distance;
        flyCamera = new FlyCamera(camera, distance);
        SetDefaultCameraPosition();
        EditFarPlane();     
    }

    public void SetDefaultCameraPosition()
    {
        camera.transform.position = new Vector3(0, 0, -(distance * 3f));
    }

    public void cameraUpdate()
    {
        if(MenuData.IsPause == true)
        {
            return;
        }


        Cursor.visible = false;
        flyCamera.Update();
        EditFarPlane();
    }

    private void EditFarPlane()
    {
        float farPlanedistance = Vector3.Distance(camera.transform.position, new Vector3(0, 0, 0));
        camera.farClipPlane = farPlanedistance;
        if(farPlanedistance - distance < 1000)
        {
            camera.nearClipPlane = 0.1f;
        }
        else
        {
            camera.nearClipPlane = 30;
        }
    }
}