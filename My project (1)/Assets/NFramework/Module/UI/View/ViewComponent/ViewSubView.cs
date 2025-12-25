using Proto.Promises;
using NFramework.Module.ObjectPoolModule;

namespace NFramework.Module.UIModule
{
    public class ViewSubViewComponent : ViewComponent
    {
        private SubViewRecords m_viewRecords;
        public SubViewRecords ViewRecords
        {
            get
            {
                if (m_viewRecords == null)
                {
                    m_viewRecords = GetFM<ObjectPoolM>().Alloc<SubViewRecords>();
                    m_viewRecords.Awake();
                    m_viewRecords.SetView(this.View);
                }

                return m_viewRecords;
            }
        }
    }
    public static class ViewSubViewComponentExtensions
    {

        #region  provider都没有,需要依赖DynamicProvider组建了

        #endregion

        #region  只有provider
        public static T AddSubViewSync<T>(this View inParentView, IUIFacadeProvider inProvider) where T : View, new()
        {
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            var facade = inProvider.Alloc<T>();
            var view = inParentView.GetFM<UIM>().CreateView<T>();
            return component.ViewRecords.AddSubViewByFacade<T>(view, facade, inProvider);
        }

        public static T AddSubViewSync<T, D>(this View inParentView, IUIFacadeProvider inProvider, D inData) where T : View, IViewSetData<D>, new()
        {
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            var facade = inProvider.Alloc<T>();
            var view = inParentView.GetFM<UIM>().CreateView<T>();
            return component.ViewRecords.AddSubViewByFacade<T, D>(view, facade, inProvider, inData);
        }

        public static async Promise<T> AddSubViewASync<T>(this View inParentView, IUIFacadeProvider inProvider) where T : View, new()
        {
            var deferred = inProvider.AllocAsync<T>();
            inParentView.AddPromise(deferred);
            var facade = await deferred.Promise;
            var view = inParentView.GetFM<UIM>().CreateView<T>();
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            return component.ViewRecords.AddSubViewByFacade<T>(view, facade, inProvider);
        }

        public static async Promise<T> AddSubViewASync<T, D>(this View inParentView, IUIFacadeProvider inProvider, D inData) where T : View, IViewSetData<D>, new()
        {

            var deferred = inProvider.AllocAsync<T>();
            inParentView.AddPromise(deferred);
            var facade = await deferred.Promise;
            var view = inParentView.GetFM<UIM>().CreateView<T>();
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            return component.ViewRecords.AddSubViewByFacade<T, D>(view, facade, inProvider, inData);
        }


        #endregion

        #region 有facade和provider
        public static T AddSubViewByFacade<T>(this View inParentView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View, new()
        {
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            return component.ViewRecords.AddSubViewByFacade<T>(inFacade, inProvider);
        }

        public static T AddSubViewByFacadeShow<T>(this View inParentView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View, new()
        {
            var result = AddSubViewByFacade<T>(inParentView, inFacade, inProvider);
            result.Show();
            return result;
        }
        #endregion

        #region 有view和facade和provider
        public static T AddSubViewByFacade<T>(this View inParentView, T inView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View
        {
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            return component.ViewRecords.AddSubViewByFacade<T>(inView, inFacade, inProvider);
        }

        public static T AddSubViewByFacadeShow<T>(this View inParentView, T inView, UIFacade inFacade, IUIFacadeProvider inProvider) where T : View
        {
            var result = AddSubViewByFacade<T>(inParentView, inView, inFacade, inProvider);
            result.Show();
            return result;
        }
        #endregion

        public static T RemoveSubView<T>(this View inParentView, T inView) where T : View
        {
            var component = ViewUtils.CheckAndAdd<ViewSubViewComponent>(inParentView);
            if (component.ViewRecords.TryRemove(inView))
            {
                inView.Destroy();
            }
            return inView;
        }
    }
}