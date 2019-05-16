using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using UnityEngine.UI;


/****************************
 * Metody na ovládání prvotniho menu
 * 
 * 
 * 
 * **************************************/

public class menu : MonoBehaviour
{
    public GameObject mainMenuHolder;
    public GameObject optionsMenuHolder;
    public Slider slider;
    public Slider sliderheight;
    public Text text;
    public Text heightText;
    public Text chunkSizeText;

    public Dropdown dropdown;


    public float value;
    public float maxPlanetheight;
    public float chunkSize;
    public bool tessellation;

    public void Start()
    {
        text.text = "Průměr planety = " + PlanetData.PlanetDiameter;
        slider.minValue = PlanetData.MinPlanetRadius;
        slider.maxValue = PlanetData.MaxPlanetRadius;
        slider.value = PlanetData.PlanetDiameter;

        heightText.text = "Maximální výška hor = " + PlanetData.PlanetDiameter * 0.001f;
        slider.minValue = PlanetData.MinPlanetRadius;
        slider.maxValue = PlanetData.MaxPlanetRadius;
        slider.value = PlanetData.PlanetDiameter;
        chunkSize = 16;
        chunkSizeText.text = "Detailnost Dlaždice = 16";
    }

    //uloží všechno data, který získal od uživatele a hlavní scénu
    public void Play()
    {
        MenuData.PlanetRadius = value;
        PlanetData.PlanetDiameter = value;
        PlanetData.PlanetRadius = value / 2;
        PlanetData.MaxPlanetHeight = maxPlanetheight;
        PlanetData.ChunkSize = chunkSize;
        PlanetData.IsTessellation = tessellation;

        UnityEngine.SceneManagement.SceneManager.LoadScene("Scenesnew");
      
    }

    //Ukončí aplikaci
    public void Quic()
    {
        Application.Quit();
    }


    //nastavi průmer planety
    public void SetRadiusOfPlanet(float valuee)
    {

        text.text = "Průměr planety = " + valuee;
        sliderheight.maxValue = valuee * 0.01f;
        sliderheight.minValue = valuee * 0.001f;

        this.value = valuee;
    }

    public void SetMaxPlanetRadius(float valuee)
    {

        heightText.text = "Maximální výška hor = " + valuee;
        maxPlanetheight = valuee;
    }

    //nastaví hodnotu chunku
    public void SetChunkSize(float valuee)
    {

        chunkSizeText.text = "Detailnost Dlaždice = " + (int)valuee;
        chunkSize = (int)valuee;
    }


    //Jestli má probíhat tesselace pro částečné odstranění popping efektu
    public void SetTessellation(bool valuee)
    {
       
        tessellation = valuee;
        Debug.Log(tessellation);
    }
}
