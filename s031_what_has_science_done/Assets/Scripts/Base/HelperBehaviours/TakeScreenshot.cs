using System.IO;
using System.Linq;
using UnityEngine;

// Based on http://answers.unity3d.com/questions/22954/how-to-save-a-picture-take-screenshot-from-a-camer.html
public class TakeScreenshot : MonoBehaviour
{
    [SerializeField] private bool useCurrentResolution = true;
    [SerializeField] private int resolutionWidth = 2550;
    [SerializeField] private int resolutionHeight = 3300;
    [SerializeField] private string folder = "screenshots";
    [SerializeField] private KeyCode[] keys = new[] { KeyCode.F9 };

    private bool takeHiResShot = false;

    public static string ScreenShotName(int width, int height, string folder)
    {
        var directory = Path.Combine(Application.dataPath, folder);
        if (!Directory.Exists(directory))
            Directory.CreateDirectory(directory);

        return Path.Combine(directory,
                            string.Format("screen_{0}x{1}_{2}.png",
                                          width, height,
                                          System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss")));
    }

    public void TakeHiResShot()
    {
        takeHiResShot = true;
    }

    private void LateUpdate()
    {
#if !UNITY_WEBPLAYER
        takeHiResShot |= keys.All(Input.GetKeyDown);
        if (takeHiResShot)
        {
            if (useCurrentResolution)
            {
                resolutionWidth = Screen.width;
                resolutionHeight = Screen.height;
            }

            takeHiResShot = false;
            var renderTexture = new RenderTexture(resolutionWidth, resolutionHeight, 24);
            GetComponent<Camera>().targetTexture = renderTexture;
            var screenShotTexture = new Texture2D(resolutionWidth, resolutionHeight, TextureFormat.RGB24, false);
            GetComponent<Camera>().Render();
            RenderTexture.active = renderTexture;
            screenShotTexture.ReadPixels(new Rect(0, 0, resolutionWidth, resolutionHeight), 0, 0);
            GetComponent<Camera>().targetTexture = null;
            RenderTexture.active = null; // JC: added to avoid errors
            Destroy(renderTexture);
            byte[] bytes = screenShotTexture.EncodeToPNG();
            string filename = ScreenShotName(resolutionWidth, resolutionHeight, folder);
            System.IO.File.WriteAllBytes(filename, bytes);
            Debug.Log(string.Format("Took screenshot to: {0}", filename));
        }
#endif
    }
}