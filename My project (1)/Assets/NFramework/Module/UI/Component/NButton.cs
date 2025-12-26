using System;
using System.ComponentModel;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UIModule
{
    [RequireComponent(typeof(Button))]
    public class NButton : UnityEngine.Component, IUIClickComponent
    {
        public event Action<IUIClickComponent> OnClick;
        private Button _unityButton;
        public void UIAwake()
        {
            _unityButton = this.GetComponent<Button>();
            _unityButton.onClick.AddListener(this.OnClickTrigger);
        }

        public void UIDestroy()
        {
            _unityButton.onClick.RemoveListener(this.OnClickTrigger);
        }

        public void OnClickTrigger()
        {
            OnClick?.Invoke(this);
        }
    }
}