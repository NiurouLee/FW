using UnityEngine.Device;

namespace Game
{
    public class DeviceTools
    {
        /// <summary>
        /// 计算设备等级
        /// </summary>
        /// <returns></returns>
        public static int GetDeviceLevel()
        {
            var gravendor = SystemInfo.graphicsDeviceVendor;
            var graname = SystemInfo.graphicsDeviceName;
            var sysmemory = SystemInfo.systemMemorySize;
            if (gravendor.Contains("Qualcomm"))
            {
                if (graname.Contains("740") || graname.Contains("730") ||
                    graname.Contains("685") || graname.Contains("680") || graname.Contains("660")
                    || graname.Contains("650") || graname.Contains("640") || graname.Contains("630"))
                {
                    return 3;
                }
                else if (graname.Contains("620") || graname.Contains("619") || graname.Contains("618")
                         || graname.Contains("540") || graname.Contains("530"))
                {
                    return 2;
                }
                else
                    return 1;
            }
            else if (gravendor.Contains("Apple"))
            {
                if (graname.Contains("A12") || graname.Contains("A13") || graname.Contains("A14") ||
                    graname.Contains("A15") || graname.Contains("A16")
                    || graname.Contains("M1") || graname.Contains("M2"))
                {
                    return 3;
                }
                else if (graname.Contains("A11"))
                {
                    return 2;
                }
                else
                    return 1;
            }
            else if (gravendor.Contains("ARM"))
            {
                if (graname.Contains("G710") || graname.Contains("G610") || graname.Contains("G78")
                    || graname.Contains("G77") || graname.Contains("G76") || graname.Contains("G68"))
                {
                    return 3;
                }
                else if (graname.Contains("G510") || graname.Contains("G72") || graname.Contains("G57")
                         || graname.Contains("G52") || graname.Contains("G71"))
                {
                    return 2;
                }
                else
                    return 1;
            }
            else
            {
                if (sysmemory <= 3096)
                    return 1;
                else if (sysmemory <= 4096)
                    return 2;
                else
                    return 3;
            }
        }
    }
}