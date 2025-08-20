using NFramework.Module.UIModule;

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

public class DemoWindowData
{
    public string Name;
}
