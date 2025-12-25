using System;
using UnityEngine.UI;

namespace NFramework.Module.UIModule
{
    public class NButton : Button, IUIClickComponent, IUIPointerComponent, IUISubmitCancelComponent
    {
        protected override void Awake()
        {
            base.onClick.AddListener(this.OnClickTrigger);
        }

        public event Action<IUIClickComponent> OnClick;
        public void OnClickTrigger()
        {
            OnClick?.Invoke(this);
        }

        public event Action<IUIPointerComponent> OnPointerEnter;
        public event Action<IUIPointerComponent> OnPointerExit;
        public event Action<IUIPointerComponent> OnPointerDown;
        public event Action<IUIPointerComponent> OnPointerUp;
        public void TriggerPointerEnter() { OnPointerEnter?.Invoke(this); }
        public void TriggerPointerExit() { OnPointerExit?.Invoke(this); }
        public void TriggerPointerDown() { OnPointerDown?.Invoke(this); }
        public void TriggerPointerUp() { OnPointerUp?.Invoke(this); }

        public event Action<IUISubmitCancelComponent> OnSubmit;
        public event Action<IUISubmitCancelComponent> OnCancel;
        public void TriggerSubmit() { OnSubmit?.Invoke(this); }
        public void TriggerCancel() { OnCancel?.Invoke(this); }

        protected override void OnDestroy()
        {
            base.onClick.RemoveListener(this.OnClickTrigger);
        }
    }
}