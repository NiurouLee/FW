using UnityEngine;

public static class ComponentExtensions
{
    public static void ExSetActive(this Component comp, bool active)
    {
        if (comp == null)
            return;

        if (comp.gameObject.activeSelf != active)
        {
            comp.gameObject.SetActive(active);
        }
    }
}