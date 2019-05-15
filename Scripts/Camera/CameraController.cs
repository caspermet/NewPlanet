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
       // camera.transform.position = new Vector3(0, 0, -(distance * 1.5f));
      //  camera.transform.position = new Vector3(-10044, 98016, 178611);
       // camera.transform.position = new Vector3(1424457, 1426233, 165498);
        camera.transform.position = new Vector3(3445624, 3445624, 2477373);
      //  camera.transform.Rotate(33, -95, -70);
       // camera.transform.Rotate(28.867f, -143.605f, -84.41801f);
        camera.transform.Rotate(29.264f, -136.375f, -12.177f);
        //camera.transform.position = new Vector3(0, 0, -(distance * 1f));
    }

    public void cameraUpdate()
    {

        if (MenuData.IsPause == true)
        {
            flyCamera.MenuUpdate();
            EditFarPlane();
            return;
        }
     
        if (Input.GetKeyDown(KeyCode.T))
        {
            PlanetData.IsLODActive = !PlanetData.IsLODActive;
        }


        if (Input.GetKeyDown(KeyCode.K))
        {
            GUI.enabled = false;
      
            PlanetData.IsMenu = !PlanetData.IsMenu;
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

    public void setDistance(float distance)
    {
        this.distance = distance;
    }
}