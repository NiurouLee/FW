public partial class View
{
    private bool _AddChild(View inView)
    {
        if (inView == null)
        {
            return false;
        }

        return Child.Add(inView);
    }

    public bool _RemoveChild(View inView)
    {
        return Child.Remove(inView);
    }

    private T _AddSubViewByFacade<T>(UIFacade inFacade) where T : View, new()
    {
        var result = new T();
        result.SetParent(this);
        this._AddChild(result);
        result.Awake(inFacade);
        return result;
    }

    private T _RemoveSubView<T>(T inView) where T : View
    {
        inView.Destroy();
        inView.RemoveParent();
        this._RemoveChild(inView);
        return inView;
    }
}