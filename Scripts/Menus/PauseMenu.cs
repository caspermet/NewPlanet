using System.Collections;
using System.Collections.Generic;
using UnityEngine;



// Trida na pouze menu
public class PauseMenu : MonoBehaviour {
    [SerializeField] private GameObject pauseMenuUI;

    [SerializeField] private bool isPaused;

	void Update () {
		if (Input.GetKeyDown(KeyCode.Escape) || Input.GetKeyDown(KeyCode.P))
        {
            isPaused = !isPaused;
        }

        if (isPaused)
        {
            ActiveMenu();
            Cursor.visible = false;
        }
        else
        {
            DeactivateMenu();         
        }
	}

    public void ActiveMenu()
    {
        MenuData.IsPause = true;
       // pauseMenuUI.SetActive(true);
    }

    public void DeactivateMenu()
    {
        MenuData.IsPause = false;
       // pauseMenuUI.SetActive(false);
    }

    public void Resume()
    {
        isPaused = !isPaused;
        DeactivateMenu();
    }
}
