using System.Runtime.CompilerServices;

namespace NFramework.UI
{
    public partial class View
    {
        public UIFacade Facade { get; private set; }
        public IUIFacadeProvider Provider { get; private set; }
        public void SetUIFacade(UIFacade inUIFacade, IUIFacadeProvider inProvider)
        {
            this.Facade = inUIFacade;
            this.Provider = inProvider;
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
        }
    }
}
