using System;

namespace NFramework.Module.UI
{
    public class ViewAttribute : Attribute
    {
        public string Name;

        public ViewAttribute(string inName)
        {
            this.Name = inName;
        }
    }
}