using Proto.Promises;
using Nframework.Module.ObjectPoolModule;

namespace NFramework.Module.UI
{
    public partial class View
    {
        private SubViewRecords m_viewRecords;

        private SubViewRecords ViewRecords
        {
            get
            {
                if (m_viewRecords == null)
                {
                    m_viewRecords = GetFrameworkModule<ObjectPoolM>().Alloc<SubViewRecords>();
                    m_viewRecords.Awake();
                    m_viewRecords.SetView(this);
                }

                return m_viewRecords;
            }
        }
        public T AddSubViewSync<T>(IUIFacadeProvider inProvider) where T : View, new()
        {
            var facade = inProvider.Alloc<T>();
            return _AddSubViewByFacade<T>(facade, inProvider);
        }

        public async Promise<T> AddSubViewASync<T>(IUIFacadeProvider inProvider = null) where T : View, new()
        {
            var facade = await inProvider.AllocAsync<T>();
            return _AddSubViewByFacade<T>(facade, inProvider);
        }

        public T AddSubViewByFacade<T>(UIFacade inFacade) where T : View, new()
        {
            return _AddSubViewByFacade<T>(inFacade, this.Provider);
        }

        public T AddSubViewByFacadeShow<T>(UIFacade inFacade) where T : View, new()
        {
            var result = _AddSubViewByFacade<T>(inFacade, this.Provider);
            result.Show();
            return result;
        }

        public T AddSubViewByFacade<T>(T inView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View
        {
            return __addSubViewByFacade<T>(inView, inFacade, inProvider);
        }

        public T AddSubViewByFacadeShow<T>(T inView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View
        {
            var result = __addSubViewByFacade<T>(inView, inFacade, inProvider);
            result.Show();
            return result;
        }
        private T _AddSubViewByFacade<T>(UIFacade inFacade, IUIFacadeProvider inProvider) where T : View, new()
        {
            var result = Framework.Instance.GetModule<UIM>().CreateView<T>();
            return __addSubViewByFacade(result, inFacade, inProvider);
        }

        private T __addSubViewByFacade<T>(T inView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View
        {
            inView.SetParent(this);
            this._AddChild(inView);
            inView.SetUIFacade(inFacade, inProvider);
            inView.Awake();
            return inView;
        }


        private bool _AddChild(View inView)
        {
            if (inView == null)
            {
                return false;
            }

            return this.ViewRecords.TryAdd(inView);
        }


        public T RemoveSubView<T>(T inView) where T : View
        {
            return _RemoveSubView(inView);
        }

        private T _RemoveSubView<T>(T inView) where T : View
        {
            if (this.ViewRecords.TryRemove(inView))
            {
                inView.Destroy();
            }
            return inView;
        }

        private void DestroySubView()
        {
            if (this.m_viewRecords != null)
            {
                this.m_viewRecords.Destroy();
                this.m_viewRecords = null;
            }
        }
    }
}