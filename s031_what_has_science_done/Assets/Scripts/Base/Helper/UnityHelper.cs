using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;
using UnityEngine;
using Object = UnityEngine.Object;

public static class UnityHelper
{
    public static Vector2 AnchorUpperLeft = new Vector2(0, 0);
    public static Vector2 AnchorUpperCenter = new Vector2(0.5f, 0);
    public static Vector2 AnchorUpperRight = new Vector2(1, 0);
    public static Vector2 AnchorCenterLeft = new Vector2(0, 0.5f);
    public static Vector2 AnchorCenter = new Vector2(0.5f, 0.5f);
    public static Vector2 AnchorCenterRight = new Vector2(1, 0.5f);
    public static Vector2 AnchorLowerLeft = new Vector2(0, 1);
    public static Vector2 AnchorLowerCenter = new Vector2(0.5f, 1);
    public static Vector2 AnchorLowerRight = new Vector2(1, 1);

    public static void CopyPositionAndRotatationFrom(this Transform transform, Transform source)
    {
        transform.position = source.position;
        transform.rotation = source.rotation;
    }

    public static T FindFirstActiveInstance<T>() where T : Component
    {
        var instances = (T[]) UnityEngine.Object.FindObjectsOfType(typeof (T));
        return instances.FirstOrDefault(instance => instance.gameObject.activeInHierarchy);
    }

    public static T[] FindObjectsOfType<T>() where T : Object
    {
        return (T[]) Object.FindObjectsOfType(typeof (T));
    }

    public static void SetTextColor(this TextMesh textMesh, Color color)
    {
        var textRenderer = textMesh.GetComponent<MeshRenderer>();
        textRenderer.material = new Material(textRenderer.material);
        textRenderer.material.color = color;
    }

    public static T GetComponentByInterface<T>(this Component component) where T : class
    {
        return component.GetComponents<Component>().OfType<T>().FirstOrDefault();
    }

    public static T[] GetComponentsByInterface<T>(this Component component) where T : class
    {
        return component.GetComponents<Component>().OfType<T>().ToArray();
    }

    public static T GetComponentInChildrenByInterface<T>(this Component component) where T : class
    {
        return component.GetComponentsInChildren<Component>().OfType<T>().FirstOrDefault();
    }

    public static T[] GetComponentsInChildrenByInterface<T>(this Component component) where T : class
    {
        return component.GetComponentsInChildren<Component>().OfType<T>().ToArray();
    }

    public static T GetComponentParentHierachy<T>(this Component startPoint) where T : Component
    {
        while (startPoint != null)
        {
            var component = startPoint.GetComponent<T>();
            if (component != null)
                return component;

            startPoint = startPoint.transform.parent;
        }

        return null;
    }

    public static T GetOrCreateChild<T>(this Component component, string childName) where T : Component
    {
        var child = component.transform.Find(childName);
        if (child == null)
        {
            child = new GameObject(childName).transform;
            child.transform.parent = component.transform;
        }

        var childComponent = child.GetComponent<T>();
        if (childComponent == null)
        {
            childComponent = child.gameObject.AddComponent<T>();
        }

        return childComponent;
    }

    public static GameObject InstantiatePrefabGameObject(GameObject prefab)
    {
        return (GameObject) Object.Instantiate(prefab);
    }

    public static GameObject InstantiatePrefabGameObject(GameObject prefab, Vector3 position, Quaternion rotation = default(Quaternion))
    {
        return (GameObject) Object.Instantiate(prefab, position, rotation);
    }

    public static T InstantiatePrefab<T>(T prefab) where T : Component
    {
        return ((GameObject) Object.Instantiate(prefab.gameObject)).GetComponent<T>();
    }

    public static T InstantiatePrefab<T>(T prefab, Vector3 position, Quaternion rotation = default(Quaternion)) where T : Component
    {
        return ((GameObject) Object.Instantiate(prefab.gameObject, position, rotation)).GetComponent<T>();
    }

    public static Transform SetPosition(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        transform.position = transform.position.Change3(x, y, z);
        return transform;
    }

    public static Transform SetLocalPosition(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        transform.localPosition = transform.localPosition.Change3(x, y, z);
        return transform;
    }

    public static Transform SetLocalScale(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        transform.localScale = transform.localScale.Change3(x, y, z);
        return transform;
    }

