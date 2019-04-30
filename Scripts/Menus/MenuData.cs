using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class MenuData
{
    private static int planetRadius;
    private static bool isPause;

    public static int PlanetRadius
    {
        get
        {
            return planetRadius;
        }
        set
        {
            planetRadius = value;
        }
    }
    public static bool IsPause
    {
        get
        {
            return isPause;
        }
        set
        {
            isPause = value;
        }
    }
}
