using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class BaseRowColItemList : MonoBehaviour
    {
        public List<BaseRowColItem> mItemList;

        public void Init()
        {
            foreach (BaseRowColItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
