using System.Collections.Generic;
using UnityEngine.UIElements.InputSystem;

namespace NFramework.Module.UIModule
{
    public static class InputMap
    {
        public static Dictionary<InputEnum, System.Type> InputMapDefine = new()
        {
            { InputEnum.Click, typeof(IUIClickComponent) },
            { InputEnum.DoubleClick, typeof(IUIClickComponent) },
            { InputEnum.LongClick, typeof(IUIClickComponent) },
            { InputEnum.Select, typeof(IUISelectComponent) },
        };


    }
}