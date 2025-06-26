namespace NFramework.UI
{
    public partial class View : IAwakeSystem, IDestroySystem
    {
        public void Awake()
        {
            OnAwake();
        }

        /// <summary>
        /// 初始化
        /// </summary>
        protected virtual void OnAwake()
        {

        }

        private void DestroyAwake()
        {

        }
    }
}