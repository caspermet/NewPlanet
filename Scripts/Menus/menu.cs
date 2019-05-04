using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class menu : MonoBehaviour
{
    public GameObject mainMenuHolder;
    public GameObject optionsMenuHolder;

    public float value;

    public void Play()
    {
        MenuData.PlanetRadius = value;
        UnityEngine.SceneManagement.SceneManager.LoadScene("Scenesnew");
    }

    public void Quic()
    {
        Application.Quit();
    }

    public void SetRadiusOfPlanet(float valuee)
    {
        Debug.Log(valuee);
      // this.value = valuee;
    }


}
