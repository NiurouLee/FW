using System.Collections.Generic;
using UnityEngine;

public class UIFacade : MonoBehaviour
{
    public Dictionary<string, Component> m_all = new Dictionary<string, Component>();

    public T Q<T>(string inName) where T : Component
    {
        if (this.m_all.TryGetValue(inName, out var com))
        {
            return com as T;
        }

        return null;
    }

    public void Visible()
    {
        this.gameObject?.SetActive(true);
    }

    public void NotVisible()
    {
        this.gameObject?.SetActive(false);
    }
}