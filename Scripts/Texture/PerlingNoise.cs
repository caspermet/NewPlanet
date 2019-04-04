using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PerlingNoise  {


    public static Texture2D CreateNoise(int size, float scale)
    {
        Texture2D texture = new Texture2D(size,size);

        for (int x = 0; x < size; x++)
        {
            for (int y = 0; y < size; y++)
            {
                Color color = GenerateColor(x, y, (float)size, scale);
                texture.SetPixel(x, y, color);
            }
        }
        texture.Apply();
        return texture;
    }

    private static Color GenerateColor(int x, int y, float size, float scale)
    {
        float xCoord = (float)x / size * scale;
        float yCoord = (float)y / size * scale;

        float sample = Mathf.PerlinNoise(xCoord, yCoord);
        return new Color(sample, sample, sample);
    }
}
