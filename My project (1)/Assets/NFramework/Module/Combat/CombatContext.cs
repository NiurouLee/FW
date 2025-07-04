using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class CombatContext : Entity, IAwakeSystem
    {
        public Dictionary<long, Combat> combatDic = new();
        public Dictionary<long, AbilityItem> abilityItemDict = new();

        public void Awake()
        {

        }
        public Combat AddCombat(long inID, CombatTagType inTagType)
        {
            Combat combat = AddChild<Combat>();
            combat.AddComponent<CombatTagComponent, CombatTagType>(inTagType);
            combatDic.Add(inID, combat);
            return combat;
        }

        public Combat GetCombat(long inID)
        {
            combatDic.TryGetValue(inID, out Combat combat);
            return combat;
        }

        public void RemoveCombat(long inID)
        {
            if (combatDic.TryGetValue(inID, out Combat combat))
            {
                this.RemoveChild(combat.Id);
                combatDic.Remove(inID);
            }
        }

        public void GetCombatByTag(CombatTagType inTagType, ref List<Combat> outCombatList)
        {
            foreach (var combat in combatDic)
            {
                if (combat.Value.GetComponent<CombatTagComponent>().tagType == inTagType)
                {
                    outCombatList.Add(combat.Value);
                }
            }
        }

        public AbilityItem AddAbilityItem(long inID, long inCombatID)
        {
            AbilityItem abilityItem = AddChild<AbilityItem>();
            abilityItem.AddComponent<AbilityItemComponent, long, long>(inID, inCombatID);
            abilityItemDict.Add(inID, abilityItem);
            return abilityItem;
        }


    }

}