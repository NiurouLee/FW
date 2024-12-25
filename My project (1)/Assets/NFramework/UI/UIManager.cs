using System.Collections.Generic;
using Proto.Promises;

namespace NFramework.UI
{
    public partial class UIManager
    {
        public Promise<T> Open<T>()
        {
            var result = Promise<T>.NewDeferred();
            return result.Promise;
        }


        // private Dictionary<string, ViewConfig> ;
        // private Dictionary<>
        // public ViewConfig GetConfig<T>() where T : View
        // {
        //     
        // }
    }
}