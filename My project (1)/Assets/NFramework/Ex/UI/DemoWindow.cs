using NFramework.Module.UIModule;

[View("DemoWindow")]
public class DemoWindow : Window, IViewSetData<DemoWindowData>
{
    public DemoWindow()
    {

this.LoadRes
    }

    
    public void SetData(DemoWindowData inData)
    {
    }
}

public class DemoWindowData
{
    public string Name;
}
