using System;
using NFramework.Core.Collections;

namespace NFramework.Module.UI
{
    [Serializable]
    public class ViewConfig
    {
        public string ID;
        public string AssetID;

        /// <summary>
        /// 31位 0 view 1 window
        /// 30位 
        ///
        /// ExclusionGroup
        /// </summary>
        public BitField32 Set;

        /// <summary>
        /// ExclusionGroup
        /// </summary>
        public Byte ExclusionGroup;

        /// <summary>
        /// Layer
        /// </summary>
        /// <returns></returns>
        public Byte Layer;
    }
}