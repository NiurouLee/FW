using System;
using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class ConditionComponent : Entity
    {
        private Dictionary<long, Condition> _conditionDice = new Dictionary<long, Condition>();

        public void AddListener(long id, Action action, long obj)
        {
            
        }

    }
}