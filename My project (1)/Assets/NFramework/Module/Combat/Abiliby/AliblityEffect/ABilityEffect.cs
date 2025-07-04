using NFramework.Module.EntityModule;
using UnityEngine;

namespace NFramework.Module.Combat
{
    //AbilityEffect是挂在Ability上的
    public class AbilityEffect : Entity ,IAwakeSystem<Effect>
    {
        public Effect effect;
        public Entity OwnerAbility => (Entity)Parent;
        public Combat OwnerCombat => ((IAbility)OwnerAbility).Owner;



    }
}