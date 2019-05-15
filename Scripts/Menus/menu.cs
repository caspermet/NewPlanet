using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

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

        chunkSizeText.text = "Detailnost Dlaždice = 16";
    }

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

    public void Quic()
    {
        Application.Quit();
    }

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

    public void SetChunkSize(float valuee)
    {

        chunkSizeText.text = "Detailnost Dlaždice = " + (int)valuee;
        chunkSize = (int)valuee;
    }

    public void SetTessellation(bool valuee)
    {
       
        tessellation = valuee;
        Debug.Log(tessellation);
    }
}
