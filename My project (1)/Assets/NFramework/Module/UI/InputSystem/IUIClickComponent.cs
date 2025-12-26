using System;

namespace NFramework.Module.UIModule
{
    public interface IUIClickComponent : IUIInputComponent
    {
        public event Action<IUIClickComponent> OnClick;
        public void OnClickTrigger();
    }
}