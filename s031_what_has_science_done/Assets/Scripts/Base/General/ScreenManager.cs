using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;

public class ScreenManager : SingletonMonoBehaviour<ScreenManager>
{
    private float aspectRatio;
    private int screenWidth;
    private int screenHeight;

    public Camera MainCamera { get; private set; }
    public Rect Rect { get; private set; }

    public event Action EventAspectRatioChanged;
    public event Action EventScreenSizeChanged;

    private void Awake()
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            Screen.fullScreen = true;
        }

        screenWidth = Screen.width;
        screenHeight = Screen.height;

        MainCamera = Camera.main;
        Refresh();
    }

    private void Update()
    {
        if (aspectRatio != MainCamera.aspect)
        {
            Refresh();

            if (EventAspectRatioChanged != null)
                EventAspectRatioChanged();
        }

        if ((screenWidth != Screen.width) || (screenHeight != Screen.height))
        {
            screenWidth = Screen.width;
            screenHeight = Screen.height;

            if (EventScreenSizeChanged != null)
                EventScreenSizeChanged();
        }
    }

    private void Refresh()
    {
        aspectRatio = MainCamera.aspect;

        var lowerLeft = MainCamera.ScreenToWorldPoint(Vector3.zero);
        Rect = new Rect(lowerLeft.x, lowerLeft.y, -lowerLeft.x * 2, -lowerLeft.y * 2);
    }
}
