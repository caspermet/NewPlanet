using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Windows;


class test
{


    public Camera _cameraWithRendTexture;
    public TextMesh _percentMesh;
    public TextMesh _nameMesh;
    public int _heightInPixelsOfCertificate = 1488;

    public void SaveCertificate(Texture2D tex2D, int i)
    {

        //byte[] bytes = tex2D.EncodeToPNG();
      //  File.WriteAllBytes( "test" + i + ".png", bytes);


    }

    public Texture2D FillInClear(Texture2D tex2D, Color whatToFillWith)
    {

        for (int i = 0; i < tex2D.width; i++)
        {
            for (int j = 0; j < tex2D.height; j++)
            {
                if (tex2D.GetPixel(i, j) == Color.clear)
                    tex2D.SetPixel(i, j, whatToFillWith);
            }
        }
        return tex2D;
    }
}