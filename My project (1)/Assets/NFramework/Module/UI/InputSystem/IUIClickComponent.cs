using System;

namespace NFramework.Module.UIModule
{
    public interface IUIClickComponent
    {
        public event Action<IUIClickComponent> OnClick;
        public void OnClickTrigger();
    }

    public interface IUIPointerComponent
    {
        public event Action<IUIPointerComponent> OnPointerEnter;
        public event Action<IUIPointerComponent> OnPointerExit;
        public event Action<IUIPointerComponent> OnPointerDown;
        public event Action<IUIPointerComponent> OnPointerUp;
        public void TriggerPointerEnter();
        public void TriggerPointerExit();
        public void TriggerPointerDown();
        public void TriggerPointerUp();
    }

    public interface IUIDragComponent
    {
        public event Action<IUIDragComponent> OnBeginDrag;
        public event Action<IUIDragComponent> OnDrag;
        public event Action<IUIDragComponent> OnEndDrag;
        public event Action<IUIDragComponent> OnDrop;
        public void TriggerBeginDrag();
        public void TriggerDrag();
        public void TriggerEndDrag();
        public void TriggerDrop();
    }

    public interface UIIScrollComponent
    {
        public event Action<UIIScrollComponent, float> OnScroll; // deltaY
        public void TriggerScroll(float delta);
    }

    public interface IUISubmitCancelComponent
    {
        public event Action<IUISubmitCancelComponent> OnSubmit;
        public event Action<IUISubmitCancelComponent> OnCancel;
        public void TriggerSubmit();
        public void TriggerCancel();
    }
}