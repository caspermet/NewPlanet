using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//testovací třída
public class CreatePlane : MonoBehaviour {
    public Material material;
	
	void Start () {
        for (int x = 0; x < 180; x++)
        {
            for (int y = 0; y < 180; y++)
            {
                CreatePlanes(x * 10, y * 10);
            }
        }
	}

    void CreatePlanes(int x, int z)
    {
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Plane);
        sphere.GetComponent<Renderer>().material = material;
        sphere.transform.position += new Vector3(x, 0, z);
    }

}
