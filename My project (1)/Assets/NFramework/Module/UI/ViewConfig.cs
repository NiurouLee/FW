using System;
using NFramework.Core.Collections;

namespace NFramework.Module.UIModule
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
        /// Layer
        /// </summary>
        /// <returns></returns>
        public UIlayer Layer => (UIlayer)this.Set.Low;
        public bool IsWindow => this.Set.GetBit(31);
    }
}