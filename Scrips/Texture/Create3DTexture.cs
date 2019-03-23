using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Create3DTexture {

/*
    public static Texture3D Create3DTextureFrom2DTexture(Texture2D texture2D, int diameter)
    {
        Color[] colorArray = new Color[diameter * diameter * diameter];
        Texture3D texture3D = new Texture3D(diameter, diameter, diameter, TextureFormat.RGBA32, true);
        float radius = diameter / 2;

        for (int x = 0; x < diameter; x++)
        {
            for (int y = 0; y < diameter; y++)
            {
                Color c = texture2D.GetPixel(x, y);
                Vector3 position = sphere(radius, x, y);
              //  colorArray[position.x * position.y * position.z] = c;
            }
        }

        return texture3D;

    }

    private static Vector3 sphere(float radius, float x, float z)
    {

        float r = radius;
        float step = Mathf.PI / r *  x;
        float stepZ = 2 * Mathf.PI / r * z;
        //	step = wolrldPosition.x * step;
        //	stepZ = wolrldPosition.z * stepZ;
        float xx = r * Mathf.Sin(step) * Mathf.Cos(stepZ);
        float zz = r * Mathf.Sin(step) * Mathf.Sin(stepZ);
        float yy = r * Mathf.Cos(step);

        return new Vector3(xx, yy, zz);
    }*/
	
}
