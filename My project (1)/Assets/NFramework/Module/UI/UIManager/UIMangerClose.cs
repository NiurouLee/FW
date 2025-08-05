namespace NFramework.Module.UI
{
    public partial class UIM
    {
        public void Close(Window inWindow)
        {
            inWindow.Hide();
            inWindow.Destroy();
        }
    }
}