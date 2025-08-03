
using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.Math;

namespace NFramework.Module.Combat
{
    public class ItemComponent : Entity
    {
        public Combat Combat => GetParent<Combat>();

        public Dictionary<int, ItemAbility> Item;

    }
}