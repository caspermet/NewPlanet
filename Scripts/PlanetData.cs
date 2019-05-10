using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PlanetData
{

    private static float planetRadius = 50 / 2;
    private static float planetDiameter = 50;
    private static float maxPlanetHeight = 1000;

    private static float minPlanetRadius = 1;
    private static float maxPlanetRadius = 127420;
    private static bool isLODActive = false;
    private static Vector3 spaceMove = new Vector3(0, 0, 0);

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

    public static Vector3 SpaceMove
    {
        get
        {
            return spaceMove;
        }
        set
        {
            spaceMove = value;
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
