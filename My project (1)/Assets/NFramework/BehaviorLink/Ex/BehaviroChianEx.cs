using System.Diagnostics;
using Proto.Promises;
using UnityEngine;

public class BehaviorChainEx
{
    public static void Test()
    {
        var behaviorChain = new BehaviorChain();
        behaviorChain.Append<BehaviorChain1>();
        behaviorChain.Execute();
    }

}

public class BehaviorChain1 : BehaviorChain
{
    protected override void Awake()
    {
        base.Awake();
        this.Append<BehaviorChain2>();
    }
}

public class BehaviorChain2 : BehaviorChain
{
    protected override void Awake()
    {
        base.Awake();
        this.Parent.Append<BehaviorChain3>();
    }

    public override void Execute()
    {
        UnityEngine.Debug.Log("BehaviorChain2 Execute");
        base.Execute();
        PromiseYielder.WaitForFrames(10);
        UnityEngine.Debug.Log("BehaviorChain2 Execute end");
        this.Success();
    }
}

internal class BehaviorChain3 : BehaviorChain
{
    protected override void Awake()
    {
        base.Awake();
    }

    public override void Execute()
    {
        base.Execute();
    }
}