using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;

/*********
 * Třída která ovládá třídu FlyXAmera
 * 
 * 
 * 
 * *********/
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
        camera.transform.position = new Vector3(0, 0, -(distance * 1.5f));
    }

    public void cameraUpdate()
    {
        // Když je pauza a uživatel si může upravovat vlastnosti planety
        if (MenuData.IsPause == true)
        {
            flyCamera.MenuUpdate();
            EditFarPlane();
            return;
        }

        // prepina mezi mody zobrazeni
        if (Input.GetKeyDown(KeyCode.T))
        {
            PlanetData.IsLODActive = !PlanetData.IsLODActive;
        }


        Cursor.visible = false;
        flyCamera.Update();
        EditFarPlane();
    }


    // S pohybem kamery je vzdálená plocha upravována, tak aby bykla vžd´, tak daljeko jak je hráč od středu planety -- ořezávání zadních ploch
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