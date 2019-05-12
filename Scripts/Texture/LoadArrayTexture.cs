using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public static class LoadArrayTexture
{
    public static Texture2DArray DoTexture(Texture2D[] ordinaryTextures)
    {
        // Create Texture2DArray
        Texture2DArray texture2DArray = new
            Texture2DArray(ordinaryTextures[0].width,
            ordinaryTextures[0].height, ordinaryTextures.Length,
            TextureFormat.RGBA32, true, false);
        // Apply settings
        texture2DArray.filterMode = FilterMode.Bilinear;
        texture2DArray.wrapMode = TextureWrapMode.Repeat;
        // Loop through ordinary textures and copy pixels to the
        // Texture2DArray

        for (int i = 0; i < ordinaryTextures.Length; i++)
        {
            texture2DArray.SetPixels(ordinaryTextures[i].GetPixels(0),
                i, 0);
        }
        // Apply our changes
        texture2DArray.Apply();


        return texture2DArray;
    }

    public static Texture2D FillInClear(Texture2D tex2D, int i)
    {
          int width = tex2D.width;
          for (int x = 1; x < width - 1; x++)
          {

              tex2D.SetPixel(x, 0, tex2D.GetPixel(x, 1));
              tex2D.SetPixel(x, width - 1, tex2D.GetPixel(x, width - 2));
              tex2D.SetPixel(0, x, tex2D.GetPixel(1, x));
              tex2D.SetPixel(width - 1, x, tex2D.GetPixel(width - 2, x));
          }

          tex2D.SetPixel(0, 0, tex2D.GetPixel(1, 1));
          tex2D.SetPixel(0, width - 1, tex2D.GetPixel(1, width - 2));
          tex2D.SetPixel(width - 1, 0, tex2D.GetPixel(width - 2, 1));
          tex2D.SetPixel(width - 1, width - 1, tex2D.GetPixel(width - 2, width - 2));

          return tex2D;
          
    }


}
