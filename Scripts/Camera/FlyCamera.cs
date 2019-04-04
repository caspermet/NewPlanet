using UnityEngine;
using System.Collections;

public class FlyCamera
{

    private float cameraSensitivity = 60;
    private float climbSpeed = 4;
    private float normalMoveSpeed = 10;
    private float slowMoveFactor = 0.25f;
    private float fastMoveFactor = 3;

    private float minSpeed = 5;
    private float maxSpeed ;


    private float planerRadius;

    private Camera camera;
    private float rotationX = 0.0f;
    private float rotationY = 0.0f;

    public FlyCamera(Camera camera, float planerRadius)
    {
        Screen.lockCursor = true;
        this.camera = camera;
        this.planerRadius = planerRadius;
        maxSpeed = planerRadius * 0.5f;
    }

    private void SetSpeedByDistance()
    {
        float cameraDistanc = Vector3.Distance(camera.transform.position, new Vector3(0, 0, 0));
       
        cameraDistanc = cameraDistanc - planerRadius;
        if (cameraDistanc > planerRadius)
        {
            normalMoveSpeed = maxSpeed;
        }
        else {
            normalMoveSpeed = (cameraDistanc / planerRadius) * maxSpeed;
            if (normalMoveSpeed < minSpeed)
            {
                normalMoveSpeed = minSpeed;
            }
        }
    }

    public void Update()
    {
        SetSpeedByDistance();
        rotationX += Input.GetAxis("Mouse X") * cameraSensitivity * Time.deltaTime;
        rotationY += Input.GetAxis("Mouse Y") * cameraSensitivity * Time.deltaTime;
        //rotationY = Mathf.Clamp(rotationY, -180, 180);

        camera.transform.localRotation = Quaternion.AngleAxis(rotationX, Vector3.up);
        camera.transform.localRotation *= Quaternion.AngleAxis(rotationY, Vector3.left);

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


        if (Input.GetKey(KeyCode.Q)) { camera.transform.position += camera.transform.up * climbSpeed * Time.deltaTime; }
        if (Input.GetKey(KeyCode.E)) { camera.transform.position -= camera.transform.up * climbSpeed * Time.deltaTime; }

        if (Input.GetKeyDown(KeyCode.End))
        {
            Screen.lockCursor = (Screen.lockCursor == false) ? true : false;
        }
    }
}