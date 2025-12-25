using System;

namespace NFramework.Module.UIModule
{
    public interface IUIClickComponent : IUIComponent
    {
        public event Action<IUIClickComponent> OnClick;
        public void OnClickTrigger();
    }
}