    public static Transform SetLossyScale(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        var lossyScale = transform.lossyScale.Change3(x, y, z);

        transform.localScale = Vector3.one;
        transform.localScale = new Vector3(lossyScale.x / transform.lossyScale.x,
                                           lossyScale.y / transform.lossyScale.y,
                                           lossyScale.z / transform.lossyScale.z);

        return transform;
    }

    public static Transform SetRotationEuler(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        var euler = transform.rotation.eulerAngles.Change3(x, y, z);
        transform.rotation = Quaternion.Euler(euler);
        return transform;
    }

    public static Transform SetLocalRotationEuler(this Transform transform, float? x = null, float? y = null, float? z = null)
    {
        var euler = transform.localRotation.eulerAngles.Change3(x, y, z);
        transform.localRotation = Quaternion.Euler(euler);
        return transform;
    }

    public static Color Change(this Color color, float? r = null, float? g = null, float? b = null, float? a = null)
    {
        if (r.HasValue) color.r = r.Value;
        if (g.HasValue) color.g = g.Value;
        if (b.HasValue) color.b = b.Value;
        if (a.HasValue) color.a = a.Value;
        return color;
    }

    public static Color ChangeAlpha(this Color color, float a)
    {
        color.a = a;
        return color;
    }

    public static Vector2 Change2(this Vector2 vector, float? x = null, float? y = null)
    {
        if (x.HasValue) vector.x = x.Value;
        if (y.HasValue) vector.y = y.Value;
        return vector;
    }

    public static Vector3 Change3(this Vector3 vector, float? x = null, float? y = null, float? z = null)
    {
        if (x.HasValue) vector.x = x.Value;
        if (y.HasValue) vector.y = y.Value;
        if (z.HasValue) vector.z = z.Value;
        return vector;
    }

    public static Vector4 Change4(this Vector4 vector, float? x = null, float? y = null, float? z = null, float? w = null)
    {
        if (x.HasValue) vector.x = x.Value;
        if (y.HasValue) vector.y = y.Value;
        if (z.HasValue) vector.z = z.Value;
        if (w.HasValue) vector.w = w.Value;
        return vector;
    }

    public static void AssignLayerToHierarchy(this GameObject gameObject, int layer)
    {
        foreach (var transform in gameObject.GetComponentsInChildren<Transform>())
        {
            transform.gameObject.layer = layer;
        }
    }

    public static Vector2 CalculateViewportSizeAtDistance(this Camera camera, float distance, float aspectRatio = 0)
    {
        if (aspectRatio == 0)
        {
            aspectRatio = camera.aspect;
        }

        var viewportHeightAtDistance = 2.0f * Mathf.Tan(0.5f * camera.fieldOfView * Mathf.Deg2Rad) * distance;
        var viewportWidthAtDistance = viewportHeightAtDistance * aspectRatio;

        return new Vector2(viewportWidthAtDistance, viewportHeightAtDistance);
    }

    public static bool ContainsLayer(this LayerMask mask, int layer)
    {
        return (mask.value & (1 << layer)) != 0;
    }

    public static GameObject[] FindGameObjectsWithLayer(int layer)
    {
        var goArray = (GameObject[]) UnityEngine.Object.FindObjectsOfType(typeof (GameObject));
        var results = goArray.Where(t => t.layer == layer).ToList();
        return results.ToArray();
    }

    public static GameObject[] FindGameObjectsWithLayer(LayerMask layerMask)
    {
        var goArray = (GameObject[]) UnityEngine.Object.FindObjectsOfType(typeof (GameObject));
        var results = goArray.Where(t => layerMask.ContainsLayer(t.layer)).ToList();
        return results.ToArray();
    }

    public static Bounds CreateBoundsFrom(Collider[] colliders)
    {
        var bounds = colliders[0].bounds;

        foreach (var colliderComponent in colliders)
        {
            bounds.Encapsulate(colliderComponent.bounds);
        }

        return bounds;
    }

    public static RaycastHit[] CharacterControllerCastAll(CharacterController characterController, Vector3 origin, Vector3 direction, float distance, int layerMask)
    {
        var scale = characterController.transform.lossyScale;
        var radius = characterController.radius * scale.x;
        var height = characterController.height * scale.y - (radius * 2);
        var center = characterController.center;
        center.Scale(scale);
        var point1 = origin + center + Vector3.down * (height / 2f);
        var point2 = point1 + Vector3.up * height;

        return Physics.CapsuleCastAll(point1, point2, radius, direction, distance, layerMask);
        //return Physics.RaycastAll(origin, direction, distance, layerMask);
    }

