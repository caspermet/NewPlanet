using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;


/********************
 * Pro vytvoření 2D array pole které se posíla na grafickou kartu
 * 
 * 
 * 
 * ****************************/

public static class LoadArrayTexture
{
    public static Texture2DArray DoTexture(Texture2D[] ordinaryTextures)
    {

        Texture2DArray texture2DArray = new
            Texture2DArray(ordinaryTextures[0].width,
            ordinaryTextures[0].height, ordinaryTextures.Length,
            TextureFormat.RGBA32, true, false);

        texture2DArray.filterMode = FilterMode.Bilinear;
        texture2DArray.wrapMode = TextureWrapMode.Repeat;


        for (int i = 0; i < ordinaryTextures.Length; i++)
        {
            texture2DArray.SetPixels(ordinaryTextures[i].GetPixels(0),
                i, 0);
        }

        texture2DArray.Apply();


        return texture2DArray;
    }
}
