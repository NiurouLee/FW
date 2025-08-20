using UnityEngine;
using System;

namespace NFramework.Module.UIModule
{
    public partial class View
    {
        public UIFacade Facade { get; private set; }
        public IUIFacadeProvider Provider { get; private set; }
        public RectTransform RectTransform { get; private set; }
        public void SetUIFacade(UIFacade inUIFacade, IUIFacadeProvider inProvider)
        {
            if (inUIFacade == null)
            {
                throw new Exception("inUIFacade is null");
            }
            this.Facade = inUIFacade;
            this.RectTransform = inUIFacade.GetComponent<RectTransform>();
            this.OnBindFacade();
        }

        protected virtual void OnBindFacade()
        {
        }

        private void DestroyFacade()
        {
            this.Provider.Free(this.Facade);
            this.Facade = null;
            this.Provider = null;
            this.RectTransform = null;
        }
    }
}
