using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class LoadArrayTexture {

  

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
}
