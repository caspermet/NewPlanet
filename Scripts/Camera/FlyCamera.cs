using UnityEngine;
using System.Collections;

/**************
 * Ovládání kamery
 * 
 * 
 * 
 * ********************/

public class FlyCamera
{

    private float cameraSensitivity = 60;
    private float normalMoveSpeed = 10;
    private float slowMoveFactor = 0.25f;
    private float fastMoveFactor = 3;

    private float minSpeed = 5;
    private float maxSpeed;

    private float rotationSpeed = 120.0f;


    private float planerRadius;

    private Camera camera;


    public FlyCamera(Camera camera, float planerRadius)
    {
        Cursor.visible = false;

        this.camera = camera;
        this.planerRadius = PlanetData.PlanetRadius;
        maxSpeed = planerRadius * 0.8f;
    }

    // úroveŇ rychlosti pozorovatele závisí na jeho vzdálenosti ku povrchu, kde se smenšující vzdáleností klesá i rychlost pohyby kamery
    private void SetSpeedByDistance()
    {
        float cameraDistanc = Vector3.Distance(camera.transform.position, new Vector3(0, 0, 0));
        planerRadius = PlanetData.PlanetRadius;
        cameraDistanc = cameraDistanc - PlanetData.PlanetRadius;
        maxSpeed = PlanetData.PlanetRadius * 0.5f;

        if (cameraDistanc > PlanetData.PlanetRadius)
        {
            normalMoveSpeed = maxSpeed;
        }
        else {
            normalMoveSpeed = (cameraDistanc / PlanetData.PlanetRadius) * maxSpeed;
            if (normalMoveSpeed < minSpeed)
            {
                normalMoveSpeed = minSpeed;
            }
        }
    }

    // Aby uživatel neskončil v planetě při zvětšování poloměru, tak při určité vzdálenosti se začne posunovat s tím jak se zvětšuje planeta
    private void SetCameraNewPosition()
    {

        if (planerRadius - PlanetData.PlanetRadius < 0 && PlanetData.ViewDistanceFromeEarth < PlanetData.PlanetRadius * 0.4f )
        {
         
            float height = PlanetData.PlanetRadius - planerRadius;
  
            camera.transform.position = (camera.transform.position + camera.transform.position.normalized * (height));
        }
        planerRadius = PlanetData.PlanetRadius;
    }

    public void MenuUpdate()
    {
        if (PlanetData.PlanetRadius != planerRadius)
        {
            SetCameraNewPosition();
        }
    }


    //Zde probíhá pohyb kamery
    public void Update()
    {

        SetSpeedByDistance();

        Vector2 mouse = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y"));
        mouse = Vector2.Scale(mouse, new Vector2(cameraSensitivity, cameraSensitivity));

        camera.transform.Rotate(-Vector3.right * mouse.y * Time.deltaTime);
        camera.transform.Rotate(Vector3.up * mouse.x * Time.deltaTime);

        if (Input.GetKey(KeyCode.Q))
            camera.transform.Rotate(Vector3.forward, rotationSpeed * Time.deltaTime);
        else if (Input.GetKey(KeyCode.E))
            camera.transform.Rotate(Vector3.forward, -rotationSpeed * Time.deltaTime);

        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {
            camera.transform.position += camera.transform.forward * (normalMoveSpeed * fastMoveFactor) * Input.GetAxis("Vertical") * Time.deltaTime;
            camera.transform.position += camera.transform.right * (normalMoveSpeed * fastMoveFactor) * Input.GetAxis("Horizontal") * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.RightControl))
        {
            camera.transform.position += camera.transform.forward * (normalMoveSpeed * slowMoveFactor) * Input.GetAxis("Vertical") * Time.deltaTime;
            camera.transform.position += camera.transform.right * (normalMoveSpeed * slowMoveFactor) * Input.GetAxis("Horizontal") * Time.deltaTime;
        }
        else
        {
            camera.transform.position += camera.transform.forward * normalMoveSpeed * Input.GetAxis("Vertical") * Time.deltaTime;
            camera.transform.position += camera.transform.right * normalMoveSpeed * Input.GetAxis("Horizontal") * Time.deltaTime;
        }



        if (Input.GetKeyDown(KeyCode.End))
        {
            Cursor.visible = (Cursor.visible == false) ? true : false;
        }
    }
}