    public static RaycastHit[] CharacterControllerCastAll(CharacterController characterController, Vector3 origin, Vector3 direction, int layerMask)
    {
        var scale = characterController.transform.lossyScale;
        var radius = characterController.radius * scale.x;
        var height = characterController.height * scale.y - (radius * 2);
        var center = characterController.center;
        center.Scale(scale);
        var point1 = origin + center + Vector3.down * (height / 2f);
        var point2 = point1 + Vector3.up * height;

        return Physics.CapsuleCastAll(point1, point2, radius, direction, Mathf.Infinity, layerMask);
        //return Physics.RaycastAll(origin, direction, distance, layerMask);
    }

    public static bool CharacterControllerCast(CharacterController characterController, Vector3 origin, Vector3 direction, out RaycastHit hitInfo, int layerMask)
    {
        var scale = characterController.transform.lossyScale;
        var radius = characterController.radius * scale.x;
        var height = characterController.height * scale.y - (radius * 2);
        var center = characterController.center;
        center.Scale(scale);
        var point1 = origin + center + Vector3.down * (height / 2f);
        var point2 = point1 + Vector3.up * height;

        return Physics.CapsuleCast(point1, point2, radius, direction, out hitInfo, Mathf.Infinity, layerMask);
    }

    public static bool CharacterControllerCast(CharacterController characterController, Vector3 origin, Vector3 direction, float distance, int layerMask)
    {
        var scale = characterController.transform.lossyScale;
        var radius = characterController.radius * scale.x;
        var height = characterController.height * scale.y - (radius * 2);
        var center = characterController.center;
        center.Scale(scale);
        var point1 = origin + center + Vector3.down * (height / 2f);
        var point2 = point1 + Vector3.up * height;

        return Physics.CapsuleCast(point1, point2, radius, direction, distance, layerMask);
    }

    public static void PlayParticleSystem(this ParticleSystem particleSystem, Vector3? position = null)
    {
        if (particleSystem == null)
            return;

        if (position != null)
            particleSystem.transform.position = position.Value;

        // Reset particle system interpolation
        // See: http://forum.unity3d.com/threads/134283-Moving-a-ParticleSystem-why-does-Unity-interpolate-its-position
        particleSystem.gameObject.SetActive(false);
        particleSystem.gameObject.SetActive(true);

        particleSystem.Play();
    }

    public static void StopParticleSystem(this ParticleSystem particleSystem)
    {
        if (particleSystem != null)
            particleSystem.Stop();
    }

    public static void SpawnParticleSystem(this ParticleSystem particleSystemPrefab, Vector3 position)
    {
        if (particleSystemPrefab == null)
            return;

        Object.Instantiate(particleSystemPrefab.gameObject, position, particleSystemPrefab.transform.rotation);
    }

    public static Vector2 CreateVector2AngleDeg(float angleDeg)
    {
        return CreateVector2AngleRad(angleDeg * Mathf.Deg2Rad);
    }

    private static Vector2 CreateVector2AngleRad(float angleRad)
    {
        return new Vector2(Mathf.Cos(angleRad), Mathf.Sin(angleRad));
    }

    public static float GetAngleRad(this Vector2 angle)
    {
        return Mathf.Atan2(angle.y, angle.x);
    }

    public static float GetAngleDeg(this Vector2 angle)
    {
        return Mathf.Atan2(angle.y, angle.x) * Mathf.Rad2Deg;
    }

    // http://answers.unity3d.com/questions/661383/whats-the-most-efficient-way-to-rotate-a-vector2-o.html
    public static Vector2 Rotate(this Vector2 v, float degrees)
    {
        float sin = Mathf.Sin(degrees * Mathf.Deg2Rad);
        float cos = Mathf.Cos(degrees * Mathf.Deg2Rad);

        float tx = v.x;
        float ty = v.y;
        v.x = (cos * tx) - (sin * ty);
        v.y = (sin * tx) + (cos * ty);

        return v;
    }

    // http://forum.unity3d.com/threads/vector-rotation.33215/
    public static Vector3 RotateX(this Vector3 v, float angle)
    {
        float sin = Mathf.Sin(angle);
        float cos = Mathf.Cos(angle);

        float ty = v.y;
        float tz = v.z;
        v.y = (cos * ty) - (sin * tz);
        v.z = (cos * tz) + (sin * ty);

        return v;
    }

    public static Vector3 RotateY(this Vector3 v, float angle)
    {
        float sin = Mathf.Sin(angle);
        float cos = Mathf.Cos(angle);

        float tx = v.x;
        float tz = v.z;
        v.x = (cos * tx) + (sin * tz);
        v.z = (cos * tz) - (sin * tx);

        return v;
    }

