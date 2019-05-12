using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PlanetData
{

    private static float planetRadius = 7463 / 2;
    private static float planetDiameter = 7463 ;
    private static float maxPlanetHeight = 1;

    private static float minPlanetRadius = 100;
    private static float maxPlanetRadius = 65536*4;
    private static bool isLODActive = false;
    private static Vector3 cameraPosition;
    private static int angle;

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

    public static Vector3 CameraPosition
    {
        get
        {
            return cameraPosition;
        }
        set
        {
            cameraPosition = value;
        }
    }

    public static int Angle
    {
        get
        {
            return angle;
        }
        set
        {
            angle = value;
        }
    }

    public static float PlanetDiameter
    {
        get
        {
            return planetDiameter;
        }
        set
        {
            planetDiameter = value;
            planetRadius = value / 2;
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
    public static float MinPlanetRadius
    {
        get
        {
            return minPlanetRadius;
        }
    }
    public static float MaxPlanetRadius
    {
        get
        {
            return maxPlanetRadius;
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
