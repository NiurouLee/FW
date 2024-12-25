using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class UIImageIrregularRaycastMask : MonoBehaviour
{
    private float alphaTestThreshold = 0.1f;
    // Start is called before the first frame update
    void Start()
    {
        var image = GetComponent<Image>();
        if (null != image)
        {
            image.alphaHitTestMinimumThreshold = alphaTestThreshold;
        }
    }


}