    public static Vector3 RotateZ(this Vector3 v, float angle)
    {
        float sin = Mathf.Sin(angle);
        float cos = Mathf.Cos(angle);

        float tx = v.x;
        float ty = v.y;
        v.x = (cos * tx) - (sin * ty);
        v.y = (cos * ty) + (sin * tx);

        return v;
    }

    public static float GetPitch(this Vector3 v)
    {
        float len = Mathf.Sqrt((v.x * v.x) + (v.z * v.z)); // Length on xz plane.
        return (-Mathf.Atan2(v.y, len));
    }

    public static float GetYaw(this Vector3 v)
    {
        return (Mathf.Atan2(v.x, v.z));
    }

    public static void SetFont(Font font, float sizeByHeight)
    {
        GUI.skin.font = font;

        var size = (int) (sizeByHeight * Screen.height);
        GUI.skin.label.fontSize = size;
        GUI.skin.textField.fontSize = size;
        GUI.skin.textArea.fontSize = size;
        GUI.skin.label.margin = new RectOffset();
        GUI.skin.label.padding = new RectOffset();
    }

    public static Rect ShowText(string text, Vector2 screenPosition, Vector2 relativeAnchor, Color color, TextAlignment alignment = TextAlignment.Left,
                                bool allUpperCase = false, bool clampToScreen = false)
    {
        if (allUpperCase)
            text = text.ToUpperInvariant();

        Color savedColor = GUI.color;
        GUI.color = color;

        GUI.skin.label.alignment = GetTextAnchorFromAlignment(alignment);

        var rect = GetTextRect(text, screenPosition, relativeAnchor, clampToScreen);

        GUI.Label(rect, text);

        GUI.color = savedColor;

        return rect;
    }

    public static Rect ShowTextOutlined(string text, Vector2 screenPosition, Vector2 relativeAnchor, Color color, int outlineStrength, Color outlineColor,
                                        TextAlignment alignment = TextAlignment.Left, bool allUpperCase = false, bool clampToScreen = false)
    {
        if (allUpperCase)
            text = text.ToUpperInvariant();

        Color savedColor = GUI.color;
        GUI.color = color;

        GUI.skin.label.alignment = GetTextAnchorFromAlignment(alignment);

        var rect = GetTextRect(text, screenPosition, relativeAnchor, clampToScreen);

        GuiLabelOutlined(rect, text, outlineStrength, outlineColor);

        GUI.color = savedColor;

        return rect;
    }

    public static void GuiLabelOutlined(Rect rect, string text, int outlineStrength, Color outlineColor)
    {
        var originalColor = GUI.color;

        GUI.color = outlineColor;

        rect.x += outlineStrength;
        GUI.Label(rect, text);
        rect.x -= outlineStrength * 2;
        GUI.Label(rect, text);
        rect.x += outlineStrength;
        rect.y += outlineStrength;
        GUI.Label(rect, text);
        rect.y -= outlineStrength * 2;
        GUI.Label(rect, text);
        rect.y += outlineStrength;

        GUI.color = originalColor;
        GUI.Label(rect, text);
    }

    private static TextAnchor GetTextAnchorFromAlignment(TextAlignment alignment)
    {
        switch (alignment)
        {
            case TextAlignment.Left:
                return TextAnchor.MiddleLeft;

            case TextAlignment.Center:
                return TextAnchor.MiddleCenter;

            case TextAlignment.Right:
                return TextAnchor.MiddleRight;
        }

        return TextAnchor.MiddleLeft;
    }

    public static Rect GetTextRect(string text, Vector2 screenPosition, Vector2 relativeAnchor, bool clampToScreen = false)
    {
        return GUI.skin.label.GetTextRect(text, screenPosition, relativeAnchor, clampToScreen);
    }

    public static Rect GetTextRect(Font font, float fontSizeByHeight, string text, Vector2 screenPosition, Vector2 relativeAnchor, bool clampToScreen = false)
    {
        var guiStyle = new GUIStyle();
        guiStyle.font = font;
        guiStyle.fontSize = (int) (fontSizeByHeight * Screen.height);

        return guiStyle.GetTextRect(text, screenPosition, relativeAnchor, clampToScreen);
    }

