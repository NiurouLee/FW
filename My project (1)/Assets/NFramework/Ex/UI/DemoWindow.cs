
using NFramework.UI;

[View("DemoWindow")]
public class DemoWindow : Window, IViewSetData<DemoWindowData>
{
    public DemoWindow()
    {

    }

    public void SetData(DemoWindowData inData)
    {
    }
}

public class DemoWindowData : IViewData
{
    public string Name;
}
