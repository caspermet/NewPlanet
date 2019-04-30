using UnityEngine;
using System.Collections;

public class SunRotate : MonoBehaviour
{

    public float sunRotateSpeed = 10.0f;
    public Transform sun;

    void Update()
    {

        if (Input.GetKey(KeyCode.R))
            sun.Rotate(new Vector3(0, sunRotateSpeed * Time.deltaTime, 0));
        else if (Input.GetKey(KeyCode.F))
            sun.Rotate(new Vector3(0, -sunRotateSpeed * Time.deltaTime, 0));
    }
}
