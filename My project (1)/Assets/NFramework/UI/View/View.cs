using System.Collections.Generic;
using System.Net;
using Proto.Promises;
using Unity.VisualScripting;
using Unity.VisualScripting.Antlr3.Runtime.Tree;

public partial class View
{
    public UIFacade Facade { get; private set; }
    protected View Parent { get; private set; }
    private void SetParent(View inParent)
    {
        this.Parent = inParent;
    }

    private void RemoveParent()
    {
        this.Parent = null;
    }


    private HashSet<View> _child;

    protected HashSet<View> Child
    {
        get
        {
            if (_child == null)
            {
                _child = new HashSet<View>();
            }

            return _child;
        }
    }


    public virtual void Awake(UIFacade inFacade)
    {
        if (inFacade == null)
        {
            this.Facade = inFacade;
            OnBindFacade();
            OnAwake();
        }
    }

    protected virtual void OnBindFacade()
    {
    }

    protected virtual void OnAwake()
    {
    }

    public virtual void Show()
    {
        OnShow();
        Enable();
    }

    public virtual void OnShow()
    {
    }

    public virtual void Enable()
    {
        this.Facade?.Enable();
        OnEnable();
    }

    public virtual void OnEnable()
    {
    }

    public virtual void Hide()
    {
        Disable();
        OnHide();
    }

    public virtual void OnHide()
    {
    }

    public virtual void Disable()
    {
        this.Facade?.Disable();
        OnDisable();
    }

    public virtual void OnDisable()
    {
    }

    public virtual void Focus()
    {
        OnFocus();
    }

    public virtual void OnFocus()
    {
    }

    public virtual void DeFocus()
    {
        OnDeFocus();
    }

    public virtual void OnDeFocus()
    {
    }

    public virtual void Destroy()
    {
        OnDestroy();
    }

    public virtual void OnDestroy()
    {
    }


    public T AddSubViewSync<T>(IUIFacadeProvider inProvider = null) where T : View, new()
    {
        var facade = inProvider.Alloc<T>();
        return _AddSubViewByFacade<T>(facade);
    }

    public async Promise<T> AddSubViewASync<T>(IUIFacadeProvider inProvider = null) where T : View, new()
    {
        var facade = await inProvider.AllocAsync<T>();
        return _AddSubViewByFacade<T>(facade);
    }

    public T AddSubViewByFacade<T>(UIFacade inFacade) where T : View, new()
    {
        return _AddSubViewByFacade<T>(inFacade);
    }

    public T AddSubViewByFacadeShow<T>(UIFacade inFacade) where T : View, new()
    {
        var result = _AddSubViewByFacade<T>(inFacade);
        result.Show();
        return result;
    }
}