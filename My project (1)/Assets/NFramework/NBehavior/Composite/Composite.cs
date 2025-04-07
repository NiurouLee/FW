
using System.Collections.Generic;

namespace NFramework.NBehavior
{
    public abstract class Composite : Container
    {
        protected List<Node> children;

        public Composite(string inName) : base(inName)
        {
        }

        public override void SetRoot(Root inRootNode)
        {
            base.SetRoot(inRootNode);


        }

        protected override void Stopped(bool inSuccess)
        {
            if (this.children != null)
            {
                for (int i = 0; i < this.children.Count; i++)
                {
                    var child = this.children[i];
                    child.ParentCompositeStopped(this);
                }
            }
            base.Stopped(inSuccess);
        }


        protected T AddChild<T>(string inName) where T : Node, new()
        {
            var child = new T();
            child.SetParent(this);
            this.children.Add(child);
            return child;
        }

        public abstract void StopLowePriorityChildrenForChild(Node inChild, bool inImmediateRestart);

    }
}
