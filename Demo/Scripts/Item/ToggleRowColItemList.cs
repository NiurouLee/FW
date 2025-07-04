using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class ToggleRowColItemList : MonoBehaviour
    {
        public List<ToggleRowColItem> mItemList;

        public void Init()
        {
            foreach (ToggleRowColItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
