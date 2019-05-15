using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class CalculateRotation
{

	public static int CalculateRotateOfMesh(Vector4 edge, int suma)
    {
        int rotate = 0;
        switch (suma)
        {
            case 0:
               
                break;
            case 1:
                if (edge.x == 1)
                {
                    rotate = 0;
                }
                else if (edge.y == 1)
                {
                    rotate = 90;

                }
                else if (edge.z == 1)
                {
                    rotate = 180;
                }
                else
                {
                    rotate = 270;
                }
                break;
            case 2:
                if (edge.x == 1 && edge.y == 1)
                {
                    rotate = 0;
                }
                else if (edge.y == 1 && edge.z == 1)
                {
                    rotate = 90;

                }
                else if (edge.z == 1 && edge.w == 1)
                {
                    rotate = 180;
                }
                else
                {
                    rotate = 270;
                }
                break;
            case 3:
                if (edge.w == 0)
                {
                    rotate = 0;
                }
                else if (edge.x == 0)
                {
                    rotate = 90;

                }
                else if (edge.y == 0)
                {
                    rotate = 180;
                }
                else
                {
                    rotate = 270;
                }
                break;
            default:
                break;
        }

        return rotate;
    }
}
