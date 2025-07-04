﻿using System;
using System.Collections.Generic;
using NFramework.Core.ILiveing;

namespace NFramework.Module.Entity
{
    public enum InstanceQueueIndex
    {
        None = -1,
        Update,
        LateUpdate,
        FixedUpdate,
        RendererUpdate,
        BattleUpdate,
        BattleLateUpdate,
        Max,
    }

    public static class InstanceQueueMap
    {
        public static Dictionary<Type, InstanceQueueIndex> InstanceQueueMapDic =
            new Dictionary<Type, InstanceQueueIndex>()
            {
                { typeof(IUpdateSystem), InstanceQueueIndex.Update },
                { typeof(ILateUpdateSystem), InstanceQueueIndex.LateUpdate },
                { typeof(IRendererUpdateSystem), InstanceQueueIndex.RendererUpdate },
                { typeof(IFixedUpdateSystem), InstanceQueueIndex.FixedUpdate },
            };
    }
}