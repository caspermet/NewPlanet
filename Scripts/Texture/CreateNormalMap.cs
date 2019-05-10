using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;


public static class CreateNormalMap
{

    public static Texture2D CreateNormalMapFromHeightMap(Texture2D heightmap)
    {
        Texture2D normalMap = new Texture2D(heightmap.width, heightmap.height);
        int top;
        int left;
        int right;
        int bottom;
        float [] array = new float[4];

        for (int x = 0; x < heightmap.width; x++)
        {
            for (int y = 0; y < heightmap.height; y++)
            {
                top = y - 1;
                left = x - 1;
                right = x + 1;
                bottom = y + 1;

                if (x == 0)
                {
                    left = heightmap.width - 1;
                }
                else if (x == heightmap.width - 1)
                {
                    right = 0;
                }

                if (y == 0)
                {
                    top = heightmap.height - 1;

                }
                else if (y == heightmap.height - 1)
                {
                    bottom = 0;
                }

                array[0] = heightmap.GetPixel(x, top).r;
                array[1] = heightmap.GetPixel(x, bottom).r;
                array[2] = heightmap.GetPixel(left, y).r;
                array[3] = heightmap.GetPixel(right, y).r;


                Vector3 n = new Vector3();
                n.z = array[3] - array[0];
                n.x = array[2] - array[1];
                n.y = 2;
                n = Vector3.Normalize(n);
                Color color = new Color(n.x,n.y,n.z,1);
                normalMap.SetPixel(x, y, color);
            }
        }

        return normalMap;

    }

    public static Texture2D NormalMap(Texture2D source, float strength)
    {
        strength = 1;

        Texture2D normalTexture;
        float xLeft;
        float xRight;
        float yUp;
        float yDown;
        float yDelta;
        float xDelta;

        normalTexture = new Texture2D(source.width, source.height, TextureFormat.ARGB32, true);

        for (int y = 0; y < normalTexture.height; y++)
        {
            for (int x = 0; x < normalTexture.width; x++)
            {
                xLeft = source.GetPixel(x - 1, y).grayscale * strength;
                xRight = source.GetPixel(x + 1, y).grayscale * strength;
                yUp = source.GetPixel(x, y - 1).grayscale * strength;
                yDown = source.GetPixel(x, y + 1).grayscale * strength;
                xDelta = ((xLeft - xRight) + 1) * 0.5f;
                yDelta = ((yUp - yDown) + 1) * 0.5f;
                normalTexture.SetPixel(x, y, new Color(xDelta, yDelta, 1.0f, 1));
            }
        }
        normalTexture.Apply();

        //Code for exporting the image to assets folder
       // System.IO.File.WriteAllBytes("Assets//Map/NormalMap.png", normalTexture.EncodeToPNG());

        return normalTexture;
    }
}

