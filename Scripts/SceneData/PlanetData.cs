using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PlanetData
{

    private static float planetRadius = 1000000 / 2;
    private static float planetDiameter = 1000000;

    private static float maxPlanetHeight = 1000000 * 0.01f;

    private static float minPlanetRadius = 10000;
    private static float maxPlanetRadius = 1000000;

    private static float chunkSize = 16;


    private static bool isLODActive = false;
    private static Vector3 cameraPosition;
    private static int angle;
    private static bool isTessellation = true;
    private static bool isMenu;
    private static float viewDistanceFromeEarth;

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
     public static float ViewDistanceFromeEarth
    {
        get
        {
            return viewDistanceFromeEarth;
        }
        set
        {
            viewDistanceFromeEarth = value;
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

    public static float ChunkSize
    {
        get
        {
            return chunkSize;
        }
        set
        {
            chunkSize = value;
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
    public static bool IsTessellation
    {
        get
        {
            return isTessellation;
        }
        set
        {
            isTessellation = value;
        }
    }

    public static bool IsMenu
    {
        get
        {
            return isMenu;
        }
        set
        {
            isMenu = value;
        }
    }
}
