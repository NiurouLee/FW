using System;
using Proto.Promises;

namespace NFramework.UI
{
    /// <summary>
    ///  UIRequest阶段,当前到那个阶段了
    /// </summary>
    [Flags]
    public enum WindowRequestStage : Byte
    {
        Construct = 0,
        Checking = 1,
        SetInitData = 2,
        ConstructWindow = 3,
        ConstructWindowDone = 4,
        GameObjectLoading = 5,
        GameObjectLoaded = 6,
        LayerServicesChecking = 7,
        WindowAwake = 8,
        WindowOpen = 8,
        WindowClose = 9,
        GameObjectUnloading = 10,
        Invalid = 11,
    }

    /// <summary>
    /// 把打开一个UI封装成Request
    /// </summary>
    public class WindowRequest : IEquatable<WindowRequest>
    {
        public string Name { get; private set; }
        public ViewConfig Config { get; private set; }
        public WindowRequestStage Stage { get; private set; }
        public Window Window { get; private set; }
        public IViewData ViewData { get; private set; }
        public IResLoader ResLoader { get; private set; }
        public UIFacadeProviderAssetLoader UIFacadeProvider { get; private set; }

        public WindowRequest(ViewConfig inConfig)
        {
            if (inConfig == null)
            {
                Log.ErrStack(" WindowRequest inConfig is null");
            }

            this.Config = inConfig;
            this.Name = inConfig.Name;
            SetStage(WindowRequestStage.Construct);
        }

        public void SetStage(WindowRequestStage inStage)
        {
            if (inStage == this.Stage)
            {
                Log.ErrStack($"WindowRequest Err:Stage Repeat,WindowName：{this.Name}");
            }

            if (inStage < this.Stage)
            {
                Log.ErrStack($"WindowRequest Err:Stage Inverse,WindowName：{this.Name}");
            }

            this.Stage = inStage;
        }

        public void SetWindow(Window inWindow)
        {
            if (inWindow == null)
            {
                Log.ErrStack($"WindowRequest set Window Err,inWindow is null:WindowName{this.Name}");
            }

            if (this.Window != null)
            {
                Log.ErrStack($"WindowRequest set Window Err,Window dont is null:WindowName{this.Name}");
            }

            this.Window = inWindow;
        }

        public void SetInitData(IViewData inViewData)
        {
            this.ViewData = inViewData;
        }

        public void SetResLoader(IResLoader inResLoader)
        {
            this.ResLoader = inResLoader;
        }

        public void SetUIFacadeProvider(UIFacadeProviderAssetLoader inUIFacadeProvider)
        {
            this.UIFacadeProvider = inUIFacadeProvider;
        }

        public bool Equals(WindowRequest other)
        {
            if (other is null) return false;
            if (ReferenceEquals(this, other)) return true;
            return Name == other.Name;
        }

        public override bool Equals(object obj)
        {
            if (obj is null) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != GetType()) return false;
            return Equals((WindowRequest)obj);
        }

        public override int GetHashCode()
        {
            return (Name != null ? Name.GetHashCode() : 0);
        }


        /// <summary>
        /// 返回给业务的Promise
        /// </summary>
        public Promise<Window>.Deferred Deferred;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="promise"></param>
        internal void SetPromiseDeferred(Promise<Window>.Deferred deferred)
        {
            this.Deferred = deferred;
        }

    }
}