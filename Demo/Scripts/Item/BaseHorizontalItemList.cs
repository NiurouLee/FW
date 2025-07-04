using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class BaseHorizontalItemList : MonoBehaviour
    {
        public List<BaseHorizontalItem> mItemList;

        public void Init()
        {
            foreach (BaseHorizontalItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
