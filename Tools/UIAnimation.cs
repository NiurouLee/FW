using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Ez.UI
{
    public enum UIShowAnimation
    {
        None = 0,
        UIFadeIn = 1,
        UIScaleIn = 2,
        UISceneVerticalIn = 3,
        UISceneHorizontalIn = 4,
        UISceneCharacterIn = 5,
    }

    public enum UICloseAnimation
    {
        None = 0,
        UIFadeOut = 1,
        UIScaleOut = 2,
        UISceneVerticalOut = 3,
        UISceneHorizontalOut = 4,
        UISceneCharacterOut = 5,
    }
}
