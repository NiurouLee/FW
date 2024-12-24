namespace Ez.UI
{
    internal class PersentingData
    {
        public string uiname;
        public object param;
        public bool isReady = false;
        public string replaceUi;
        public string parentUi;
        public bool closed = false;
        public bool hasError = false;
        public UIControllerBase controller;
        public UIControllerParam ctrlparam;
    }

    public enum UIWindowState : ushort
    {
        None = 1,
        Initial = 2,
        Loading = 3,
        Loaded = 4,
        Shown = 5,
        Hided = 6,
        Destoryed = 7,
    }

    public class UIEventID
    {
        //-异步加载在UIShow之前触发 同步加载在UIShow之后触发
        public const string UIAsyncBeginShown = "system_event_ui_async_begin_shown",
        //-跟UIClose的区别是加载中的界面被关闭也会触发
        UIBeginClosed = "system_event_ui_begin_closed",

        UIShown = "system_event_ui_shown", //UI显示 调用UIData 的Shown
        UIShowed = "system_event_ui_Showed", //UI显示 调用UIData 的Shown后的下一帧 真正显示
        UIClose = "system_event_ui_close", //UI关闭 调用UIData 的Close
        UIClosed = "system_event_ui_closed", //UI从UIManager中关闭
        UIClosedError = "system_event_ui_closed_error", //非正常关闭,可能1 加载界面资源失败, 2资源未加载完就关闭了

        UIHided = "system_event_ui_hided",
        AllHided = "system_event_ui_all_hided",

        UIBlurBackGroundShown = "system_event_ui_blur_background_shown",
        UIBlurBackGroundDispose = "system_event_ui_blur_background_dispose",
        UIBlurBackGroundHided = "system_event_ui_blur_background_hide",

        //-@UI加载完毕设置回调
        UIViewSetGameObject = "system_event_ui_view_set_game_object";
    }

    //public class UIStack<T> : IEnumerable<T>, IEnumerable, ICollection, IReadOnlyCollection<T>
    //{

    //}

    public enum ControllerFlags : int
    {
        None = 0,
        MainViewInited,
        InitView,

        WillAppear,
        Appear,

        RegisterEvent,
    }

}