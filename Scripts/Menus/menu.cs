using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class menu : MonoBehaviour
{
    public GameObject mainMenuHolder;
    public GameObject optionsMenuHolder;

    public Slider radiusSlider;

  /*  void Update()
    {
        if (Input.GetKey(KeyCode.Escape))
        {
            Scene currentScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
            if (currentScene.name == "menu")
            {       
                UnityEngine.SceneManagement.SceneManager.LoadScene("Scenesnew");
            }
            else
            {
                UnityEngine.SceneManagement.SceneManager.LoadScene("menu");
            }
        }
    }*/

    public void Play()
    {
        MenuData.PlanetRadius = 40;
        UnityEngine.SceneManagement.SceneManager.LoadScene("Scenesnew");
    }

    public void Quic()
    {
        Application.Quit();
    }

    public void SetRadiusOfPlanet(float value)
    {

    }


}
