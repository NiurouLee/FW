namespace NFramework.UI
{
    public class Window : View
    {

        public void Close()
        {
            UIManager.Instance.Close(this);
        }

    }
}