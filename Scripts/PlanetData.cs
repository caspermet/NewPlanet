using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PlanetData {

    public static float planetRadius;
    public static float maxPlanetHeight;
    public static bool isLODActive = false;

    public static float PlanetRadius
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

    public static float MaxPlanetHeight
    {
        get
        {
            return maxPlanetHeight;
        }
        set
        {
            maxPlanetHeight = value;
        }
    }
    public static bool IsLODActive
    {
        get
        {
            return isLODActive;
        }
        set
        {
            isLODActive = value;
        }
    }
}
