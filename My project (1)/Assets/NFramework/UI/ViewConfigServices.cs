using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NFramework.UI
{
    /// <summary>
    /// UI框架View配置提供服务 ,组合优于继承，不把所有的东西塞到UIManager中
    /// </summary>
    public class ViewConfigServices
    {
        public ViewConfigServices()
        {

        }
        public ViewConfig GetViewConfig(string name)
        {
            return new ViewConfig();
        }

    }
}