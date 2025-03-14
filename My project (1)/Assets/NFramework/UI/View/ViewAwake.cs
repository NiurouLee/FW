namespace NFramework.UI
{
    public partial class View
    {
        public void SetUIFacade(UIFacade inUIFacade)
        {
            this.Facade = inUIFacade;
            this.OnBindFacade();
        }

        protected virtual void OnBindFacade()
        {
        }

        public void Awake()
        {
            OnAwake();
        }

        /// <summary>
        ///     初始化 只有GameObject实例化完成后调用一次  再次从池子中拿出来时不会调用
        /// </summary>
        protected virtual void OnAwake()
        {
        }
    }
}