    public static Rect GetTextRect(this GUIStyle guiStyle, string text, Vector2 screenPosition, Vector2 relativeAnchor, bool clampToScreen = false)
    {
        var size = guiStyle.CalcSize(new GUIContent(text)); // * normalizedFontSize;
        var rect = new Rect(screenPosition.x + size.x * -relativeAnchor.x, screenPosition.y + size.y * -relativeAnchor.y, size.x, size.y);

        if (clampToScreen)
        {
            if (rect.x < 0)
                rect.x = 0;

            if (rect.y < 0)
                rect.y = 0;

            if (rect.xMax >= Screen.width)
                rect.x -= rect.xMax - Screen.width;

            if (rect.yMax >= Screen.width)
                rect.y -= rect.yMax - Screen.height;
        }
        return rect;
    }

    public static Vector2 GetTextSize(Font font, float fontSizeByHeight, string text)
    {
        var guiStyle = new GUIStyle();
        guiStyle.font = font;
        guiStyle.fontSize = (int) (fontSizeByHeight * Screen.height);

        return guiStyle.CalcSize(new GUIContent(text));
    }

    public static void StripCloneFromName(this GameObject gameObject)
    {
        gameObject.name = gameObject.GetNameWithoutClone();
    }

    public static string GetNameWithoutClone(this GameObject gameObject)
    {
        var gameObjectName = gameObject.name;

        var clonePartIndex = gameObjectName.IndexOf("(Clone)", StringComparison.Ordinal);
        if (clonePartIndex == -1)
            return gameObjectName;

        return gameObjectName.Substring(0, clonePartIndex);
    }

    public static T DeserializeFromString<T>(string str)
    {
        var serializer = new XmlSerializer(typeof (T));
        try
        {
            using (var stringReader = new StringReader(str))
            {
                return (T) serializer.Deserialize(stringReader);
            }
        }
        catch (Exception)
        {
            return default(T);
        }
    }

    public static string SerializeToString<T>(T data)
    {
        var serializer = new XmlSerializer(typeof (T));
        using (var stringWriter = new StringWriter())
        {
            serializer.Serialize(stringWriter, data);
            return stringWriter.ToString();
        }
    }

    public static bool PlayerPrefsGetBool(string key)
    {
        return PlayerPrefs.GetInt(key) == 1;
    }

    public static bool PlayerPrefsGetBool(string key, bool defaultValue)
    {
        return PlayerPrefs.GetInt(key, defaultValue ? 1 : 0) == 1;
    }

    public static void PlayerPrefsSetBool(string key, bool value)
    {
        PlayerPrefs.SetInt(key, value ? 1 : 0);
    }

    public static Rect CreateExtendedRect(this Rect rect, float extension)
    {
        var copy = rect;
        copy.xMin -= extension;
        copy.xMax += extension;
        copy.yMin -= extension;
        copy.yMax += extension;
        return copy;
    }

    public static bool Contains(this Rect rect, Vector2 position, float border)
    {
        return (position.x > rect.xMin + border) &&
               (position.y > rect.yMin + border) &&
               (position.x < rect.xMax - border) &&
               (position.y < rect.yMax - border);
    }

    public static bool MovingOutwards(this Rect rect, Vector2 position, Vector2 direction, float border)
    {
        return ((position.x < rect.xMin + border) && (direction.x < 0)) ||
               ((position.y < rect.yMin + border) && (direction.y < 0)) ||
               ((position.x > rect.xMax - border) && (direction.x > 0)) ||
               ((position.y > rect.yMax - border) && (direction.y > 0));
    }

    public static float GetBorderProximity(this Rect rect, float border, Vector2 position, Vector2? direction = null)
    {
        var left = 1f;
        var top = 1f;
        var right = 1f;
        var bottom = 1f;

        if ((position.x < rect.xMin + border) && (direction == null || (direction.Value.x < 0)))
            left = (position.x - rect.xMin) / border;

        if ((position.y < rect.yMin + border) && (direction == null || (direction.Value.y < 0)))
            top = (position.y - rect.yMin) / border;

        if ((position.x > rect.xMax - border) && (direction == null || (direction.Value.x > 0)))
            right = (rect.xMax - position.x) / border;

        if ((position.y > rect.yMax - border) && (direction == null || (direction.Value.y > 0)))
            bottom = (rect.yMax - position.y) / border;

        return Mathf.Min(left, top, right, bottom);
    }

    public static float RealDeltaTime { get { return (Time.timeScale > 0) ? (Time.deltaTime / Time.timeScale) : 0; } }
	public static float RealSmoothDeltaTime { get { return (Time.timeScale > 0) ? (Time.smoothDeltaTime / Time.timeScale) : 0; } }
}
