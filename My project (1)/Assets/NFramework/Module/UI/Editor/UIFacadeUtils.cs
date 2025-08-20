using System.Collections.Generic;

namespace NFramework.Module.UIModule
{
    public static class UIFacadeUtils
    {

        public static bool CheckName(UnityEngine.Object target, int index, string name)
        {
            UIFacade _uiFacade = (UIFacade)target;
            for (int i = 0; i < _uiFacade.Elements.Count; i++)
            {
                if (i == index)
                {
                    continue;
                }
                UIElement _e = _uiFacade.Elements[i];
                if (_e.Name == name)
                {
                    return false;
                }
            }
            return true;
        }


    }
}