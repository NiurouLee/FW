using System;

namespace NFramework.Module.UI
{
    public class Window : View
    {
        public void Close()
        {
            Framework.Instance.GetModule<UIM>().Close(this);
        }

        private IUIFacadeProvider _selfFacadeProvider;
        internal IUIFacadeProvider GetSelfFacadeProvider()
        {
            if (_selfFacadeProvider == null)
            {
                _selfFacadeProvider = new UIFacadeProviderAssetLoader(this.ResLoadRecords);
            }
            return _selfFacadeProvider;
        }
    }
}